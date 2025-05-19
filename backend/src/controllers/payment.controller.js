// backend/controllers/payment.controller.js
const { Payment } = require('../models/payment.model'); // Import the Payment model
const { Order } = require('../models/order.model'); // Import the Order model

const paymentController = {
  /**
   * Creates a new payment.
   * Requires authentication and authorization (client only).
   * A client can only create a payment for an existing order.
   */
  async createPayment(req, res) {
    try {
      const { orderId, ...paymentData } = req.body;
      const clientId = req.user.id; // Get client ID from the authenticated user

      //  Verify that the order exists, belongs to the client, and is in a state that allows payment
      const order = await Order.findOne({
        where: { id: orderId, client_id: clientId, /* Add status check, e.g., status: 'pending_payment' */ },
      });
      if (!order) {
        return res.status(400).json({ error: 'Order not found, or payment is not allowed for its current status' });
      }

      const payment = await Payment.create({
        ...paymentData,
        client_id: clientId, // Set the client ID
        order_id: orderId,
      });
      res.status(201).json({ message: 'Payment created successfully', payment });
    } catch (error) {
      console.error('Error creating payment:', error);
      res.status(500).json({ error: 'Failed to create payment' });
    }
  },

  /**
   * Retrieves payment details by ID.
   * Requires authentication.
   */
  async getPayment(req, res) {
    try {
      const paymentId = req.params.id;
      const payment = await Payment.findOne({ where: { id: paymentId } });
      if (!payment) {
        return res.status(404).json({ error: 'Payment not found' });
      }
      res.status(200).json({ payment });
    } catch (error) {
      console.error('Error getting payment:', error);
      res.status(500).json({ error: 'Failed to retrieve payment' });
    }
  },

  /**
   * Retrieves payment details for a specific order.
   * Requires authentication.
   */
  async getPaymentForOrder(req, res) {
    try {
      const orderId = req.params.orderId;
      const payment = await Payment.findOne({ where: { order_id: orderId } });
      if (!payment) {
        return res.status(404).json({ error: 'Payment not found for this order' });
      }
      res.status(200).json({ payment });
    } catch (error) {
      console.error('Error getting payment for order:', error);
      res.status(500).json({ error: 'Failed to retrieve payment for order' });
    }
  },
};

module.exports = paymentController;
