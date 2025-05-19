// backend/controllers/client.controller.js
const { Client } = require('../models/client.model'); // Import the Client model

const clientController = {
  /**
   * Retrieves client data by ID.
   * Requires authentication.
   */
  async getClient(req, res) {
    try {
      const clientId = req.params.id;

      //  Important:  You might want to restrict access to only the logged-in user's client data.
      const client = await Client.findOne({ where: { id: clientId } });
      if (!client) {
        return res.status(404).json({ error: 'Client not found' });
      }

      res.status(200).json({ client });
    } catch (error) {
      console.error('Error getting client:', error);
      res.status(500).json({ error: 'Failed to retrieve client' });
    }
  },

  /**
   * Updates client data.
   * Requires authentication and authorization.  Only the client themselves can update their data.
   */
  async updateClient(req, res) {
    try {
      const clientId = req.params.id;
      const updatedData = req.body;

      //  Important:  Only allow the logged-in client to update their own data.
      //  You'll need to adjust this based on how you associate the Client model
      //  with the User model (e.g., a client_id in the User table, or a one-to-one relationship).
      const client = await Client.findOne({ where: { id: clientId } });
       if (!client) {
        return res.status(404).json({ error: 'Client not found' });
      }

      //  Update the client's data
      await client.update(updatedData);
      const updatedClient = await Client.findOne({where: {id: clientId}});

      res.status(200).json({ message: 'Client updated successfully', client: updatedClient });
    } catch (error) {
      console.error('Error updating client:', error);
      res.status(500).json({ error: 'Failed to update client' });
    }
  },
};

module.exports = clientController;
