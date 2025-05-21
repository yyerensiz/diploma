// backend/controllers/order.controller.js
const { Order, OrderStatus } = require('../models/order.model'); // Import the Order model, and the OrderStatus enum if you have one
const { User } = require('../models/user.model'); // Import the User model
const { Payment } = require('../models/payment.model');
const { Op } = require('sequelize');
const { Specialist } = require('../models/specialist.model');
const { Child } = require('../models/child.model'); // Import the Child model
// new imports for payment
// const { sequelize } = require('../config/database.config');    // ← ADD THIS
const { db } = require('../config/database.config');
const { Wallet } = require('../models/wallet.model');
const { Transaction } = require('../models/transaction.model');
const { Subsidy } = require('../models/subsidy.model');

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
      amount: order.total_cost,
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
    const clientId = req.user.user_id;
    const orders = await Order.findAll({
      where: {
        client_id: clientId,
        //status: { [Op.ne]: OrderStatus.completed }
      },
      include: [{
        model: Specialist,
        as: 'specialist',
        include: [{ model: User, as: 'user', attributes: ['id','full_name','pfp_url'] }]
      }],
      order: [['created_at','DESC']]
    });

    // manually load children for each order
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
//   async updateOrder(req, res) {
//   try {
//     const orderId    = parseInt(req.params.id,   10);
//     const newStatus  = req.body.status;
//     const meUserId   = req.user.user_id;
//     const meRole     = req.user.role; // 'client' or 'specialist'

//     // 1) load order
//     const order = await Order.findByPk(orderId);
//     if (!order) return res.status(404).json({ error: 'Order not found' });

//     // 2) branch by role
//     if (meRole === 'specialist') {
//       // only the assigned specialist can change
//       const spec = await Specialist.findOne({ where: { user_id: meUserId }});
//       if (!spec || spec.id !== order.specialist_id) {
//         return res.status(403).json({ error: 'Unauthorized' });
//       }

//       // allowed transitions for specialist:
//       // pending → accepted or cancelled
//       // in_progress → completed
//       if (order.status === OrderStatus.pending
//         && [OrderStatus.accepted, OrderStatus.cancelled].includes(newStatus)) {
//         // ok
//       } else if (order.status === OrderStatus.in_progress
//         && newStatus === OrderStatus.completed) {
//         // ok
//       } else {
//         return res.status(400).json({ error: `Cannot ${newStatus} from ${order.status}` });
//       }

//     } else if (meRole === 'client') {
//       // only the ordering client can change
//       if (order.client_id !== meUserId) {
//         return res.status(403).json({ error: 'Unauthorized' });
//       }

//       // allowed only: accepted → in_progress
//       if (!(order.status === OrderStatus.accepted
//          && newStatus === OrderStatus.in_progress)) {
//         return res.status(400).json({ error: `Clients may only start accepted orders` });
//       }

//     } else {
//       return res.status(403).json({ error: 'Unauthorized role' });
//     }

//     // 3) finally apply
//     order.status = newStatus;
//     await order.save();

//     // 4) you might want to update the payment status once completed
//     if (newStatus === OrderStatus.completed) {
//       await Payment.update(
//         { status: 'completed' },
//         { where: { order_id: order.id } }
//       );
//     }

//     return res.json({ message: 'Order updated', order });
//   }
//   catch (err) {
//     console.error(err);
//     return res.status(500).json({ error: 'Failed to update order' });
//   }
// },
async updateOrder(req, res) {
  try {
    const orderId   = parseInt(req.params.id, 10);
    const meUser    = req.user;      // { user_id, role, … }
    const newStatus = req.body.status;

    const order = await Order.findByPk(orderId);
    if (!order) return res.status(404).json({ error: 'Order not found' });

    // … your role & transition checks here …

    if (meUser.role === 'specialist' && newStatus === OrderStatus.completed) {
      await db.transaction(async (t) => {
        // mark order completed
        await order.update({ status: newStatus }, { transaction: t });

        // load (or create) wallets
        const [clientWallet] = await Wallet.findOrCreate({
          where:      { user_id: order.client_id },
          defaults:   { balance: 0 },
          transaction: t,
        });
        // const [specWallet] = await Wallet.findOrCreate({
        //   where:      { user_id: order.specialist_id },
        //   defaults:   { balance: 0 },
        //   transaction: t,
        // });
        // Load the specialist row to get the user_id
        const specialist = await Specialist.findByPk(order.specialist_id, { transaction: t });
        if (!specialist) throw new Error('Specialist not found');

        // Now use specialist.user_id to find the wallet
        const [specWallet] = await Wallet.findOrCreate({
          where:      { user_id: specialist.user_id },
          defaults:   { balance: 0 },
          transaction: t,
        });
        // specWallet.balance += order.total_cost;
        // await specWallet.save({ transaction: t });
        // compute subsidy
        const sub            = await Subsidy.findOne({
          where:      { client_id: order.client_id },
          transaction: t,
        });
        const pct            = sub?.percentage || 0;
        const subsidyAmount  = order.total_cost * pct;
        const clientPays     = order.total_cost - subsidyAmount;

        if (clientWallet.balance < clientPays) {
          throw new Error('Insufficient balance');
        }

        // 1) deduct client
        clientWallet.balance -= clientPays;
        await clientWallet.save({ transaction: t });
        console.log('TO SPECIALIST TOTAL COST:', order.total_cost);
        console.log('TO SPECIALIST CLIENT PAYS:', clientPays);
        console.log('SUBSIDY:', subsidyAmount);
        console.log('CLIENT WALLET BALANCE:', clientWallet.balance);
        console.log('SPEC WALLET BALANCE:', specWallet.balance);
        console.log('SPEC USER ID:', specialist.user_id);
        console.log('SPEC WALLET ID:', specWallet.id);
        //console.log(':', specWallet.);

        // 2) credit specialist with full cost
        specWallet.balance += order.total_cost;
        // await specWallet.save({ transaction: t });  // ← make sure this is specWallet!
        await Wallet.update(
  { balance: db.literal(`balance + ${order.total_cost}`) },
  { where: { id: specWallet.id }, transaction: t }
);

        // 3) record the net‐payment transaction
        const netTx = await Transaction.create({
  from_user_id: order.client_id,
  to_user_id:   specialist.user_id, // <-- FIXED
  order_id:     order.id,
  amount:       clientPays,
  type:         'payment',
  status:       'completed',
}, { transaction: t });

if (subsidyAmount > 0) {
  await Transaction.create({
    from_user_id: null,
    to_user_id:   specialist.user_id, // <-- FIXED
    order_id:     order.id,
    amount:       subsidyAmount,
    type:         'subsidy',
    status:       'completed',
  }, { transaction: t });
}

        // 5) mark the original Payment row completed & link it
        await Payment.update({
          status:         'completed',
          transaction_id: netTx.id,
        }, {
          where:       { order_id: order.id },
          transaction: t,
        });
      });
    } else {
      // other flows: just update status
      await order.update({ status: newStatus });
    }

    return res.status(200).json({ message: 'Order updated', order });
  } catch (err) {
    console.error('Error updating order:', err);
    return res.status(500).json({ error: err.message });
  }
},


};

module.exports = orderController;