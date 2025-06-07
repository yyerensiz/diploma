// backend/src/routes/admin.routes.js
const express = require('express');
const router = express.Router();
const adminController = require('../admin/admin.controller');
const authMiddleware = require('../middleware/auth.middleware');

router.use(authMiddleware.authenticate);
router.use(authMiddleware.authorize(['admin']));

router.get('/users', adminController.listUsers);
router.put('/users/:id', adminController.updateUser);



module.exports = router;
