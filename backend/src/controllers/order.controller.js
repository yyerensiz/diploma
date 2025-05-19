// backend/controllers/order.controller.js
const { Order, OrderStatus } = require('../models/order.model'); // Import the Order model, and the OrderStatus enum if you have one
const { User } = require('../models/user.model'); // Import the User model
const { Payment } = require('../models/payment.model');
const { Op } = require('sequelize');
const { Specialist } = require('../models/specialist.model');
const { Child } = require('../models/child.model'); // Import the Child model
const orderController = {
  /**
   * Retrieves order details by ID.
   * Requires authentication.
   */
  async getOrder(req, res) {
    try {
      const orderId = req.params.id;
      const order = await Order.findOne({
        where: { id: orderId },
        include: [
          { model: User, as: 'client' }, //  Include the client user data
          { model: User, as: 'specialist' }, // Include the specialist user data
        ],
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

  /**
   * Creates a new order.
   * Requires authentication and authorization (client only).
   */
//   async createOrder(req, res) {
//   try {
//     const {
//       service_type,
//       child_ids,
//       scheduled_for,
//       description,
//       status,
//       total_cost,
//       specialist_id,
//     } = req.body;

//     const client_id = req.user.user_id;

//     const order = await Order.create({
//       client_id,
//       specialist_id,
//       service_type,    // ← now a string column
//       child_ids,
//       scheduled_for,
//       description,
//       status: status || OrderStatus.pending,
//       total_cost: total_cost || 0,
//     });
    
//     await Payment.create({
//       order_id: order.id,
//       client_id,
//       specialist_id,
//       amount: order.total_cost * 2,
//       payment_method: 'cash',       // For now, always 'cash'
//       status: 'pending',            // Or 'pending_payment' if you want
//     });
//     res.status(201).json(order);
//   } catch (error) {
//     console.error('Error creating order:', error);
//     res.status(500).json({ error: 'Failed to create order' });
//   }
// },
// controllers/order.controller.js

async createOrder(req, res) {
  try {
    const {
      service_type,
      child_ids = [],        // Postgres array in the request
      scheduled_for,
      description,
      status,
      total_cost,
      specialist_id,
    } = req.body;

    const client_id = req.user.user_id;

    // 1) Create the order (this only writes to orders.child_ids)
    const order = await Order.create({
      client_id,
      specialist_id,
      service_type,
      child_ids,             // array column
      scheduled_for,
      description,
      status: status || OrderStatus.pending,
      total_cost: total_cost || 0,
    });

    // 2) ALSO seed the join table so Sequelize.include('children') works:
    // if (child_ids.length) {
    //   // this will INSERT INTO order_children (order_id, child_id) VALUES …
    //   await order.setChildren(child_ids);
    // }

    // 3) Your existing payment logic…
    await Payment.create({
      order_id: order.id,
      client_id,
      specialist_id,
      amount: order.total_cost * 2,
      payment_method: 'cash',
      status: 'pending',
    });

    return res.status(201).json(order);
  } catch (error) {
    console.error('Error creating order:', error);
    return res.status(500).json({ error: 'Failed to create order' });
  }
},


  /**
   * Updates an order (e.g., status change).
   * Requires authentication and authorization (specialist only).
   */
  // async updateOrder(req, res) {
  //   try {
  //     const orderId = req.params.id;
  //     const updatedData = req.body;
  //     const specialistId = req.user.id;

  //     const order = await Order.findOne({ where: { id: orderId } });
  //     if (!order) {
  //       return res.status(404).json({ error: 'Order not found' });
  //     }

  //     //  Important:  Only the specialist assigned to the order can update it.
  //     if (order.specialist_id !== specialistId) {
  //       return res.status(403).json({ error: 'Unauthorized to update this order' });
  //     }

  //     //  You might want to add validation for status transitions (e.g., can't go from "completed" to "pending").
  //     if (updatedData.status) {
  //       //  validateStatusTransition(order.status, updatedData.status);  // Implement this function
  //     }
  //     await order.update(updatedData);
  //     const updatedOrder = await Order.findOne({where: {id: orderId}});

  //     //  Optionally, send notifications to the client and specialist about the order update.
  //     //  You'll need to implement the notification logic.

  //     res.status(200).json({ message: 'Order updated successfully', order: updatedOrder });
  //   } catch (error) {
  //     console.error('Error updating order:', error);
  //     res.status(500).json({ error: 'Failed to update order' });
  //   }
  // },
  /**
   * Retrieves orders for a client.
   * Requires authentication and authorization (client only).
   */
 async getClientOrders(req, res) {
  try {
    const authenticatedClientId = req.user.user_id; // or req.user.id, depending on your model
    console.log('Found user:', req.user?.user_id, req.user?.firebase_uid);

  

const orders = await Order.findAll({
  where: {
    client_id: authenticatedClientId,
    status: { [Op.ne]: 'completed' }
  },
  include: [{
    model: Specialist,
    as: 'specialist',
    include: [{ model: User, as: 'user' }]
  }],
  order: [['created_at', 'DESC']]
});
    res.status(200).json({ orders });
  } catch (error) {
    console.error('Error getting client orders:', error);
    res.status(500).json({ error: 'Failed to retrieve client orders' });
  }
},


  /**
   * Retrieves orders for a specialist.
   * Requires authentication and authorization (specialist only).
   */
 async getSpecialistOrders(req, res) {
  try {
    const meUserId = req.user.user_id;
    const specialist = await Specialist.findOne({ where: { user_id: meUserId } });
    if (!specialist) return res.status(404).json({ error: 'Specialist not found' });

    const orders = await Order.findAll({
      where: { specialist_id: specialist.id },
      include: [{ model: User, as: 'client', attributes: ['id','full_name','pfp_url'] }],
      order: [['created_at','DESC']],
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

  /** PUT /api/orders/:id */
  async updateOrder(req, res) {
    try {
      const orderId = parseInt(req.params.id, 10);
      const meUserId = req.user.user_id;

      // 1) Find your specialist record
      const specialist = await Specialist.findOne({ where: { user_id: meUserId } });
      if (!specialist) {
        return res.status(404).json({ error: 'Specialist profile not found' });
      }

      // 2) Load the order and ensure it belongs to *your* specialist.id
      const order = await Order.findOne({
        where: {
          id: orderId,
          specialist_id: specialist.id,
        }
      });
      if (!order) {
        return res.status(403).json({ error: 'Unauthorized to update this order' });
      }

      // 3) Apply updates (e.g. status)
      await order.update(req.body);

      return res.status(200).json({ message: 'Order updated successfully', order });
    } catch (err) {
      console.error('Error updating order:', err);
      return res.status(500).json({ error: 'Failed to update order' });
    }
  },

};

module.exports = orderController;