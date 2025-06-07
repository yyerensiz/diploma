//backend\src\routes\order.routes.js
const express = require('express');
const router = express.Router();
const orderController = require('../controllers/order.controller');
const authMiddleware = require('../middleware/auth.middleware');

router.get('/client', authMiddleware.authenticate, orderController.getClientOrders);
router.get('/specialist/:specialistId', authMiddleware.authenticate, authMiddleware.authorize(['specialist']), orderController.getSpecialistOrders);
router.get('/:id', authMiddleware.authenticate, orderController.getOrder);
router.post('/',authMiddleware.authenticate, authMiddleware.authorize(['client']), orderController.createOrder);
router.put('/:id',authMiddleware.authenticate, authMiddleware.authorize(['specialist','client']), orderController.updateOrder);

module.exports = router;
