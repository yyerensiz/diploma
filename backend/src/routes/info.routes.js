//backend\src\routes\info.routes.js
const express = require('express');
const router = express.Router();
const infoPanelController = require('../controllers/info.controller.js');

router.get('/', infoPanelController.getAll);

module.exports = router;
