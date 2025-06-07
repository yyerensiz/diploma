// backend/controllers/user.controller.js
const { User } = require('../models/user.model');

const userController = {
  async getUser(req, res) {
    try {
      const userId = parseInt(req.params.id, 10);
      if (req.user.id !== userId && !req.user.isAdmin) {
        return res.status(403).json({ error: 'Unauthorized to view this profile' });
      }
      const user = await User.findOne({ where: { id: userId } });
      if (!user) {
        return res.status(404).json({ error: 'User not found' });
      }
      res.status(200).json({ user });
    } catch (error) {
      console.error('Error getting user:', error);
      res.status(500).json({ error: 'Failed to retrieve user' });
    }
  },

  async updateUser(req, res) {
    try {
      const firebaseUid = req.params.id;
      if (req.user.firebase_uid !== firebaseUid && !req.user.isAdmin) {
        return res.status(403).json({ error: 'Unauthorized to update this profile' });
      }
      const [updatedCount] = await User.update(req.body, {
        where: { firebase_uid: firebaseUid }
      });
      if (!updatedCount) {
        return res.status(404).json({ error: 'User not found or not updated' });
      }
      const updatedUser = await User.findOne({ where: { firebase_uid: firebaseUid } });
      res.status(200).json({ user: updatedUser });
    } catch (error) {
      console.error('Error updating user:', error);
      res.status(500).json({ error: 'Failed to update user' });
    }
  }
};

module.exports = userController;
