// backend/models/user.model.js
const {DataTypes} = require('sequelize');
const {db} = require('../config/database.config');

const User = db.define('user', {
  user_id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true,
    field: 'id'
  },
  firebase_uid: {
    type: DataTypes.STRING,
    allowNull: false,
    unique: true,
  },
  email: {
    type: DataTypes.STRING,
    allowNull: false,
    unique: true,
  },
  address: {
    type: DataTypes.STRING,
    allowNull: true,
    field: 'address'
  },
  role: {
    type: DataTypes.ENUM('client', 'specialist', 'admin'),
    allowNull: false,
  },
  full_name: {
    type: DataTypes.STRING,
    allowNull: true,
  },
  phone: {
    type: DataTypes.STRING,
    allowNull: true,
    field: 'phone'
  },
  pfp_url: {
    type: DataTypes.STRING,
    allowNull: true,
    field: 'pfp_url'
  },
  fcm_token: {
    type: DataTypes.STRING,
    allowNull: true,
  },
}, {
  tableName: 'users',
  timestamps: true,
  createdAt: 'created_at', 
  updatedAt: false,
});

module.exports = {User};
