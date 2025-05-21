//backend\src\controllers\info.controller.js
const { InfoPanel } = require('../models/info.model');

const infoPanelController = {
  async getAll(req, res) {
    try {
      const panels = await InfoPanel.findAll({ order: [['id', 'ASC']] });
      res.status(200).json({ panels });
    } catch (error) {
      res.status(500).json({ error: 'Failed to load info panels' });
    }
  },
  // Optionally: add, update, delete for admin
};
module.exports = infoPanelController;
