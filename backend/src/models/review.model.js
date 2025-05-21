// backend/models/review.model.js
const { DataTypes, Sequelize } = require('sequelize');
const { db }                  = require('../config/database.config');
const { User }                = require('./user.model');
const { Order }               = require('./order.model');
const { Specialist }          = require('./specialist.model');

const Review = db.define('review', {
  id: {
    type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true,
  },
  order_id: {
    type: DataTypes.INTEGER, allowNull: false,
    references: { model: 'orders', key: 'id' },
    unique: true,
  },
  client_id: {
    type: DataTypes.INTEGER, allowNull: false,
    references: { model: 'users', key: 'id' },
  },
  specialist_id: {
    type: DataTypes.INTEGER, allowNull: false,
    references: { model: 'specialists', key: 'id' },
  },
  rating: {
    type: DataTypes.INTEGER, allowNull: false,
    validate: { min: 1, max: 5 },
  },
  comment: {
    type: DataTypes.TEXT,
  },
}, {
  tableName: 'reviews',
  createdAt: 'created_at',
  updatedAt: false,
});

// Associations
Review.belongsTo(User, { foreignKey: 'client_id',    as: 'client' });
Review.belongsTo(Order, { foreignKey: 'order_id',     as: 'order'  });
Review.belongsTo(Specialist, { foreignKey: 'specialist_id', as: 'specialist' });

// After any change, recompute avg rating:
async function recomputeRating(review) {
  const [{ avg }] = await Review.findAll({
    attributes: [[Sequelize.fn('AVG', Sequelize.col('rating')), 'avg']],
    where: { specialist_id: review.specialist_id },
    raw: true
  });
  await Specialist.update(
    { rating: parseFloat(parseFloat(avg || 0).toFixed(2)) },
    { where: { id: review.specialist_id } }
  );
}

Review.afterCreate(recomputeRating);
Review.afterUpdate(recomputeRating);
Review.afterDestroy(recomputeRating);

module.exports = { Review };
