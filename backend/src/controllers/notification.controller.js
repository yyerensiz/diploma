// backend/controllers/notification.controller.js
const { firebaseAdmin } = require('../config/firebase.config');
const { io } = require('../server'); // Import the Socket.IO instance from server.js
const { User } = require('../models/user.model'); // Import the User model

const notificationController = {
  /**
   * Sends a notification (push notification via FCM and/or real-time via Socket.IO).
   * Requires authentication and authorization (admin only).
   */
  async sendNotification(req, res) {
    try {
      const { userId, title, body, type, data } = req.body;

      //  1. Send Push Notification (FCM)
      if (userId) {
        //  If a userId is provided, send a targeted notification
        const user = await User.findOne({ where: { id: userId } }); // find the user in your database
        if (!user) {
          return res.status(404).json({ error: 'User not found' });
        }
        const deviceToken = user.fcm_token; //  Assuming you store FCM tokens in your User model
        if (deviceToken) {
          const message = {
            notification: {
              title,
              body,
            },
            data: data || {}, //  Optional data payload
            token: deviceToken,
          };

          try {
            await firebaseAdmin.messaging().send(message);
            console.log('FCM notification sent successfully to user:', userId);
          } catch (fcmError) {
            console.error('Error sending FCM notification:', fcmError);
            //  Don't block the whole operation if FCM fails.  Log the error and continue.
          }
        } else {
          console.warn(`User ${userId} has no FCM token.`);
        }
      } else {
        //if userId is not provided, send to all.
        const message = {
            notification: {
              title,
              body,
            },
        }
         try {
            await firebaseAdmin.messaging().sendToTopic('all', message);
            console.log('FCM notification sent successfully to topic: all');
          } catch (fcmError) {
            console.error('Error sending FCM notification:', fcmError);
          }
      }


      // 2. Send Real-time Notification (Socket.IO)
      //  Send a real-time message to the appropriate user(s) or group.
      //  You'll need to define Socket.IO events in your client-side code to handle these.
      if (type) {
        //  Use a consistent event naming scheme (e.g., 'notification:{type}')
        const eventName = `notification:${type}`;
         if(userId){
             io.to(userId).emit(eventName, { title, body, data }); //sending to a specific socket
         }
         else{
             io.emit(eventName, { title, body, data });  //sending to everyone.
         }


        console.log(`Socket.IO notification sent with event: ${eventName}`);
      }


      res.status(200).json({ message: 'Notification sent successfully' });
    } catch (error) {
      console.error('Error sending notification:', error);
      res.status(500).json({ error: 'Failed to send notification' });
    }
  },
};

module.exports = notificationController;