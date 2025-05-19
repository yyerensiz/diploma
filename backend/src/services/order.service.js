// backend/services/order.service.js
const { Order, OrderStatus } = require('../models/order.model'); // Import the Order model and OrderStatus

const orderService = {
  /**
   * Validates if a given status transition is allowed for an order.
   * For example, you might not want to allow an order to go directly from 'pending' to 'completed'.
   */
  async validateStatusTransition(currentStatus, newStatus) {
    const allowedTransitions = {
      [OrderStatus.pending]: [OrderStatus.accepted, OrderStatus.cancelled],
      [OrderStatus.accepted]: [OrderStatus.in_progress, OrderStatus.cancelled],
      [OrderStatus.in_progress]: [OrderStatus.completed, OrderStatus.cancelled],
      [OrderStatus.completed]: [], // No further transitions allowed
      [OrderStatus.cancelled]: [], // No further transitions allowed
    };

    if (!allowedTransitions[currentStatus]) {
      throw new Error(`Invalid current status: ${currentStatus}`);
    }

    if (!allowedTransitions[currentStatus].includes(newStatus)) {
      throw new Error(`Invalid status transition from ${currentStatus} to ${newStatus}`);
    }
    return true;
  },

  /**
   * Updates the order status and sends notifications.
   * @param orderId - The ID of the order to update.
   * @param newStatus - The new status to set for the order.
   * @param io -  The Socket.IO instance for sending real-time notifications.
   */
  async updateOrderStatusAndNotify(orderId, newStatus, io) {
    const order = await Order.findOne({ where: { id: orderId } });
    if (!order) {
      throw new Error('Order not found');
    }

    // Validate the status transition
    await this.validateStatusTransition(order.status, newStatus);

    // Update the order status
    order.status = newStatus;
    await order.save();

    //  Get the client and specialist IDs
    const { client_id, specialist_id } = order;

    // Emit a Socket.IO event to notify the client and specialist about the status change
    io.to(`user:${client_id}`).emit('order:updated', {
      orderId,
      newStatus,
      message: `Order status updated to ${newStatus}`,
    });
    io.to(`user:${specialist_id}`).emit('order:updated', {
      orderId,
      newStatus,
      message: `Order status updated to ${newStatus}`,
    });

    //  Consider sending an FCM notification as well (for when the user is not online)
    //  You would use the firebaseAdmin.messaging() here, similar to the notificationController
    //  (You'll need the FCM tokens of the client and specialist)

    return order; // Return the updated order
  },
};

module.exports = orderService;
