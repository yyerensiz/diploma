// backend/controllers/user.controller.js
const { User } = require('../models/user.model'); // Import the User model

const userController = {
  /**
   * Retrieves a user's profile by ID.
   * Requires authentication.
   */
  async getUser(req, res) {
    try {
      const userId = req.params.id;

      //  Important:  You might want to restrict access to only the logged-in user's profile,
      //  or only allow admins to view other profiles.  The current code allows any authenticated user to view any user.
      const user = await User.findOne({ where: { id: userId } });  //  Find by id, not firebase_uid
      if (!user) {
        return res.status(404).json({ error: 'User not found' });
      }
      // Potential improvement inside getUser
      if (req.user.id !== parseInt(req.params.id) && !req.user.isAdmin) {
        return res.status(403).json({ error: 'Unauthorized to view this profile' });
      }


      res.status(200).json({ user });
    } catch (error) {
      console.error('Error getting user:', error);
      res.status(500).json({ error: 'Failed to retrieve user' });
    }
  },

  /**
   * Updates a user's profile.
   * Requires authentication and authorization.  Only the user themselves can update their profile.
   */
 // Use firebase_uid instead of id for route params:
async updateUser(req, res) {
  try {
    const firebaseUid = req.params.id; // rename param for clarity

    if (req.user.firebase_uid !== firebaseUid && !req.user.isAdmin) {
      return res.status(403).json({ error: 'Unauthorized to update this profile' });
    }

    const [updated] = await User.update(req.body, {
      where: { firebase_uid: firebaseUid },
    });

    if (!updated) {
      return res.status(404).json({ error: 'User not found or not updated' });
    }

    const updatedUser = await User.findOne({ where: { firebase_uid: firebaseUid } });
    res.status(200).json({ user: updatedUser });

  } catch (error) {
    console.error('Error updating user:', error);
    res.status(500).json({ error: 'Failed to update user' });
  }
},
};

module.exports = userController;
