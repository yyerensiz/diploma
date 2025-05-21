// backend/models/transaction.model.js
const { DataTypes } = require('sequelize');
const { db } = require('../config/database.config');

const Transaction = db.define('transaction', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  from_user_id: {
    type: DataTypes.INTEGER,
    allowNull: true,       // null = system (subsidy)
  },
  to_user_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  order_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  amount: {
    type: DataTypes.FLOAT,
    allowNull: false,
  },
  type: {
    type: DataTypes.STRING,
    allowNull: false,      // e.g. 'payment' or 'subsidy'
  },
  status: {
    type: DataTypes.STRING,
    allowNull: false,      // e.g. 'completed'
  },
}, {
  tableName: 'transactions',
  timestamps: false,
  createdAt: 'created_at',
  updatedAt: false,
});

module.exports = { Transaction };
