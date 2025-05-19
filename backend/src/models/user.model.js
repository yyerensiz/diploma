// backend/models/user.model.js
const { DataTypes } = require('sequelize');
const { db } = require('../config/database.config');

const User = db.define('user', {
  user_id: { // Changed to user_id to match the database
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true,
    field: 'id' // Explicitly map to the database column name
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
    field: 'address' // Explicitly map to the database column name
  },
  role: {
    type: DataTypes.ENUM('client', 'specialist', 'admin'),
    allowNull: false,
  },
  full_name: { // Changed to full_name to match the database
    type: DataTypes.STRING,
    allowNull: true,
  },
  phone: { // Changed to phone to match the database
    type: DataTypes.STRING,
    allowNull: true,
    field: 'phone' // Explicitly map to the database column name
  },
  pfp_url: { // Added pfp_url to match the database
    type: DataTypes.STRING,
    allowNull: true,
    field: 'pfp_url'
  },
  fcm_token: {
    type: DataTypes.STRING,
    allowNull: true,
  },
  //  Removed first_name and last_name
}, {
  tableName: 'users',
  timestamps: true,
  createdAt: 'created_at', //explicitly define the column name if it is different
  updatedAt: false, //set to false, if you do not have this column in table
});

module.exports = { User };
