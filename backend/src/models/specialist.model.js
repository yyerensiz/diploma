// backend/models/specialist.model.js
const {DataTypes} = require('sequelize');
const {db} = require('../config/database.config');
const {User} = require('./user.model');

const Specialist = db.define('specialist', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  },
  user_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: User,
      key: 'id',
    },
    unique: true,
  },
  bio: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  hourly_rate: {
    type: DataTypes.DECIMAL(10, 2), 
    allowNull: true,
  },
  available_times: {
    type: DataTypes.TEXT,
    allowNull: true,
  },
  rating: {
    type: DataTypes.DECIMAL(3, 2),
    allowNull: true,
  },
  // service_ids: {
  //   type: DataTypes.ARRAY(DataTypes.INTEGER),
  //   allowNull: true,
  // },
  verified: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
  },
}, {
  tableName: 'specialists',
  timestamps: false,
});

User.hasOne(Specialist, {
  foreignKey: 'user_id',
  as: 'specialistProfile',
});
Specialist.belongsTo(User, {
  foreignKey: 'user_id',
  as: 'user',
});

module.exports = {Specialist};