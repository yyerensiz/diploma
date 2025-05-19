const { firebaseAdmin } = require('../config/firebase.config'); // Import Firebase Admin SDK
const { User } = require('../models/user.model'); // Import the User model
const { Specialist } = require('../models/specialist.model'); // Import the Specialist model
const { generateCustomToken } = require('../services/auth.service');

const authController = {
  /**
   * Registers a new user (client or specialist).
   * 1. Creates the user in Firebase Authentication (with a temporary password).
   * 2. Creates a corresponding record in the PostgreSQL database.
   * 3. If the user is a specialist, creates a corresponding record in the specialists table.
   */
  async register(req, res) {
    console.log('Register request body:', req.body); // Log the request body
    try {
      const { email, password, full_name, phone, role, fcm_token } = req.body;

      // 1. Create user in Firebase Authentication
      console.log('Creating user in Firebase...');
      const firebaseUser = await firebaseAdmin.auth().createUser({
        email,
        password,
      });
      console.log('Firebase user created:', firebaseUser); // Log Firebase user data

      // 2. Create user in PostgreSQL
      console.log('Creating user in PostgreSQL...');
      const user = await User.create({
        firebase_uid: firebaseUser.uid,
        email,
        full_name,
        phone,
        role,
        fcm_token,
      });
      console.log('PostgreSQL user created:', user.toJSON());
      console.log('User ID immediately after creation:', user.user_id); // <----- ACCESS VIA user.user_id

      // 3. If the user is a specialist, create a specialist profile
      if (role === 'specialist') {
        console.log('Creating specialist profile...');
        console.log('User ID just before Specialist.create:', user.user_id); // <----- ACCESS VIA user.user_id
        const specialist = await Specialist.create({
          user_id: user.user_id, // <----- ACCESS VIA user.user_id
          bio: null,
          hourly_rate: null,
          rating: 0,
          service_ids: [],
          verified: false,
        });
        console.log('Specialist profile created:', specialist);
      }

      //  Generate a custom token for client-side authentication
      console.log('Generating custom token...');
      const token = await generateCustomToken(firebaseUser.uid, role);
      console.log('Custom token generated:', token);

      res.status(201).json({ message: 'User registered successfully', user, token });
    } catch (error) {
      console.error('Error registering user:', error);
      res.status(500).json({ error: 'Failed to register user', message: error.message });
    }
  },


  /**
   * Logs in a user.
   * 1. Verifies the Firebase ID token from the client.
   * 2. Retrieves the user's role from the database.
   * 3. Returns a custom token and user data.
   */
  async login(req, res) {
    console.log('Login request body:', req.body); // Log the request body
    try {
      const { token } = req.body;

      // 1. Verify Firebase ID token
      console.log('Verifying Firebase ID token...');
      const decodedToken = await firebaseAdmin.auth().verifyIdToken(token);
      console.log('Decoded token:', decodedToken); // Log decoded token
      const firebaseUser = await firebaseAdmin.auth().getUser(decodedToken.uid);
      console.log('Firebase user:', firebaseUser)

      // 2. Retrieve user from PostgreSQL
      console.log('Retrieving user from PostgreSQL...');
      const user = await User.findOne({ where: { firebase_uid: decodedToken.uid } });
      console.log('PostgreSQL user:', user); // Log user data
      if (!user) {
        const errorMessage = 'User not found in database.  This should not happen.';
        console.error(errorMessage);
        return res.status(404).json({ error: errorMessage });
      }
      const role = user.role;

      // 3. Generate custom token
      console.log('Generating custom token...');
      const customToken = await generateCustomToken(decodedToken.uid, role);
      console.log('Custom token:', customToken);

      res.status(200).json({ message: 'Login successful', user, token: customToken });
    } catch (error) {
      console.error('Error logging in user:', error); // Log the error
      res.status(401).json({ error: 'Invalid token', message: error.message }); // Include the error message
    }
  },

  /**
   * Retrieves the currently logged-in user's profile.
   * Requires the authMiddleware.authenticate middleware.
   */
  async getMe(req, res) {
    console.log('GetMe request from user:', req.user);
    try {
      // The user's data is already attached to the request by the authMiddleware
      const user = req.user;
      res.status(200).json({ user });
    } catch (error) {
      console.error('Error getting user profile:', error);
      res.status(500).json({ error: 'Failed to retrieve user profile', message: error.message }); // Include error
    }
  },

  /**
   * Handles password reset requests.
   * Uses Firebase Authentication's password reset functionality.
   */
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
      res.status(500).json({ error: 'Failed to send password reset email', message: error.message }); // Include
    }
  },
};

module.exports = authController;