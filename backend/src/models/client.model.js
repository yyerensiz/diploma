// backend/models/client.model.js
const {DataTypes} = require('sequelize');
const {db} = require('../config/database.config');
const {User} = require('./user.model');

const Client = db.define('client', {
//   id: {
//     type: DataTypes.INTEGER,
//     primaryKey: true,
//     autoIncrement: true,
//   },
//   user_id: {
//     type: DataTypes.INTEGER, 
//     allowNull: false,
//     references: {
//       model: User,
//       key: 'id',
//     },
//     unique: true,
//   },
//   date_of_birth: {
//     type: DataTypes.DATE,
//     allowNull: true,
//   },
// }, {
//   tableName: 'clients',
//   timestamps: true,
});

User.hasOne(Client, {
  foreignKey: 'user_id',
  as: 'clientProfile',
});
Client.belongsTo(User, {
  foreignKey: 'user_id',
  as: 'user',
});

module.exports = {Client};