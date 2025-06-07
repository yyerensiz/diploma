// backend/models/info.model.js
const { DataTypes } = require('sequelize');
const { db } = require('../config/database.config');

const InfoPanel = db.define('info_panel', {
  id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  title: { type: DataTypes.STRING, allowNull: false },
  description: { type: DataTypes.TEXT, allowNull: false },
  color: { type: DataTypes.STRING, allowNull: false, defaultValue: 'blue' }
}, {
  tableName: 'info_panels',
  timestamps: false
});

module.exports = {InfoPanel};
