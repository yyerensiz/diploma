// backend/routes/client.routes.js
const express = require('express');
const router = express.Router();
const clientController = require('../controllers/client.controller');
const authMiddleware = require('../middleware/auth.middleware');

//  Client routes
router.get('/:id', authMiddleware.authenticate, clientController.getClient);
router.put('/:id', authMiddleware.authenticate, authMiddleware.authorize(['client']), clientController.updateClient);

module.exports = router;