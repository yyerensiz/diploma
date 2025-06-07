// backend/routes/child.routes.js
const express = require('express');
const router = express.Router();
const childController = require('../controllers/child.controller');
const authMiddleware = require('../middleware/auth.middleware');

router.get('/my', authMiddleware.authenticate, authMiddleware.authorize(['client']), childController.getChildren);
router.get('/:id', authMiddleware.authenticate, childController.getChild);
router.post('/', authMiddleware.authenticate, authMiddleware.authorize(['client']), childController.createChild);
router.put('/:id', authMiddleware.authenticate, authMiddleware.authorize(['client']), childController.updateChild);
router.delete('/:id', authMiddleware.authenticate, authMiddleware.authorize(['client']), childController.deleteChild);

module.exports = router;