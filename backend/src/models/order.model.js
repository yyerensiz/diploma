// backend/models/order.model.js
const { DataTypes }   = require('sequelize');
const { db }          = require('../config/database.config');
const { User }        = require('./user.model');
const { Specialist} = require('../models/specialist.model');
const { Child } = require('./child.model');
const OrderStatus = {
  pending:     'pending',
  accepted:    'accepted',
  in_progress: 'in_progress',
  completed:   'completed',
  cancelled:   'cancelled',
};

const Order = db.define('order', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },

  client_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: { model: User, key: 'id' },
  },

  specialist_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: { model: User, key: 'id' },
  },

  service_type: {
    type: DataTypes.STRING,
    allowNull: false,
  },


  child_ids: {             // this was missing
    type: DataTypes.ARRAY(DataTypes.INTEGER),
    allowNull: false,
  },

  scheduled_for: {
    type: DataTypes.DATE,
    allowNull: false,
  },

  description: {
    type: DataTypes.TEXT,
    allowNull: true,
  },

  status: {
    type: DataTypes.ENUM(...Object.values(OrderStatus)),
    allowNull: false,
    defaultValue: OrderStatus.pending,
  },

  total_cost: {
    type: DataTypes.DECIMAL(10,2),
    allowNull: false,
    defaultValue: 0.0,
  },
}, {
  tableName: 'orders',
  createdAt: 'created_at',
  updatedAt: 'updated_at',
});

Order.belongsTo(User, { foreignKey: 'client_id',     as: 'client'     });
//Order.belongsTo(User, { foreignKey: 'specialist_id', as: 'specialist' });
Order.belongsTo(Specialist, {
  foreignKey: 'specialist_id',   // orders.specialist_id
  targetKey: 'id',               // specialists.id
  as: 'specialist'
});
// Order.belongsToMany(Child, {
//   through: 'order_children',
//   foreignKey: 'order_id',
//   otherKey: 'child_id',
//   as: 'children',
// });
// Child.belongsToMany(Order, {
//   through: 'order_children',
//   foreignKey: 'child_id',
//   otherKey: 'order_id',
//   as: 'orders',
// });
module.exports = { Order, OrderStatus };
