// backend/services/user.service.js
const {User} = require('../models/user.model');

const userService = {
  async getUserById(userId) {
    try {
      return await User.findOne({ where: { id: userId } });
    } catch (error) {
      console.error('Error retrieving user by ID:', error);
      throw error;
    }
  },

  async getUserByFirebaseUid(firebaseUid) {
    try {
      return await User.findOne({ where: { firebase_uid: firebaseUid } });
    } catch (error) {
      console.error('Error retrieving user by Firebase UID:', error);
      throw error;
    }
  },

  async updateUserProfile(userId, updatedData) {
    try {
      const user = await User.findOne({ where: { id: userId } });
      if (!user) {
        throw new Error(`User not found: ${userId}`);
      }
      await user.update(updatedData);
      return await User.findOne({ where: { id: userId } });
    } catch (error) {
      console.error('Error updating user profile:', error);
      throw error;
    }
  },

  async deleteUser(userId) {
    try {
      return await User.destroy({ where: { id: userId } });
    } catch (error) {
      console.error('Error deleting user:', error);
      throw error;
    }
  }
};

module.exports = userService;
