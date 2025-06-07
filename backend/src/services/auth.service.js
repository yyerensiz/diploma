// backend/services/auth.service.js
const {firebaseAdmin} = require('../config/firebase.config');

const authService = {

  async generateCustomToken(uid, role) {
    try {
      const customToken = await firebaseAdmin.auth().createCustomToken(uid, { role });
      return customToken;
    } catch (error) {
      console.error('Error generating custom token:', error);
      throw error;
    }
  },
};

module.exports = authService;
