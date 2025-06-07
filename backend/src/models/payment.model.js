// backend/models/payment.model.js
const {DataTypes} = require('sequelize');
const {db} = require('../config/database.config');
const {User} = require('./user.model');
const {Order} = require('./order.model');

const Payment = db.define('payment', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  client_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: User,
      key: 'id',
    },
  },
  specialist_id:{
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: User,
      key: 'id',
    },
  },
  order_id: {
    type: DataTypes.INTEGER, 
    allowNull: false,
    references: {
      model: Order,
      key: 'id',
    },
    unique: true,
  },
  payment_method: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  amount: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
  },
  status: {
    type: DataTypes.STRING,
    allowNull: false,
    defaultValue: 'pending',
  },
  transaction_id: {
    type: DataTypes.STRING,
    allowNull: true,
  },
}, {
  tableName: 'payments',
  timestamps: false,
});

Payment.belongsTo(User, {
  foreignKey: 'client_id',
  as: 'client',
});

Payment.belongsTo(Order, {
  foreignKey: 'order_id',
  as: 'order',
});

module.exports = {Payment};