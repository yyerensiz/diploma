const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const { Server } = require('socket.io');
const http = require('http');
require('dotenv').config(); // Load environment variables from .env file
const { db } = require('./config/database.config'); // Import database connection
const authRoutes = require('./routes/auth.routes'); // Import your route files
const userRoutes = require('./routes/user.routes');
const clientRoutes = require('./routes/client.routes');
const specialistRoutes = require('./routes/specialist.routes');
const orderRoutes = require('./routes/order.routes');
const childRoutes = require('./routes/child.routes');
const reviewRoutes = require('./routes/review.routes');
const paymentRoutes = require('./routes/payment.routes');
const notificationRoutes = require('./routes/notification.routes');
const infoPanelRoutes = require('./routes/info.routes');

// Create an Express application
const app = express();
const server = http.createServer(app); // Create an HTTP server
const io = new Server(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST'],
  },
}); // Initialize Socket.IO

// Middleware
app.use(cors()); // Enable Cross-Origin Resource Sharing
app.use(bodyParser.json()); // Parse JSON request bodies
app.use(bodyParser.urlencoded({ extended: true })); // Parse URL-encoded request bodies

// --- Configuration ---
const config = {
  port: process.env.PORT || 5000,
  //  Add other configurations like:
  //   db: {
  //    host: 'your_db_host',
  //    user: 'your_db_user',
  //    password: 'your_db_password',
  //    database: 'your_db_name',
  //   },
  //   firebase: {
  //    apiKey: 'YOUR_FIREBASE_API_KEY',
  //    authDomain: 'YOUR_FIREBASE_AUTH_DOMAIN',
  //    projectId: 'YOUR_FIREBASE_PROJECT_ID',
  //    // ...
  //   }
};

// --- Routes ---
//  Define your routes here.  For example:
app.use('/api/auth', authRoutes); // Mount the auth routes
app.use('/api/users', userRoutes); // Mount user routes
app.use('/api/clients', clientRoutes);
app.use('/api/specialists', specialistRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/children', childRoutes);
app.use('/api/reviews', reviewRoutes);
app.use('/api/payments', paymentRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/info-panels', infoPanelRoutes);

// --- Socket.IO ---
//  Handle Socket.IO connections and events here.
io.on('connection', (socket) => {
  console.log(`Socket connected: ${socket.id}`);

  //  Example: Listen for a custom event from the client
  socket.on('message', (data) => {
    console.log('Received message:', data);
    //  Broadcast the message to all connected clients
    io.emit('message', data);
  });

  // Join a user-specific room (optional, for targeted notifications)
  socket.on('joinRoom', (userId) => {
    socket.join(`user:${userId}`);
    console.log(`Socket ${socket.id} joined room user:${userId}`);
  });

  socket.on('disconnect', () => {
    console.log(`Socket disconnected: ${socket.id}`);
  });
});

// --- Error Handling ---
//  Error handling middleware (optional, but recommended)
app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ error: 'Internal Server Error' });
});

// --- Start the server ---
db.authenticate() //connect to DB before starting server
  .then(() => {
    console.log('Connection to the database has been established successfully.');
    // return db.sync({ force: true }); //  Use force: true only during development to reset the database
    return db.sync();
  })
  .then(() => {
    console.log('Database models synced');
    // Start the server
    server.listen(config.port, () => { // Use server.listen, not app.listen
      console.log(`Server is running on port ${config.port}`);
    });
  })
  .catch((err) => {
    console.error('Unable to connect to the database:', err);
  });

//  Export the app and io if needed for testing or other modules.  For example:
module.exports = { app, io };
