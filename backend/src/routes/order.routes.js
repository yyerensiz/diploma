//backend\src\routes\order.routes.js
const express        = require('express');
const router         = express.Router();
const orderController = require('../controllers/order.controller');
const authMiddleware = require('../middleware/auth.middleware');

// 1. Client sees their own orders
router.get(
  '/client',
  authMiddleware.authenticate,
  orderController.getClientOrders
);

// 2. Specialist sees *their* orders — must come before the generic '/:id'
router.get(
  '/specialist/:specialistId',
  authMiddleware.authenticate,
  authMiddleware.authorize(['specialist']),
  orderController.getSpecialistOrders
);

// 3. Fetch any single order by its ID
router.get(
  '/:id',
  authMiddleware.authenticate,
  orderController.getOrder
);

// 4. Create (client only)
router.post(
  '/',
  authMiddleware.authenticate,
  authMiddleware.authorize(['client']),
  orderController.createOrder
);

// 5. Update (specialist only)
router.put(
  '/:id',
  authMiddleware.authenticate,
  authMiddleware.authorize(['specialist','client']),
  orderController.updateOrder
);

module.exports = router;
