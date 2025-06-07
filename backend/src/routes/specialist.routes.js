const express = require('express');
const router = express.Router();
const specialistController = require('../controllers/specialist.controller');
const authMiddleware = require('../middleware/auth.middleware');
const upload = require('../middleware/upload');

router.get('/', specialistController.getAllSpecialists);
router.get('/profile', authMiddleware.authenticate, authMiddleware.authorize(['specialist']), specialistController.getSpecialistProfile); // New route
router.get('/:id', authMiddleware.authenticate, specialistController.getSpecialist);
router.put('/profile', authMiddleware.authenticate, authMiddleware.authorize(['specialist']), specialistController.updateSpecialistProfile); // Modified route for profile update
router.get('/:id/orders', authMiddleware.authenticate, authMiddleware.authorize(['specialist']), specialistController.getSpecialistOrders);
router.post(
  '/verify',
  authMiddleware.authenticate,
  authMiddleware.authorize(['specialist']),
  upload.fields([
    { name: 'id_document', maxCount: 1 },
    { name: 'certificate', maxCount: 1 },
  ]),
  specialistController.uploadVerificationDocs
);

module.exports = router;