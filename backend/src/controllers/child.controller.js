// backend/controllers/child.controller.js
const { Child } = require('../models/child.model'); // Import the Child model
const { Client } = require('../models/client.model'); // or adjust path if needed

const childController = {
  /**
   * Retrieves a child's details by ID.
   * Requires authentication.
   */
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
    const clientId = req.user.user_id; // authenticated user's client id
    const children = await Child.findAll({ where: { client_id: clientId } });
    console.log("Resolved user ID:", clientId);
    console.log('Request body:', req.body);
    console.log('Children:', children);
    res.status(200).json({ children });
  } catch (error) {
    console.error('Error getting children:', error);
    res.status(500).json({ error: 'Failed to retrieve children' });
  }
},

  /**
   * Creates a new child for a client.
   * Requires authentication and authorization (client only).
   */
  async createChild(req, res) {
  try {
    const { name, date_of_birth, bio } = req.body;
    const userId = req.user?.user_id;

    console.log("Resolved user ID:", userId);
    console.log('Request body:', req.body);

    // Optional: Check user role is client
    if (req.user.role !== 'client') {
      return res.status(403).json({ error: 'Only clients can create children' });
    }

    const child = await Child.create({
      full_name: name,
      birth_date: date_of_birth,
      bio: bio,
      client_id: userId, // or client_id if that's how your table is named
    });

    res.status(201).json({ message: 'Child created successfully', child });
  } catch (error) {
    console.error('Error creating child:', error);
    res.status(500).json({ error: 'Failed to create child' });
  }
},
// backend/controllers/child.controller.js



  /**
   * Updates a child's details.
   * Requires authentication and authorization (client only).
   * Only the parent client can update their child's information.
   */
  async updateChild(req, res) {
  try {
    const childId = req.params.id;
    const { full_name, birth_date, bio, pfp_url } = req.body; // ✅ Match what frontend sends
    const clientId = req.user.user_id;

    const child = await Child.findOne({ where: { id: childId, client_id: clientId } });
    if (!child) {
      return res.status(404).json({ error: 'Child not found or unauthorized' });
    }

    // ✅ Apply only fields that are not undefined
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

  /**
   * Deletes a child.
   * Requires authentication and authorization (client only).
   * Only the parent client can delete their child.
   */
  async deleteChild(req, res) {
    try {
      const childId = req.params.id;
      const clientId = req.user.user_id; // Get client ID from the authenticated user

      const child = await Child.findOne({ where: { id: childId, client_id: clientId } }); //check client_id
      if (!child) {
        return res.status(404).json({ error: 'Child not found or unauthorized' });
      }

      await child.destroy();
      res.status(200).json({ message: 'Child deleted successfully' });
    } catch (error) {
      console.error('Error deleting child:', error);
      res.status(500).json({ error: 'Failed to delete child' });
    }
  },
};

module.exports = childController;
