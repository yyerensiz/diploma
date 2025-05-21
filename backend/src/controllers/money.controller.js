// backend/src/controllers/money.controller.js
const { Wallet } = require('../models/wallet.model');
const { Transaction } = require('../models/transaction.model');
const { Subsidy } = require('../models/subsidy.model');
const { User } = require('../models/user.model');
const { sequelize } = require('../config/database.config');
const path = require('path');
const fs   = require('fs');

const moneyController = {
  /**
   * POST /api/money/charge
   * Client pays for a service; government subsidy reduces their out-of-pocket.
   * Body: { specialist_id, amount }
   */
  async charge(req, res) {
    const clientId = req.user.user_id;
    const { specialist_id, amount } = req.body;
    if (!specialist_id || !amount) {
      return res.status(400).json({ error: 'specialist_id and amount required' });
    }

    // wrap in a transaction
    const t = await sequelize.transaction();
    try {
      // 1) load or create wallets
      const [clientWallet] = await Wallet.findOrCreate({
        where: { user_id: clientId },
        defaults: { balance: 0 },
        transaction: t,
      });
      const [specWallet] = await Wallet.findOrCreate({
        where: { user_id: specialist_id },
        defaults: { balance: 0 },
        transaction: t,
      });

      // 2) fetch subsidy percentage (0..1) for this client
      const sub = await Subsidy.findOne({ where: { client_id: clientId }, transaction: t });
      const pct = sub?.percentage || 0;
      const subsidyAmount = amount * pct;
      const clientPays = amount - subsidyAmount;

      // 3) ensure client has enough balance
      if (clientWallet.balance < clientPays) {
        await t.rollback();
        return res.status(400).json({ error: 'Insufficient balance' });
      }

      // 4) deduct clientPays
      clientWallet.balance -= clientPays;
      await clientWallet.save({ transaction: t });

      // 5) credit specialist full amount
      specWallet.balance += amount;
      await specWallet.save({ transaction: t });

      // 6) record transactions
      // 6a) client → specialist net payment
      await Transaction.create({
        sender_id: clientId,
        receiver_id: specialist_id,
        amount: clientPays,
        type: 'payment',
        description: `Service payment (net)`,
      }, { transaction: t });

      // 6b) subsidy (system) → specialist
      if (subsidyAmount > 0) {
        await Transaction.create({
          sender_id: null,
          receiver_id: specialist_id,
          amount: subsidyAmount,
          type: 'subsidy',
          description: `Government subsidy`,
        }, { transaction: t });
      }

      await t.commit();
      return res.status(200).json({
        message: 'Charge successful',
        client_balance: clientWallet.balance,
        specialist_balance: specWallet.balance,
        subsidy: subsidyAmount,
        paid: clientPays,
      });
    } catch (err) {
      await t.rollback();
      console.error('Charge error:', err);
      return res.status(500).json({ error: 'Payment failed' });
    }
  },

  /**
   * GET /api/money/wallet
   * Fetch current balance for the authenticated user.
   */
  async getWallet(req, res) {
    try {
      const userId = req.user.user_id;
      const [wallet] = await Wallet.findOrCreate({
        where: { user_id: userId },
        defaults: { balance: 0 },
      });
      return res.status(200).json({ balance: wallet.balance });
    } catch (err) {
      console.error('Wallet error:', err);
      return res.status(500).json({ error: 'Failed to load wallet' });
    }
  },

  /**
   * GET /api/money/transactions
   * List all transactions where user is sender or receiver.
   */
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
        order: [['created_at', 'DESC']],
      });
      return res.status(200).json({ transactions: txs });
    } catch (err) {
      console.error('Transactions error:', err);
      return res.status(500).json({ error: 'Failed to load transactions' });
    }
  },

  /**
   * POST /api/money/subsidies
   * Add or update a subsidy percentage for a client.
   * Body: { client_id, percentage } (percentage between 0 and 1)
   */
  async setSubsidy(req, res) {
    try {
      const { client_id, percentage } = req.body;
      if (typeof client_id !== 'number' || typeof percentage !== 'number') {
        return res.status(400).json({ error: 'client_id and percentage required' });
      }
      if (percentage < 0 || percentage > 1) {
        return res.status(400).json({ error: 'percentage must be between 0 and 1' });
      }
      const [sub, created] = await Subsidy.upsert({
        client_id,
        percentage,
      }, { returning: true });
      return res.status(200).json({
        subsidy: sub,
        created,
      });
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
      const file     = req.file;
      if (!file) {
        return res.status(400).json({ error: 'Document is required' });
      }

      // ensure the final folder exists
      const uploadsDir = path.join(__dirname, '..', 'uploads', 'subsidies');
      if (!fs.existsSync(uploadsDir)) {
        fs.mkdirSync(uploadsDir, { recursive: true });
      }

      // move from tmp to our folder, give a unique name
      const destName = `${clientId}_${Date.now()}${path.extname(file.originalname)}`;
      const destPath = path.join(uploadsDir, destName);
      fs.renameSync(file.path, destPath);

      // Optionally create or update a "pending" subsidy record
      // Here we upsert a subsidy row with percentage=0, active=false until admin approves.
      await Subsidy.upsert({
        client_id: clientId,
        percentage: 0,
        active: false,
        document_path: destPath    // you may need to add this column
      });

      return res.status(200).json({ message: 'Subsidy request submitted' });
    } catch (err) {
      console.error('Error uploading subsidy document:', err);
      return res.status(500).json({ error: 'Failed to upload subsidy document' });
    }
  },
};

module.exports = moneyController;
