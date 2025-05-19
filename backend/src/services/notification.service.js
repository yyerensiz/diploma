// backend/services/notification.service.js
const { firebaseAdmin } = require('../config/firebase.config');
const { User } = require('../models/user.model'); // Import the User model

const notificationService = {
  /**
   * Sends a push notification to a user's device via FCM.
   * @param userId - The ID of the user to send the notification to.
   * @param title - The title of the notification.
   * @param body - The body of the notification.
   * @param data -  Optional data payload to send with the notification.
   */
  async sendPushNotification(userId, title, body, data = {}) {
    try {
      const user = await User.findOne({ where: { id: userId } });
      if (!user) {
        throw new Error(`User not found: ${userId}`);
      }

      const deviceToken = user.fcm_token; //  Assuming you store FCM tokens in your User model
      if (!deviceToken) {
        console.warn(`User ${userId} has no FCM token.`);
        return; //  Don't throw an error, just log and return
      }

      const message = {
        notification: {
          title,
          body,
        },
        data, //  Optional data payload
        token: deviceToken,
      };

      const response = await firebaseAdmin.messaging().send(message);
      console.log('FCM notification sent successfully:', response);
      return response;
    } catch (error) {
      console.error('Error sending push notification:', error);
      throw error; //  Re-throw the error for the caller to handle
    }
  },
};

module.exports = notificationService;
