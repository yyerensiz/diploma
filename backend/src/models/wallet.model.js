const {DataTypes} = require('sequelize');
const {db} = require('../config/database.config');

const Wallet = db.define('wallet', {
  id: {type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true},
  user_id: {type: DataTypes.INTEGER, allowNull: false, unique: true},
  balance: {
  type: DataTypes.DECIMAL(14, 2),
  allowNull: false,
  defaultValue: 0.00
  },
}, {
  tableName: 'wallets',
  timestamps: false,
});

module.exports = {Wallet};
