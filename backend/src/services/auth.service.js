// backend/services/auth.service.js
const { firebaseAdmin } = require('../config/firebase.config');

const authService = {
  /**
   * Generates a custom token for a given Firebase UID and role.
   * This token can be used to sign in the user on the client-side.
   */
  async generateCustomToken(uid, role) {
    try {
      //  Set custom claims, including the user's role.
      const customToken = await firebaseAdmin.auth().createCustomToken(uid, { role });
      return customToken;
    } catch (error) {
      console.error('Error generating custom token:', error);
      throw error; //  Re-throw the error so it can be handled by the caller
    }
  },
};

module.exports = authService;
