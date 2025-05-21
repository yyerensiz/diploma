const { DataTypes } = require('sequelize');
const { db } = require('../config/database.config');

const Wallet = db.define('wallet', {
  id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  user_id: { type: DataTypes.INTEGER, allowNull: false, unique: true },
  balance: { type: DataTypes.FLOAT, defaultValue: 0 },
}, {
  tableName: 'wallets',
  // updatedAt: 'updated_at',
  // //underscored: true,
  // underscored:   true,           // auto‐map camelCase<->snake_case everywhere
  // //createdAt:    'created_at',    // look for `created_at` instead of `createdAt`
  // //updatedAt:    'updated_at', 
  timestamps: false,
});

module.exports = { Wallet };
