// backend/models/review.model.js
const { DataTypes } = require('sequelize');
const { db } = require('../config/database.config');
const { User } = require('./user.model');
const { Order } = require('./order.model');

const Review = db.define('review', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  client_id: {
    type: DataTypes.INTEGER, // Changed to INTEGER
    allowNull: false,
    references: {
      model: User,
      key: 'user_id',
    },
  },
  order_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: Order,
      key: 'id'
    },
    unique: true,
  },
  rating: {
    type: DataTypes.INTEGER,
    allowNull: false,
    validate: {
      min: 1,
      max: 5,
    },
  },
  comment: {
    type: DataTypes.TEXT,
    allowNull: false,
  },
}, {
  tableName: 'reviews',
  timestamps: true,
});

Review.belongsTo(User, {
  foreignKey: 'client_id',
  as: 'client',
});
Review.belongsTo(Order, {
  foreignKey: 'order_id',
  as: 'order'
});

module.exports = { Review };
