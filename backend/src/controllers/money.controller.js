// backend/src/controllers/money.controller.js
const { Wallet } = require('../models/wallet.model');
const { Transaction } = require('../models/transaction.model');
const { Subsidy } = require('../models/subsidy.model');
const { sequelize } = require('../config/database.config');
const path = require('path');
const fs = require('fs');
const { Card } = require('../paymentAPI/models/card.model');
const { db } = require('../config/database.config');
const { Op } = require('sequelize');


const moneyController = {
  async charge(req, res) {
    const clientId = req.user.user_id;
    const { specialist_id, amount } = req.body;
    if (!specialist_id || !amount) {
      return res.status(400).json({ error: 'specialist_id and amount required' });
    }

    const t = await sequelize.transaction();
    try {
      const [clientWallet] = await Wallet.findOrCreate({
        where: { user_id: clientId },
        defaults: { balance: 0 },
        transaction: t
      });
      const [specWallet] = await Wallet.findOrCreate({
        where: { user_id: specialist_id },
        defaults: { balance: 0 },
        transaction: t
      });

      const sub = await Subsidy.findOne({ where: { client_id: clientId }, transaction: t });
      const pct = sub?.percentage || 0;
      const subsidyAmount = amount * pct;
      const clientPays = amount - subsidyAmount;

      if (clientWallet.balance < clientPays) {
        await t.rollback();
        return res.status(400).json({ error: 'Insufficient balance' });
      }

      clientWallet.balance -= clientPays;
      await clientWallet.save({ transaction: t });

      specWallet.balance += amount;
      await specWallet.save({ transaction: t });

      await Transaction.create({
        sender_id: clientId,
        receiver_id: specialist_id,
        amount: clientPays,
        type: 'payment',
        description: 'Service payment (net)'
      }, { transaction: t });

      if (subsidyAmount > 0) {
        await Transaction.create({
          sender_id: null,
          receiver_id: specialist_id,
          amount: subsidyAmount,
          type: 'subsidy',
          description: 'Government subsidy'
        }, { transaction: t });
      }


      await t.commit();
      return res.status(200).json({
        message: 'Charge successful',
        client_balance: clientWallet.balance,
        specialist_balance: specWallet.balance,
        subsidy: subsidyAmount,
        paid: clientPays
      });
    } catch (err) {
      await t.rollback();
      console.error('Charge error:', err);
      return res.status(500).json({ error: 'Payment failed' });
    }
  },

  async getWallet(req, res) {
    try {
      const userId = req.user.user_id;
      const [wallet] = await Wallet.findOrCreate({
        where: { user_id: userId },
        defaults: { balance: 0 }
      });
      return res.status(200).json({ balance: wallet.balance });
    } catch (err) {
      console.error('Wallet error:', err);
      return res.status(500).json({ error: 'Failed to load wallet' });
    }
  },

  async getTransactions(req, res) {
    try {
      const userId = req.user.user_id;
      const txs = await Transaction.findAll({
        where: {
          [sequelize.Op.or]: [
            { sender_id: userId },
            { receiver_id: userId }
          ]
        },
        order: [['created_at', 'DESC']]
      });
      return res.status(200).json({ transactions: txs });
    } catch (err) {
      console.error('Transactions error:', err);
      return res.status(500).json({ error: 'Failed to load transactions' });
    }
  },

  async setSubsidy(req, res) {
    try {
      const { client_id, percentage } = req.body;
      if (
        typeof client_id !== 'number' ||
        typeof percentage !== 'number' ||
        percentage < 0 ||
        percentage > 1
      ) {
        return res.status(400).json({
          error: 'client_id and percentage required; percentage must be between 0 and 1'
        });
      }
      const [sub, created] = await Subsidy.upsert(
        { client_id, percentage },
        { returning: true }
      );
      return res.status(200).json({ subsidy: sub, created });
    } catch (err) {
      console.error('Subsidy error:', err);
      return res.status(500).json({ error: 'Failed to set subsidy' });
    }
  },

  async getSubsidies(req, res) {
    try {
      const clientId = req.user.user_id;
      const subs = await Subsidy.findAll({ where: { client_id: clientId } });
      return res.status(200).json({ subsidies: subs });
    } catch (err) {
      console.error('Subsidies error:', err);
      return res.status(500).json({ error: 'Failed to load subsidies' });
    }
  },

  async applySubsidyDocs(req, res) {
    try {
      const clientId = req.user.user_id;
      const file = req.file;
      if (!file) {
        return res.status(400).json({ error: 'Document is required' });
      }

      const uploadsDir = path.join(__dirname, '..', 'uploads', 'subsidies');
      if (!fs.existsSync(uploadsDir)) {
        fs.mkdirSync(uploadsDir, { recursive: true });
      }

      const destName = `${clientId}_${Date.now()}${path.extname(file.originalname)}`;
      const destPath = path.join(uploadsDir, destName);
      fs.renameSync(file.path, destPath);

      await Subsidy.upsert({
        client_id: clientId,
        percentage: 0,
        active: false,
        document_path: destPath
      });

      return res.status(200).json({ message: 'Subsidy request submitted' });
    } catch (err) {
      console.error('Error uploading subsidy document:', err);
      return res.status(500).json({ error: 'Failed to upload subsidy document' });
    }
  },

  async replenishWallet(req, res) {
  const userId = req.user.user_id;
  let { card_number, exp_date, cvv, amount } = req.body;

  console.log('‹replenishWallet› received body:', req.body);
  console.log('‹replenishWallet› typeof amount:', typeof amount, 'value:', amount);

  const parsedAmt = parseFloat(amount);
  console.log('‹replenishWallet› parsedAmt after parseFloat:', parsedAmt);

  if (isNaN(parsedAmt) || parsedAmt <= 0) {
    return res.status(400).json({ error: 'Amount must be a valid number > 0' });
  }

  try {
    const card = await Card.findOne({ where: { card_number, exp_date, cvv } });
    if (!card) {
      return res.status(404).json({ error: 'No card found matching those details' });
    }
    console.log('‹replenishWallet› card.balance BEFORE deduction:', card.balance);

    if (parseFloat(card.balance) < parsedAmt) {
      return res.status(400).json({ error: 'Insufficient card balance' });
    }

    card.balance = (parseFloat(card.balance) - parsedAmt).toFixed(2);
    await card.save();
    console.log('‹replenishWallet› card.balance AFTER deduction:', card.balance);

    const [wallet] = await Wallet.findOrCreate({
      where: { user_id: userId },
      defaults: { balance: 0.00 }
    });

    console.log('‹replenishWallet› wallet.balance BEFORE credit:', wallet.balance);

    wallet.balance = (parseFloat(wallet.balance) + parsedAmt).toFixed(2);
    await wallet.save();
    console.log('‹replenishWallet› wallet.balance AFTER credit:', wallet.balance);

    return res.status(200).json({
      message: 'Wallet replenished successfully',
      wallet_balance: wallet.balance
    });
  } catch (err) {
    console.error('Replenish Wallet error:', err);
    return res.status(500).json({ error: 'Failed to replenish wallet' });
  }
}
};

module.exports = moneyController;
