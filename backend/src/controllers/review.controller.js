// backend/controllers/review.controller.js
const { Review }     = require('../models/review.model');
const { Order }      = require('../models/order.model');
const { Specialist } = require('../models/specialist.model');
const { User }       = require('../models/user.model');

const reviewController = {
  async getReview(req, res) {
    const review = await Review.findByPk(req.params.id, {
      include: [{ model: User, as: 'client', attributes: ['id','full_name'] }]
    });
    if (!review) return res.status(404).json({ error: 'Not found' });
    res.json({ review });
  },

  async createReview(req, res) {
    const client_id     = req.user.user_id;
    const { order_id, specialist_id, rating, comment } = req.body;

    // order must belong to client and be completed
    const order = await Order.findOne({
      where: { id: order_id, client_id, status: 'completed' }
    });
    if (!order) {
      return res.status(400).json({ error: 'Order invalid' });
    }

    // only one review per order
    if (await Review.findOne({ where: { order_id } })) {
      return res.status(400).json({ error: 'Already reviewed' });
    }

    const review = await Review.create({
      order_id, client_id, specialist_id, rating, comment
    });
    res.status(201).json({ review });
  },

  async updateReview(req, res) {
    const client_id = req.user.user_id;
    const review = await Review.findOne({
      where: { id: req.params.id, client_id }
    });
    if (!review) return res.status(404).json({ error: 'Not found or unauthorized' });

    await review.update(req.body);
    res.json({ review });
  },

  async getSpecialistReviews(req, res) {
    const specialist_id = parseInt(req.params.specialistId, 10);
    const reviews = await Review.findAll({
      where: { specialist_id },
      include: [{ model: User, as: 'client', attributes: ['id','full_name'] }],
      order: [['created_at','DESC']],
    });
    res.json({ reviews });
  },
};

module.exports = reviewController;
