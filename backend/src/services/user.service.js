// backend/services/user.service.js
const { User } = require('../models/user.model'); // Import the User model

const userService = {
  /**
   * Retrieves a user by their ID.
   * @param userId - The ID of the user to retrieve.
   * @returns - The user object, or null if not found.
   */
  async getUserById(userId) {
    try {
      const user = await User.findOne({ where: { id: userId } });
      return user;
    } catch (error) {
      console.error('Error retrieving user by ID:', error);
      throw error; // Re-throw the error so it can be handled by the caller
    }
  },

  /**
   * Retrieves a user by their Firebase UID.
   * @param firebaseUid - The Firebase UID of the user to retrieve.
   * @returns - The user object, or null if not found.
   */
  async getUserByFirebaseUid(firebaseUid) {
    try {
      const user = await User.findOne({ where: { firebase_uid: firebaseUid } });
      return user;
    } catch (error) {
      console.error('Error retrieving user by Firebase UID:', error);
      throw error;
    }
  },

  /**
   * Updates a user's profile information.
   * @param userId - The ID of the user to update.
   * @param updatedData - An object containing the fields to update (e.g., { firstName: 'John', lastName: 'Doe' }).
   * @returns - The updated user object.
   */
  async updateUserProfile(userId, updatedData) {
    try {
      const user = await User.findOne({ where: { id: userId } });
      if (!user) {
        throw new Error(`User not found: ${userId}`);
      }

      await user.update(updatedData);
      const updatedUser = await User.findOne({ where: { id: userId } }); //avoid stale data
      return updatedUser;
    } catch (error) {
      console.error('Error updating user profile:', error);
      throw error;
    }
  },

  /**
    * Deletes a user by their ID.
    * @param userId - The ID of the user to delete.
    * @returns -  Number of rows deleted (1 for success, 0 for failure).
    */
  async deleteUser(userId) {
      try{
          const deletedRows = await User.destroy({
              where: {id: userId}
          });
          return deletedRows;

      } catch(error){
        console.error("Error deleting user:", error);
        throw error;
      }
  }
};

module.exports = userService;
