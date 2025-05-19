// backend/routes/payment.routes.js
const express = require('express');
const router = express.Router();
const paymentController = require('../controllers/payment.controller');
const authMiddleware = require('../middleware/auth.middleware');

//  Payment routes
router.post('/', authMiddleware.authenticate, authMiddleware.authorize(['client']), paymentController.createPayment);
router.get('/:id', authMiddleware.authenticate, paymentController.getPayment);
router.get('/order/:orderId', authMiddleware.authenticate, paymentController.getPaymentForOrder);

module.exports = router;

