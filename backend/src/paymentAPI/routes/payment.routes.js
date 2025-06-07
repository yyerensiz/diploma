// backend/src/paymentAPI/routes/payment.routes.js
const express = require('express');
const router = express.Router();
const paymentController = require('../controllers/payment.controller');

router.get('/cards', paymentController.listCards);
router.post('/cards', paymentController.createCard);
router.put('/cards/:id', paymentController.updateCard);
router.delete('/cards/:id', paymentController.deleteCard);
router.post('/charge', paymentController.chargeCard);

module.exports = router;
