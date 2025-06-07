// backend/controllers/child.controller.js
const { Child } = require('../models/child.model');

const childController = {
  async getChild(req, res) {
    try {
      const childId = req.params.id;
      const child = await Child.findOne({ where: { id: childId } });
      if (!child) {
        return res.status(404).json({ error: 'Child not found' });
      }
      res.status(200).json({ child });
    } catch (error) {
      console.error('Error getting child:', error);
      res.status(500).json({ error: 'Failed to retrieve child' });
    }
  },

  async getChildren(req, res) {
    try {
      const clientId = req.user.user_id;
      console.log('Resolved user ID:', clientId);
      console.log('Request body:', req.body);
      const children = await Child.findAll({ where: { client_id: clientId } });
      console.log('Children:', children);
      res.status(200).json({ children });
    } catch (error) {
      console.error('Error getting children:', error);
      res.status(500).json({ error: 'Failed to retrieve children' });
    }
  },

  async createChild(req, res) {
    try {
      const { name, date_of_birth, bio } = req.body;
      const userId = req.user.user_id;
      console.log('Resolved user ID:', userId);
      console.log('Request body:', req.body);

      if (req.user.role !== 'client') {
        return res.status(403).json({ error: 'Only clients can create children' });
      }

      const child = await Child.create({
        full_name: name,
        birth_date: date_of_birth,
        bio,
        client_id: userId
      });

      res.status(201).json({ message: 'Child created successfully', child });
    } catch (error) {
      console.error('Error creating child:', error);
      res.status(500).json({ error: 'Failed to create child' });
    }
  },

  async updateChild(req, res) {
    try {
      const childId = req.params.id;
      const { full_name, birth_date, bio, pfp_url } = req.body;
      const clientId = req.user.user_id;

      const child = await Child.findOne({ where: { id: childId, client_id: clientId } });
      if (!child) {
        return res.status(404).json({ error: 'Child not found or unauthorized' });
      }

      const updatedFields = {};
      if (full_name !== undefined) updatedFields.full_name = full_name;
      if (birth_date !== undefined) updatedFields.birth_date = birth_date;
      if (bio !== undefined) updatedFields.bio = bio;
      if (pfp_url !== undefined) updatedFields.pfp_url = pfp_url;

      await child.update(updatedFields);
      const updatedChild = await Child.findOne({ where: { id: childId } });

      console.log('UPDATE request received:', req.body);
      res.status(200).json({ message: 'Child updated successfully', child: updatedChild });
    } catch (error) {
      console.error('Error updating child:', error);
      res.status(500).json({ error: 'Failed to update child' });
    }
  },

  async deleteChild(req, res) {
    try {
      const childId = req.params.id;
      const clientId = req.user.user_id;
      const child = await Child.findOne({ where: { id: childId, client_id: clientId } });
      if (!child) {
        return res.status(404).json({ error: 'Child not found or unauthorized' });
      }

      await child.destroy();
      res.status(200).json({ message: 'Child deleted successfully' });
    } catch (error) {
      console.error('Error deleting child:', error);
      res.status(500).json({ error: 'Failed to delete child' });
    }
  }
};

module.exports = childController;
