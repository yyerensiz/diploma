const { Specialist } = require('../models/specialist.model'); // Import the Specialist model
const { Order } = require('../models/order.model');         // Import the Order model
const { User } = require('../models/user.model');           // <---- IMPORT THE USER MODEL

const specialistController = {
  /**
   * Retrieves specialist data by ID.
   * Requires authentication.
   */
  async getSpecialist(req, res) {
    try {
      const specialistId = req.params.id;
      const specialist = await Specialist.findOne({ where: { id: specialistId } });
      if (!specialist) {
        return res.status(404).json({ error: 'Specialist not found' });
      }
      res.status(200).json({ specialist });
    } catch (error) {
      console.error('Error getting specialist:', error);
      res.status(500).json({ error: 'Failed to retrieve specialist' });
    }
  },

  /**
   * Retrieves orders for a specialist.
   * Requires authentication and authorization.  Only the specialist can view their orders.
   */
  async getSpecialistOrders(req, res) {
    try {
      const specialistId = req.params.id;

      //  Important:  Verify that the logged-in specialist is the one requesting their orders.
      //  You might have the specialist ID stored in req.user after the authentication middleware.
      const orders = await Order.findAll({ where: { specialist_id: specialistId } }); //  Corrected to specialist_id
      res.status(200).json({ orders });
    } catch (error) {
      console.error('Error getting specialist orders:', error);
      res.status(500).json({ error: 'Failed to retrieve orders' });
    }
  },

  async getSpecialistProfile(req, res) {
  console.log('req.user:', req.user);
  console.log('req.user.id:', req.user?.id);
  try {
    const userId = req.user.user_id; // Assuming req.user is populated by authMiddleware
    const specialistProfile = await Specialist.findOne({
      where: { user_id: userId },
      include: [{ model: User, as: 'user' }], // Include user data
    });

    if (!specialistProfile) {
      return res.status(404).json({ error: 'Specialist profile not found' });
    }

    // Structure the response to include relevant user data
    const profileData = {
      id: specialistProfile.id,
      bio: specialistProfile.bio,
      hourly_rate: specialistProfile.hourly_rate,
      rating: specialistProfile.rating,
      available_times: specialistProfile.available_times,
      verified: specialistProfile.verified,
      full_name: specialistProfile.user?.full_name,
      email: specialistProfile.user?.email,
      phone: specialistProfile.user?.phone, // Include phone
      pfp_url: specialistProfile.user?.pfp_url,
      // Add other relevant fields
    };

    res.status(200).json(profileData);
  } catch (error) {
    console.error('Error getting specialist profile:', error);
    res.status(500).json({ error: 'Failed to retrieve specialist profile' });
  }
},

  /**
   * Updates the profile of the logged-in specialist.
   * Allows updating fields in both the specialists and users tables.
   * Requires authentication and authorization.
   */
  async updateSpecialistProfile(req, res) {
  try {
    const userId = req.user.user_id; // Use req.user.user_id
    const updatedData = req.body;

    const specialistProfile = await Specialist.findOne({ where: { user_id: userId } });
    if (!specialistProfile) {
      return res.status(404).json({ error: 'Specialist profile not found' });
    }

    const user = await User.findByPk(userId);
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Update specialist-specific fields
    if (updatedData.bio !== undefined) specialistProfile.bio = updatedData.bio;
    if (updatedData.hourly_rate !== undefined) specialistProfile.hourly_rate = updatedData.hourly_rate;
    if (updatedData.available_times !== undefined) specialistProfile.available_times = updatedData.available_times;
    // Add other specialist fields you want to update

    // Update user-related fields
    if (updatedData.full_name !== undefined) user.full_name = updatedData.full_name;
    if (updatedData.pfp_url !== undefined) user.pfp_url = updatedData.pfp_url;
    if (updatedData.phone !== undefined) user.phone = updatedData.phone; // Allow updating phone
    // Add other user fields you want to update

    await specialistProfile.save();
    await user.save();

    // Fetch the updated profile to send back
    const updatedProfile = await Specialist.findOne({
      where: { user_id: userId }, // Use req.user.user_id here as well
      include: [{ model: User, as: 'user' }],
    });

    const responseData = {
      id: updatedProfile.id,
      bio: updatedProfile.bio,
      hourly_rate: updatedProfile.hourly_rate,
      rating: updatedProfile.rating,
      available_times: updatedProfile.available_times,
      verified: updatedProfile.verified,
      full_name: updatedProfile.user?.full_name,
      email: updatedProfile.user?.email,
      phone: updatedProfile.user?.phone,
      pfp_url: updatedProfile.user?.pfp_url,
      message: 'Профиль обновлён',
    };

    res.status(200).json(responseData);
  } catch (error) {
    console.error('Error updating specialist profile:', error);
    res.status(500).json({ error: 'Failed to update specialist profile' });
  }
},
async getAllSpecialists(req, res) {
  try {
    const specialists = await Specialist.findAll({
      include: [{ model: User, as: 'user' }],
    });

    const formattedSpecialists = specialists.map(specialist => ({
      id: specialist.id,
      name: specialist.user ? specialist.user.full_name : 'Unknown',
      rating: specialist.rating ? parseFloat(specialist.rating) : 0,
      description: specialist.bio || '',
      hourly_rate: specialist.hourly_rate ? parseFloat(specialist.hourly_rate) : null,
      available_times: specialist.available_times || null,
      verified: specialist.verified === true || specialist.verified === 'true',
      phone: specialist.user ? specialist.user.phone : null,
      pfp_url: specialist.user ? specialist.user.pfp_url : null,
      // Add other relevant fields as needed
    }));

    res.status(200).json(formattedSpecialists);
  } catch (error) {
    console.error('Error fetching all specialists:', error);
    res.status(500).json({ error: 'Failed to retrieve specialists' });
  }
},

};

const path = require('path');
const fs = require('fs');

specialistController.uploadVerificationDocs = async (req, res) => {
  try {
    const userId = req.user.user_id; // Populated by authMiddleware

    // Validate files
    const idDoc = req.files['id_document']?.[0];
    const certDoc = req.files['certificate']?.[0];
    if (!idDoc || !certDoc) {
      return res.status(400).json({ error: 'Both documents are required' });
    }

    // Prepare uploads directory
    const uploadsDir = path.join(__dirname, '..', 'uploads', 'verification');
    if (!fs.existsSync(uploadsDir)) fs.mkdirSync(uploadsDir, { recursive: true });

    // Move files and create unique names
    const savePath = (file) =>
      path.join(
        uploadsDir,
        `${userId}_${file.fieldname}_${Date.now()}${path.extname(file.originalname)}`
      );
    const idDocPath = savePath(idDoc);
    const certDocPath = savePath(certDoc);

    fs.renameSync(idDoc.path, idDocPath);
    fs.renameSync(certDoc.path, certDocPath);

    // Optionally: Save file paths to the DB for admin review (not required, but recommended)
    // await Specialist.update(
    //   { id_document_path: idDocPath, certificate_path: certDocPath },
    //   { where: { user_id: userId } }
    // );

    console.log(`Verification documents received for user ${userId}`);

    res.status(200).json({ message: 'Documents uploaded successfully' });
  } catch (error) {
    console.error('Error uploading verification documents:', error);
    res.status(500).json({ error: 'Failed to upload documents' });
  }
};


module.exports = specialistController;