// backend/models/child.model.js
const { DataTypes } = require('sequelize');
const { db } = require('../config/database.config');
const { User } = require('./user.model');

const Child = db.define('child', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  client_id: {
    type: DataTypes.UUID, // Changed to INTEGER
    allowNull: false,
    references: {
      model: 'users',
      key: 'client_id',
    },
  },
  full_name: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  birth_date: {
    type: DataTypes.DATE,
    allowNull: false,
  },
  bio: {
    type: DataTypes.TEXT, // or STRING if you prefer short bios
    allowNull: true,
  },
  pfp_url: {
    type: DataTypes.STRING,
    allowNull: true,
  },
}, {
  tableName: 'children',
  timestamps: false,
});

Child.belongsTo(User, {
  foreignKey: 'client_id',
  as: 'client',
});

module.exports = { Child };