// backend/controllers/review.controller.js
const { Review } = require('../models/review.model'); // Import the Review model
const { Order } = require('../models/order.model'); // Import the Order model

const reviewController = {
  /**
   * Retrieves a review by ID.
   * Requires authentication.
   */
  async getReview(req, res) {
    try {
      const reviewId = req.params.id;
      const review = await Review.findOne({ where: { id: reviewId } });
      if (!review) {
        return res.status(404).json({ error: 'Review not found' });
      }
      res.status(200).json({ review });
    } catch (error) {
      console.error('Error getting review:', error);
      res.status(500).json({ error: 'Failed to retrieve review' });
    }
  },

  /**
   * Creates a new review.
   * Requires authentication and authorization (client only).
   * A client can only create a review for an order they have completed.
   */
  async createReview(req, res) {
    try {
      const { orderId, ...reviewData } = req.body;
      const clientId = req.user.id; // Get client ID from the authenticated user

      //  Verify that the order exists and is completed, and belongs to the client
      const order = await Order.findOne({
        where: { id: orderId, client_id: clientId, status: 'completed' }, //  Add status check
      });
      if (!order) {
        return res.status(400).json({ error: 'Order not found, not completed, or does not belong to you' });
      }

      //  Check if a review for this order already exists
      const existingReview = await Review.findOne({ where: { order_id: orderId } });
      if (existingReview) {
        return res.status(400).json({ error: 'Review for this order already exists' });
      }

      const review = await Review.create({
        ...reviewData,
        client_id: clientId, // Set the client ID
        order_id: orderId,
      });
      res.status(201).json({ message: 'Review created successfully', review });
    } catch (error) {
      console.error('Error creating review:', error);
      res.status(500).json({ error: 'Failed to create review' });
    }
  },

  /**
   * Updates a review.
   * Requires authentication and authorization (client only).
   * Only the client who created the review can update it.
   */
  async updateReview(req, res) {
    try {
      const reviewId = req.params.id;
      const updatedData = req.body;
      const clientId = req.user.id; // Get client ID from the authenticated user

      const review = await Review.findOne({ where: { id: reviewId, client_id: clientId } }); //  Check client_id
      if (!review) {
        return res.status(404).json({ error: 'Review not found or unauthorized' });
      }

      await review.update(updatedData);
      const updatedReview = await Review.findOne({where: {id: reviewId}});
      res.status(200).json({ message: 'Review updated successfully', review: updatedReview });
    } catch (error) {
      console.error('Error updating review:', error);
      res.status(500).json({ error: 'Failed to update review' });
    }
  },

  /**
   * Retrieves reviews for a specialist.
   * Requires authentication.
   */
  async getSpecialistReviews(req, res) {
    try {
      const specialistId = req.params.specialistId;
      const reviews = await Review.findAll({
        where: { specialist_id: specialistId }, //  You'll need to have specialist_id in your Review model
        include: [
          { model: User, as: 'client' }, //  Include client information
        ],
      });
      res.status(200).json({ reviews });
    } catch (error) {
      console.error('Error getting specialist reviews:', error);
      res.status(500).json({ error: 'Failed to retrieve reviews' });
    }
  },
};

module.exports = reviewController;