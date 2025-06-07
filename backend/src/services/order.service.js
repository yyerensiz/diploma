// backend/services/order.service.js
const {Order, OrderStatus} = require('../models/order.model');

const orderService = {
  async validateStatusTransition(currentStatus, newStatus) {
    const allowedTransitions = {
      [OrderStatus.pending]: [OrderStatus.accepted, OrderStatus.cancelled],
      [OrderStatus.accepted]: [OrderStatus.in_progress, OrderStatus.cancelled],
      [OrderStatus.in_progress]: [OrderStatus.completed, OrderStatus.cancelled],
      [OrderStatus.completed]: [],
      [OrderStatus.cancelled]: []
    };

    if (!allowedTransitions[currentStatus]) {
      throw new Error(`Invalid current status: ${currentStatus}`);
    }
    if (!allowedTransitions[currentStatus].includes(newStatus)) {
      throw new Error(`Invalid status transition from ${currentStatus} to ${newStatus}`);
    }
    return true;
  },

  async updateOrderStatusAndNotify(orderId, newStatus, io) {
    const order = await Order.findOne({ where: { id: orderId } });
    if (!order) {
      throw new Error('Order not found');
    }

    await this.validateStatusTransition(order.status, newStatus);

    order.status = newStatus;
    await order.save();

    const { client_id, specialist_id } = order;

    io.to(`user:${client_id}`).emit('order:updated', {
      orderId,
      newStatus,
      message: `Order status updated to ${newStatus}`
    });
    io.to(`user:${specialist_id}`).emit('order:updated', {
      orderId,
      newStatus,
      message: `Order status updated to ${newStatus}`
    });

    return order;
  }
};

module.exports = orderService;
