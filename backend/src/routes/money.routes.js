// backend/src/routes/money.routes.js
const express = require('express');
const router = express.Router();
const moneyController = require('../controllers/money.controller');
const auth = require('../middleware/auth.middleware');

const upload  = require('../middleware/upload');

router.post('/charge', auth.authenticate, auth.authorize(['client']), moneyController.charge);
router.get('/wallet', auth.authenticate, moneyController.getWallet);
router.get('/transactions', auth.authenticate, moneyController.getTransactions);
router.post('/subsidies', auth.authenticate, auth.authorize(['admin']), moneyController.setSubsidy);
router.get('/subsidies',    auth.authenticate, moneyController.getSubsidies);
router.post(
  '/subsidies/apply',
  auth.authenticate,
  auth.authorize(['client']),
  upload.single('document'),
  moneyController.applySubsidyDocs
);
router.post('/replenish', auth.authenticate, auth.authorize(['client', 'specialist']), moneyController.replenishWallet);


module.exports = router;
