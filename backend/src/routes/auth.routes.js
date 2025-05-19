// backend/routes/auth.routes.js
const express = require('express');
const router = express.Router();
const authController = require('../controllers/auth.controller');
const authMiddleware = require('../middleware/auth.middleware'); //  Import the auth middleware

//  Authentication routes
router.post('/register', authController.register);
router.post('/login', authController.login);
router.get('/me', authMiddleware.authenticate, authController.getMe); //  Use the middleware here
router.post('/reset-password', authController.resetPassword);

module.exports = router;
