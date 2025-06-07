// backend/src/paymentAPI/controllers/payment.controller.js
const { Card } = require('../models/card.model');
const { Op, Sequelize } = require('sequelize');

const paymentController = {
  /**
   * List all cards in the system (for admin/CLI)
   */
  async listCards(req, res) {
    try {
      const cards = await Card.findAll({ order: [['id', 'ASC']] });
      return res.status(200).json({ cards });
    } catch (err) {
      console.error('List cards error:', err);
      return res.status(500).json({ error: 'Failed to fetch cards' });
    }
  },

  /**
   * Create a new card (bank account simulation).
   * Body: { full_name, card_number, exp_date, cvv, initial_balance }
   */
  async createCard(req, res) {
    const { full_name, card_number, exp_date, cvv, initial_balance } = req.body;
    if (!full_name || !card_number || !exp_date || !cvv) {
      return res.status(400).json({ error: 'full_name, card_number, exp_date, and cvv are required' });
    }

    try {
      const newCard = await Card.create({
        full_name,
        card_number,
        exp_date,
        cvv,
        balance: typeof initial_balance === 'number' ? initial_balance : 0.0
      });
      return res.status(201).json({ card: newCard });
    } catch (err) {
      console.error('Create card error:', err);
      if (err.name === 'SequelizeUniqueConstraintError' || err.name === 'SequelizeValidationError') {
        const messages = err.errors.map(e => e.message);
        return res.status(400).json({ error: messages.join('; ') });
      }
      return res.status(500).json({ error: 'Failed to create card' });
    }
  },

  /**
   * Update an existing card by ID.
   * Params: :id
   * Body can include any of { full_name, exp_date, cvv, balance } (card_number is immutable).
   */
  async updateCard(req, res) {
    const { id } = req.params;
    const { full_name, exp_date, cvv, balance } = req.body;

    try {
      const card = await Card.findByPk(id);
      if (!card) {
        return res.status(404).json({ error: 'No card found with that ID' });
      }
      if (full_name !== undefined) card.full_name = full_name;
      if (exp_date !== undefined)  card.exp_date = exp_date;
      if (cvv !== undefined)       card.cvv = cvv;
      if (balance !== undefined) {
        if (typeof balance !== 'number' || balance < 0) {
          return res.status(400).json({ error: 'Balance must be a non‐negative number' });
        }
        card.balance = balance;
      }
      await card.save();
      return res.status(200).json({ card });
    } catch (err) {
      console.error('Update card error:', err);
      if (err.name === 'SequelizeValidationError') {
        const messages = err.errors.map(e => e.message);
        return res.status(400).json({ error: messages.join('; ') });
      }
      return res.status(500).json({ error: 'Failed to update card' });
    }
  },

  /**
   * Delete a card by ID.
   * Params: :id
   */
  async deleteCard(req, res) {
    const { id } = req.params;
    try {
      const rowsDeleted = await Card.destroy({ where: { id } });
      if (rowsDeleted === 0) {
        return res.status(404).json({ error: 'No card found with that ID' });
      }
      return res.status(200).json({ message: 'Card deleted successfully' });
    } catch (err) {
      console.error('Delete card error:', err);
      return res.status(500).json({ error: 'Failed to delete card' });
    }
  },

  /**
   * Charge a card (simulate a purchase): 
   * Body: { card_number, exp_date, cvv, amount }
   *   – amount: how much to deduct from the card’s balance
   * On success: deduct that amount from card.balance and return the remaining card balance.
   * Errors:
   *   • 400 if missing/invalid fields or amount ≤ 0
   *   • 404 if no card matches (card_number, exp_date, cvv)
   *   • 400 if card.balance < amount (“Insufficient funds”)
   */
  async chargeCard(req, res) {
    const { card_number, exp_date, cvv, amount } = req.body;

    // 1) Validate input
    if (!card_number || !exp_date || !cvv || typeof amount !== 'number') {
      return res.status(400).json({
        error: 'card_number, exp_date, cvv, and numeric amount are required'
      });
    }
    if (amount <= 0) {
      return res.status(400).json({ error: 'Amount must be a positive number' });
    }

    try {
      // 2) Look up the card by exact match
      const card = await Card.findOne({
        where: {
          card_number,
          exp_date,
          cvv
        }
      });
      if (!card) {
        return res.status(404).json({ error: 'No account found matching those details' });
      }

      // 3) Check if there is enough balance
      if (card.balance < amount) {
        return res.status(400).json({ error: 'Insufficient funds' });
      }

      // 4) Deduct from the card’s balance, save, and return the new balance
      card.balance -= amount;
      await card.save();

      return res.status(200).json({
        message: 'Card charged successfully',
        card_id: card.id,
        remaining_balance: card.balance
      });
    } catch (err) {
      console.error('Charge card error:', err);
      return res.status(500).json({ error: 'Failed to charge card' });
    }
  }
};

module.exports = paymentController;
