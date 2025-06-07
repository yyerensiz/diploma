// backend/controllers/order.controller.js
const { Order, OrderStatus } = require('../models/order.model');
const { User } = require('../models/user.model');
const { Payment } = require('../models/payment.model');
const { Specialist } = require('../models/specialist.model');
const { Child } = require('../models/child.model');
const { db } = require('../config/database.config');
const { Wallet } = require('../models/wallet.model');
const { Transaction } = require('../models/transaction.model');
const { Subsidy } = require('../models/subsidy.model');

const orderController = {
  async getOrder(req, res) {
    try {
      const orderId = req.params.id;
      const order = await Order.findOne({
        where: { id: orderId },
        include: [
          { model: User, as: 'client' },
          { model: User, as: 'specialist' }
        ]
      });
      if (!order) {
        return res.status(404).json({ error: 'Order not found' });
      }
      res.status(200).json({ order });
    } catch (error) {
      console.error('Error getting order:', error);
      res.status(500).json({ error: 'Failed to retrieve order' });
    }
  },

  async createOrder(req, res) {
    console.log('Creating order');
    try {
      const {
        service_type,
        child_ids = [],
        scheduled_for,
        description,
        status,
        total_cost,
        specialist_id
      } = req.body;
      console.log('Request body:', req.body);
      const client_id = req.user.user_id;
      const order = await Order.create({
        client_id,
        specialist_id,
        service_type,
        child_ids,
        scheduled_for,
        description,
        status: status || OrderStatus.pending,
        total_cost: total_cost || 0
      });
      console.log('Order created:', order);
      await Payment.create({
        order_id: order.id,
        client_id,
        specialist_id,
        amount: order.total_cost,
        payment_method: 'cash',
        status: 'pending'
      });
      return res.status(201).json(order);
    } catch (error) {
      console.error('Error creating order:', error);
      return res.status(500).json({ error: 'Failed to create order' });
    }
  },

  async getClientOrders(req, res) {
    try {
      const clientId = req.user.user_id;
      const orders = await Order.findAll({
        where: { client_id: clientId },
        include: [{
          model: Specialist,
          as: 'specialist',
          include: [{ model: User, as: 'user', attributes: ['id', 'full_name', 'pfp_url'] }]
        }],
        order: [['created_at', 'DESC']]
      });
      await Promise.all(orders.map(async o => {
        const kids = await Child.findAll({ where: { id: o.child_ids || [] } });
        o.dataValues.children = kids;
      }));
      return res.json({ orders });
    } catch (err) {
      console.error(err);
      return res.status(500).json({ error: 'Failed to retrieve client orders' });
    }
  },

  async getSpecialistOrders(req, res) {
    try {
      const meUserId = req.user.user_id;
      const specialist = await Specialist.findOne({ where: { user_id: meUserId } });
      if (!specialist) {
        return res.status(404).json({ error: 'Specialist not found' });
      }
      const orders = await Order.findAll({
        where: { specialist_id: specialist.id },
        include: [{ model: User, as: 'client', attributes: ['id', 'full_name', 'pfp_url'] }],
        order: [['created_at', 'DESC']]
      });
      await Promise.all(orders.map(async o => {
        const kids = await Child.findAll({ where: { id: o.child_ids || [] } });
        o.dataValues.children = kids;
      }));
      return res.status(200).json({ orders });
    } catch (err) {
      console.error(err);
      return res.status(500).json({ error: 'Failed to retrieve specialist orders' });
    }
  },

  async updateOrder(req, res) {
    try {
      const orderId = parseInt(req.params.id, 10);
      const meUser = req.user;
      const newStatus = req.body.status;
      const order = await Order.findByPk(orderId);
      if (!order) {
        return res.status(404).json({ error: 'Order not found' });
      }

      if (meUser.role === 'specialist' && newStatus === OrderStatus.completed) {
        await db.transaction(async (t) => {
          await order.update({ status: newStatus }, { transaction: t });

          const [clientWallet] = await Wallet.findOrCreate({
            where: { user_id: order.client_id },
            defaults: { balance: 0 },
            transaction: t
          });

          const specialist = await Specialist.findByPk(order.specialist_id, { transaction: t });
          if (!specialist) {
            throw new Error('Specialist not found');
          }

          const [specWallet] = await Wallet.findOrCreate({
            where: { user_id: specialist.user_id },
            defaults: { balance: 0 },
            transaction: t
          });

          const sub = await Subsidy.findOne({
            where: { client_id: order.client_id },
            transaction: t
          });
          const pct = sub?.percentage || 0;
          const subsidyAmount = order.total_cost * pct;
          const clientPays = order.total_cost - subsidyAmount;

          if (clientWallet.balance < clientPays) {
            throw new Error('Insufficient balance');
          }

          clientWallet.balance -= clientPays;
          await clientWallet.save({ transaction: t });

          await Wallet.update(
            { balance: db.literal(`balance + ${order.total_cost}`) },
            { where: { id: specWallet.id }, transaction: t }
          );

          const netTx = await Transaction.create({
            from_user_id: order.client_id,
            to_user_id: specialist.user_id,
            order_id: order.id,
            amount: clientPays,
            type: 'payment',
            status: 'completed'
          }, { transaction: t });

          if (subsidyAmount > 0) {
            await Transaction.create({
              from_user_id: null,
              to_user_id: specialist.user_id,
              order_id: order.id,
              amount: subsidyAmount,
              type: 'subsidy',
              status: 'completed'
            }, { transaction: t });
          }

          await Payment.update({
            status: 'completed',
            transaction_id: netTx.id
          }, {
            where: { order_id: order.id },
            transaction: t
          });
        });
      } else {
        await order.update({ status: newStatus });
      }

      return res.status(200).json({ message: 'Order updated', order });
    } catch (err) {
      console.error('Error updating order:', err);
      return res.status(500).json({ error: err.message });
    }
  }
};

module.exports = orderController;
