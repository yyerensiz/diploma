// backend/src/middleware/upload.js
const multer = require('multer');
const tmp = multer({ dest: 'uploads/subsidies/tmp' });
module.exports = tmp;
