// backend/routes/notification.routes.js
const express = require('express');
const router = express.Router();
const notificationController = require('../controllers/notification.controller');
const authMiddleware = require('../middleware/auth.middleware');

//  Notification routes
router.post('/send', authMiddleware.authenticate, authMiddleware.authorize(['admin']), notificationController.sendNotification); //  Admin only

module.exports = router;