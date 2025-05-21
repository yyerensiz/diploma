const express = require('express');
const router = express.Router();
const specialistController = require('../controllers/specialist.controller');
const authMiddleware = require('../middleware/auth.middleware');
const multer = require('multer');

const upload = multer({
  dest: 'uploads/',
  limits: { fileSize: 5 * 1024 * 1024 }, // 5 MB
});

// Specialist routes
router.get('/', specialistController.getAllSpecialists); // <---- ADD THIS LINE
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
// router.post(
//   '/verify/approve/:id',
//   specialistController.approveSpecialist
// );
module.exports = router;