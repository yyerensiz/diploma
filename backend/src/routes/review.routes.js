// backend/routes/review.routes.js
const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/auth.middleware');
const reviewController = require('../controllers/review.controller');

router.get('/:id', authMiddleware.authenticate, reviewController.getReview);
router.post('/', authMiddleware.authenticate, authMiddleware.authorize(['client']), reviewController.createReview);
router.put('/:id', authMiddleware.authenticate, authMiddleware.authorize(['client']), reviewController.updateReview);
router.get('/specialist/:specialistId', authMiddleware.authenticate, reviewController.getSpecialistReviews);

module.exports = router;
