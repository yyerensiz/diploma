const { DataTypes } = require('sequelize');
const { db } = require('../config/database.config');

const Subsidy = db.define('subsidy', {
  id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  client_id: { type: DataTypes.INTEGER, allowNull: false, unique: true },
  percentage: { type: DataTypes.FLOAT, allowNull: false },
  active: {type: DataTypes.BOOLEAN, allowNull:false}, // e.g., 0.5 = 50%
}, {
  tableName: 'subsidies',
  timestamps: false,
  createdAt: false,
});

module.exports = { Subsidy };
