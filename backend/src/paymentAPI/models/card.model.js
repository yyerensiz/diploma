// backend/src/paymentAPI/models/card.model.js
const { DataTypes } = require('sequelize');
const { db } = require('../../config/database.config');

const Card = db.define('card', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  full_name: {
    type: DataTypes.STRING,
    allowNull: false
  },
  card_number: {
    type: DataTypes.STRING(16),
    allowNull: false,
    unique: true,
    validate: {
      isNumeric: {
        msg: 'Card number must contain only digits'
      },
      len: {
        args: [16, 16],
        msg: 'Card number must be exactly 16 digits'
      }
    }
  },
  exp_date: {
    type: DataTypes.STRING(5), // e.g. "MM/YY"
    allowNull: false,
    validate: {
      is: {
        args: /^(0[1-9]|1[0-2])\/\d{2}$/,
        msg: 'Expiration date must be in MM/YY format'
      }
    }
  },
  cvv: {
    type: DataTypes.STRING(3),
    allowNull: false,
    validate: {
      isNumeric: {
        msg: 'CVV must be numeric'
      },
      len: {
        args: [3, 3],
        msg: 'CVV must be exactly 3 digits'
      }
    }
  },
  balance: {
    type: DataTypes.DECIMAL(14, 2),
    allowNull: false,
    defaultValue: 0.0,
    validate: {
      min: {
        args: [0],
        msg: 'Balance cannot be negative'
      }
    }
  }
}, {
  tableName: 'cards',
  timestamps: false
});

module.exports = { Card };
