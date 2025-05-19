// backend/middleware/auth.middleware.js
const { firebaseAdmin } = require('../config/firebase.config');
const { db } = require('../config/database.config'); // Import your database connection
const { User } = require('../models/user.model'); // Import the User model

const authMiddleware = {
  /**
   * Middleware to authenticate a user by verifying their Firebase ID token.
   * Attaches the user object to the request for subsequent route handlers.
   */
  async authenticate(req, res, next) {
    try {
      const authorizationHeader = req.headers.authorization;

      if (!authorizationHeader || !authorizationHeader.startsWith('Bearer ')) {
        return res.status(401).json({ error: 'Authorization header is missing or invalid' });
      }

      const token = authorizationHeader.split('Bearer ')[1];
      if (!token) {
        return res.status(401).json({ error: 'Token is missing' });
      }

      // Verify the ID token using Firebase Admin SDK
      const decodedToken = await firebaseAdmin.auth().verifyIdToken(token);
      const firebaseUser = await firebaseAdmin.auth().getUser(decodedToken.uid);


      // Fetch user from database using firebase_uid
      const user = await User.findOne({ where: { firebase_uid: decodedToken.uid } });
      if (!user) {
        return res.status(404).json({ error: 'User not found in database' });
      }

      // Attach the user object to the request.  Important for subsequent middleware/controllers.
      req.user = user;
      next(); //  Call next() to pass control to the next middleware or route handler
    } catch (error) {
      console.error('Authentication error:', error);
      return res.status(401).json({ error: 'Invalid token' }); //  Return 401 for authentication failures
    }
  },

  /**
   * Middleware to authorize a user based on their role.
   * This middleware should be used *after* the authenticate middleware.
   */
  authorize(allowedRoles) {
    return (req, res, next) => {
      //  The authenticate middleware must have already run, so req.user is available.
      if (!req.user) {
        return res.status(401).json({ error: 'User not authenticated' }); // Should not happen if authenticate is used before
      }

      const userRole = req.user.role;

      if (!allowedRoles.includes(userRole)) {
        return res.status(403).json({ error: 'Unauthorized' }); //  403 Forbidden
      }

      next();
    };
  },
};

module.exports = authMiddleware;
