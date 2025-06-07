// backend/controllers/client.controller.js
const { Client } = require('../models/client.model');

const clientController = {
  async getClient(req, res) {
    try {
      const client = await Client.findOne({ where: { id: req.params.id } });
      if (!client) {
        return res.status(404).json({ error: 'Client not found' });
      }
      res.status(200).json({ client });
    } catch (error) {
      console.error('Error getting client:', error);
      res.status(500).json({ error: 'Failed to retrieve client' });
    }
  },

  async updateClient(req, res) {
    try {
      const client = await Client.findOne({ where: { id: req.params.id } });
      if (!client) {
        return res.status(404).json({ error: 'Client not found' });
      }
      await client.update(req.body);
      const updatedClient = await Client.findOne({ where: { id: req.params.id } });
      res.status(200).json({ message: 'Client updated successfully', client: updatedClient });
    } catch (error) {
      console.error('Error updating client:', error);
      res.status(500).json({ error: 'Failed to update client' });
    }
  }
};

module.exports = clientController;
