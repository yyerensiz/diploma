// backend/routes/auth.routes.js
const express = require('express');
const router = express.Router();
const authController = require('../controllers/auth.controller');
const authMiddleware = require('../middleware/auth.middleware'); 

router.post('/register', authController.register);
router.post('/login', authController.login);
router.get('/me', authMiddleware.authenticate, authController.getMe); 
router.post('/reset-password', authController.resetPassword);

module.exports = router;
