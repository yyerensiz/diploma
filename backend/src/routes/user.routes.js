// backend/routes/user.routes.js
const express = require('express');
const router = express.Router();
const userController = require('../controllers/user.controller');
const authMiddleware = require('../middleware/auth.middleware');

router.get('/:id', authMiddleware.authenticate, userController.getUser);
router.put('/:id', authMiddleware.authenticate, authMiddleware.authorize(['client', 'specialist']), userController.updateUser);

module.exports = router;
