// backend/controllers/auth.controller.js
const { firebaseAdmin } = require('../config/firebase.config');
const { User } = require('../models/user.model');
const { Specialist } = require('../models/specialist.model');
const { generateCustomToken } = require('../services/auth.service');

const authController = {
  async register(req, res) {
    console.log('Register request body:', req.body);
    try {
      const { email, password, full_name, phone, role, fcm_token } = req.body;

      console.log('Creating user in Firebase...');
      const firebaseUser = await firebaseAdmin.auth().createUser({ email, password });
      console.log('Firebase user created:', firebaseUser);

      console.log('Creating user in PostgreSQL...');
      const user = await User.create({ firebase_uid: firebaseUser.uid, email, full_name, phone, role, fcm_token });
      console.log('PostgreSQL user created:', user.toJSON());
      console.log('User ID immediately after creation:', user.user_id);

      if (role === 'specialist') {
        console.log('Creating specialist profile...');
        console.log('User ID just before Specialist.create:', user.user_id);
        const specialist = await Specialist.create({
          user_id: user.user_id,
          bio: null,
          hourly_rate: null,
          rating: 0,
          service_ids: [],
          verified: false
        });
        console.log('Specialist profile created:', specialist);
      }

      console.log('Generating custom token...');
      const token = await generateCustomToken(firebaseUser.uid, role);
      console.log('Custom token generated:', token);

      res.status(201).json({ message: 'User registered successfully', user, token });
    } catch (error) {
      console.error('Error registering user:', error);
      res.status(500).json({ error: 'Failed to register user', message: error.message });
    }
  },

  async login(req, res) {
    console.log('Login request body:', req.body);
    try {
      const { token } = req.body;

      console.log('Verifying Firebase ID token...');
      const decodedToken = await firebaseAdmin.auth().verifyIdToken(token);
      console.log('Decoded token:', decodedToken);
      const firebaseUser = await firebaseAdmin.auth().getUser(decodedToken.uid);
      console.log('Firebase user:', firebaseUser);

      console.log('Retrieving user from PostgreSQL...');
      const user = await User.findOne({ where: { firebase_uid: decodedToken.uid } });
      console.log('PostgreSQL user:', user);
      if (!user) {
        const msg = 'User not found in database.  This should not happen.';
        console.error(msg);
        return res.status(404).json({ error: msg });
      }

      console.log('Generating custom token...');
      const customToken = await generateCustomToken(decodedToken.uid, user.role);
      console.log('Custom token:', customToken);

      res.status(200).json({ message: 'Login successful', user, token: customToken });
    } catch (error) {
      console.error('Error logging in user:', error);
      res.status(401).json({ error: 'Invalid token', message: error.message });
    }
  },

  async getMe(req, res) {
    console.log('GetMe request from user:', req.user);
    try {
      res.status(200).json({ user: req.user });
    } catch (error) {
      console.error('Error getting user profile:', error);
      res.status(500).json({ error: 'Failed to retrieve user profile', message: error.message });
    }
  },

  async resetPassword(req, res) {
    console.log('Reset password request for email:', req.body.email);
    try {
      const { email } = req.body;

      console.log('Sending password reset email to Firebase...');
      await firebaseAdmin.auth().sendPasswordResetEmail(email);
      console.log('Password reset email sent.');

      res.status(200).json({ message: 'Password reset email sent successfully' });
    } catch (error) {
      console.error('Error sending password reset email:', error);
      res.status(500).json({ error: 'Failed to send password reset email', message: error.message });
    }
  }
};

module.exports = authController;
