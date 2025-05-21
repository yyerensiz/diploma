// backend/src/routes/money.routes.js
const express = require('express');
const router = express.Router();
const moneyController = require('../controllers/money.controller');
const auth = require('../middleware/auth.middleware');

const multer = require('multer');
const upload  = require('../middleware/upload');

// POST /api/money/charge
router.post('/charge', auth.authenticate, auth.authorize(['client']), moneyController.charge);

// GET /api/money/wallet
router.get('/wallet', auth.authenticate, moneyController.getWallet);

// GET /api/money/transactions
router.get('/transactions', auth.authenticate, moneyController.getTransactions);

// POST /api/money/subsidies
router.post('/subsidies', auth.authenticate, auth.authorize(['admin']), moneyController.setSubsidy);


router.get('/subsidies',    auth.authenticate, moneyController.getSubsidies);    // ← NEW!

router.post(
  '/subsidies/apply',
  auth.authenticate,
  auth.authorize(['client']),
  upload.single('document'),
  moneyController.applySubsidyDocs
);

module.exports = router;
