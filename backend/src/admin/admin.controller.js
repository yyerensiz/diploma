// backend/src/admin/admin.controller.js

const { User } = require('../models/user.model');
const { Specialist } = require('../models/specialist.model');
const { Subsidy } = require('../models/subsidy.model');

const adminController = {
  async listUsers(req, res) {
    try {
      const users = await User.findAll({
        attributes: [
          'user_id',
          'firebase_uid',
          'email',
          'full_name',
          'phone',
          'role',
          'pfp_url',
          'created_at',
          'address'
        ],
        include: [
          {
            model: Specialist,
            as: 'specialistProfile',
            attributes: ['id', 'verified']
          }
        ],
        order: [['created_at', 'DESC']],
      });

      const plainUsers = users.map((u) => u.get({ plain: true }));

      await Promise.all(
        plainUsers.map(async (user) => {
          if (user.role === 'client') {
            const subsidyRow = await Subsidy.findOne({
              where: { client_id: user.user_id }
            });
            if (subsidyRow) {
              user.subsidy = subsidyRow.percentage;
              user.subsidy_active = subsidyRow.active;
            } else {
              user.subsidy = null;
              user.subsidy_active = false;
            }
          } else {
            user.subsidy = null;
            user.subsidy_active = false;
          }
        })
      );

      return res.status(200).json({ users: plainUsers });
    } catch (error) {
      console.error('adminController.listUsers error:', error);
      return res.status(500).json({
        error: 'Failed to list users',
        message: error.message
      });
    }
  },

  async updateUser(req, res) {
    try {
      const userId = parseInt(req.params.id, 10);
      const updates = req.body;

      const user = await User.findByPk(userId, {
        include: [{ model: Specialist, as: 'specialistProfile' }]
      });
      if (!user) {
        return res.status(404).json({ error: 'User not found' });
      }

      if (user.role === 'specialist' && typeof updates.verified !== 'undefined') {
        const spec = user.specialistProfile;
        if (!spec) {
          return res.status(404).json({ error: 'Specialist profile not found' });
        }
        spec.verified = updates.verified;
        await spec.save();
      }

      if (user.role === 'client' &&
          (typeof updates.subsidy !== 'undefined' ||
           typeof updates.active !== 'undefined')) {
        const newPercentage =
          typeof updates.subsidy !== 'undefined'
            ? parseFloat(updates.subsidy) || 0
            : undefined;
        const newActive =
          typeof updates.active !== 'undefined'
            ? Boolean(updates.active)
            : undefined;

        const existing = await Subsidy.findOne({
          where: { client_id: userId }
        });

        if (existing) {
          if (typeof newPercentage !== 'undefined') {
            existing.percentage = newPercentage;
          }
          if (typeof newActive !== 'undefined') {
            existing.active = newActive;
          }
          await existing.save();
        } else {
          await Subsidy.create({
            client_id: userId,
            percentage: newPercentage != null ? newPercentage : 0,
            active: newActive != null ? newActive : true
          });
        }
      }

      const allowedFields = ['full_name', 'phone', 'email'];
      for (let f of allowedFields) {
        if (typeof updates[f] !== 'undefined') {
          user[f] = updates[f];
        }
      }
      await user.save();

      const updatedUser = await User.findByPk(userId, {
        include: [{ model: Specialist, as: 'specialistProfile' }]
      });

      let subsidyVal = null;
      let subsidyActive = false;
      if (updatedUser.role === 'client') {
        const subsidyRow = await Subsidy.findOne({
          where: { client_id: userId }
        });
        if (subsidyRow) {
          subsidyVal = subsidyRow.percentage;
          subsidyActive = subsidyRow.active;
        }
      }

      const result = updatedUser.get({ plain: true });
      result.subsidy = subsidyVal;
      result.subsidy_active = subsidyActive;

      return res.status(200).json({ user: result });
    } catch (error) {
      console.error('adminController.updateUser error:', error);
      return res.status(500).json({
        error: 'Failed to update user',
        message: error.message
      });
    }
  }
};

module.exports = adminController;
