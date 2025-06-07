// backend/controllers/payment.controller.js
const { Payment } = require('../models/payment.model');
const { Order } = require('../models/order.model');

const paymentController = {
  async createPayment(req, res) {
    try {
      const { orderId, ...paymentData } = req.body;
      const clientId = req.user.id;

      const order = await Order.findOne({
        where: { id: orderId, client_id: clientId }
      });
      if (!order) {
        return res
          .status(400)
          .json({ error: 'Order not found, or payment is not allowed for its current status' });
      }

      const payment = await Payment.create({
        ...paymentData,
        client_id: clientId,
        order_id: orderId
      });

      res.status(201).json({ message: 'Payment created successfully', payment });
    } catch (error) {
      console.error('Error creating payment:', error);
      res.status(500).json({ error: 'Failed to create payment' });
    }
  },

  async getPayment(req, res) {
    try {
      const payment = await Payment.findOne({ where: { id: req.params.id } });
      if (!payment) {
        return res.status(404).json({ error: 'Payment not found' });
      }
      res.status(200).json({ payment });
    } catch (error) {
      console.error('Error getting payment:', error);
      res.status(500).json({ error: 'Failed to retrieve payment' });
    }
  },

  async getPaymentForOrder(req, res) {
    try {
      const payment = await Payment.findOne({ where: { order_id: req.params.orderId } });
      if (!payment) {
        return res.status(404).json({ error: 'Payment not found for this order' });
      }
      res.status(200).json({ payment });
    } catch (error) {
      console.error('Error getting payment for order:', error);
      res.status(500).json({ error: 'Failed to retrieve payment for order' });
    }
  }
};

module.exports = paymentController;
