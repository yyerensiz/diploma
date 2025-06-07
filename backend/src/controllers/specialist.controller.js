// backend/controllers/specialist.controller.js
const fs = require('fs');
const path = require('path');
const { Specialist } = require('../models/specialist.model');
const { Order } = require('../models/order.model');
const { User } = require('../models/user.model');

const specialistController = {
  async getSpecialist(req, res) {
    try {
      const specialist = await Specialist.findOne({
        where: { id: req.params.id }
      });
      if (!specialist) {
        return res.status(404).json({ error: 'Specialist not found' });
      }
      return res.status(200).json({ specialist });
    } catch (error) {
      console.error('Error getting specialist:', error);
      return res.status(500).json({ error: 'Failed to retrieve specialist' });
    }
  },

  async getSpecialistOrders(req, res) {
    try {
      const orders = await Order.findAll({
        where: { specialist_id: req.params.id }
      });
      return res.status(200).json({ orders });
    } catch (error) {
      console.error('Error getting specialist orders:', error);
      return res.status(500).json({ error: 'Failed to retrieve orders' });
    }
  },

  async getSpecialistProfile(req, res) {
    try {
      const profile = await Specialist.findOne({
        where: { user_id: req.user.user_id },
        include: [{ model: User, as: 'user' }]
      });
      if (!profile) {
        return res.status(404).json({ error: 'Specialist profile not found' });
      }
      const { user } = profile;
      const data = {
        id: profile.id,
        bio: profile.bio,
        hourly_rate: profile.hourly_rate,
        rating: profile.rating,
        available_times: profile.available_times,
        verified: profile.verified,
        full_name: user?.full_name,
        email: user?.email,
        phone: user?.phone,
        pfp_url: user?.pfp_url
      };
      return res.status(200).json(data);
    } catch (error) {
      console.error('Error getting specialist profile:', error);
      return res.status(500).json({ error: 'Failed to retrieve specialist profile' });
    }
  },

  async updateSpecialistProfile(req, res) {
    try {
      const userId = req.user.user_id;
      const profile = await Specialist.findOne({ where: { user_id: userId } });
      const user = await User.findByPk(userId);
      if (!profile || !user) {
        return res.status(404).json({ error: 'Specialist or user not found' });
      }

      const updates = req.body;
      if (updates.bio !== undefined) profile.bio = updates.bio;
      if (updates.hourly_rate !== undefined) profile.hourly_rate = updates.hourly_rate;
      if (updates.available_times !== undefined) profile.available_times = updates.available_times;
      if (updates.full_name !== undefined) user.full_name = updates.full_name;
      if (updates.pfp_url !== undefined) user.pfp_url = updates.pfp_url;
      if (updates.phone !== undefined) user.phone = updates.phone;

      await profile.save();
      await user.save();

      const updated = await Specialist.findOne({
        where: { user_id: userId },
        include: [{ model: User, as: 'user' }]
      });
      const { user: usr } = updated;
      const response = {
        id: updated.id,
        bio: updated.bio,
        hourly_rate: updated.hourly_rate,
        rating: updated.rating,
        available_times: updated.available_times,
        verified: updated.verified,
        full_name: usr?.full_name,
        email: usr?.email,
        phone: usr?.phone,
        pfp_url: usr?.pfp_url,
        message: 'Profile updated'
      };
      return res.status(200).json(response);
    } catch (error) {
      console.error('Error updating specialist profile:', error);
      return res.status(500).json({ error: 'Failed to update specialist profile' });
    }
  },

  async getAllSpecialists(req, res) {
    try {
      const specialists = await Specialist.findAll({
        include: [{ model: User, as: 'user' }]
      });
      const list = specialists.map(s => {
        const u = s.user || {};
        return {
          id: s.id,
          full_name: u.full_name || 'Unknown',
          rating: parseFloat(s.rating) || 0,
          description: s.bio || '',
          hourly_rate: s.hourly_rate != null ? parseFloat(s.hourly_rate) : null,
          available_times: s.available_times || null,
          verified: Boolean(s.verified),
          phone: u.phone || null,
          pfp_url: u.pfp_url || null
        };
      });
      return res.status(200).json(list);
    } catch (error) {
      console.error('Error fetching all specialists:', error);
      return res.status(500).json({ error: 'Failed to retrieve specialists' });
    }
  },

  uploadVerificationDocs: async (req, res) => {
    try {
      const userId = req.user.user_id;
      const idDoc = req.files.id_document?.[0];
      const certDoc = req.files.certificate?.[0];
      if (!idDoc || !certDoc) {
        return res.status(400).json({ error: 'Both documents are required' });
      }

      const dir = path.join(__dirname, '..', 'uploads', 'verification');
      if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });

      const save = file =>
        path.join(dir, `${userId}_${file.fieldname}_${Date.now()}${path.extname(file.originalname)}`);
      const idPath = save(idDoc);
      const certPath = save(certDoc);

      fs.renameSync(idDoc.path, idPath);
      fs.renameSync(certDoc.path, certPath);

      console.log(`Verification documents received for user ${userId}`);
      return res.status(200).json({ message: 'Documents uploaded successfully' });
    } catch (error) {
      console.error('Error uploading verification documents:', error);
      return res.status(500).json({ error: 'Failed to upload documents' });
    }
  }
};

module.exports = specialistController;
