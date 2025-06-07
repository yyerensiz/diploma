// backend/middleware/auth.middleware.js
const {firebaseAdmin} = require('../config/firebase.config');
const {User} = require('../models/user.model');

const authMiddleware = {
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

      const decodedToken = await firebaseAdmin.auth().verifyIdToken(token);
      const user = await User.findOne({ where: { firebase_uid: decodedToken.uid } });
      if (!user) {
        return res.status(404).json({ error: 'User not found in database' });
      }

      req.user = user;
      next();
    } catch (error) {
      console.error('Authentication error:', error);
      return res.status(401).json({ error: 'Invalid token' }); 
    }
  },

  authorize(allowedRoles) {
    return (req, res, next) => {
      if (!req.user) {
        return res.status(401).json({ error: 'User not authenticated' }); 
      }

      const userRole = req.user.role;

      if (!allowedRoles.includes(userRole)) {
        return res.status(403).json({ error: 'Unauthorized' }); 
      }
      next();
    };
  },
};

module.exports = authMiddleware;
