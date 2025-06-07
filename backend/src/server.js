// backend/src/server.js
require('dotenv').config();
const express = require('express');
const http = require('http');
const {Server} = require('socket.io');
const cors = require('cors');
const {db} = require('./config/database.config');
const path = require('path');
const authRoutes = require('./routes/auth.routes');
const userRoutes = require('./routes/user.routes');
const clientRoutes = require('./routes/client.routes');
const specialistRoutes = require('./routes/specialist.routes');
const orderRoutes = require('./routes/order.routes');
const childRoutes = require('./routes/child.routes');
const reviewRoutes = require('./routes/review.routes');
const paymentRoutes = require('./routes/payment.routes');
const infoPanelRoutes = require('./routes/info.routes');
const moneyRoutes = require('./routes/money.routes');
const payApiRoutes = require('./paymentAPI/routes/payment.routes');
const adminRoutes = require('./admin/admin.routes');


const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: { origin: '*', methods: ['GET', 'POST'] }
});

const config = {
  port: process.env.PORT || 5000
};


app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/clients', clientRoutes);
app.use('/api/specialists', specialistRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/children', childRoutes);
app.use('/api/reviews', reviewRoutes);
app.use('/api/payments', paymentRoutes);
app.use('/api/info-panels', infoPanelRoutes);
app.use('/api/money', moneyRoutes);
app.use('/api/payment', payApiRoutes);
app.use('/api/admin', adminRoutes);

const adminStaticPath = path.join(__dirname, '/admin');
console.log('Serving static admin from:', adminStaticPath);

app.use(
  '/admin',
  express.static(adminStaticPath)
);

io.on('connection', socket => {
  console.log(`Socket connected: ${socket.id}`);

  socket.on('message', data => {
    io.emit('message', data);
  });

  socket.on('joinRoom', userId => {
    socket.join(`user:${userId}`);
  });

  socket.on('disconnect', () => {
    console.log(`Socket disconnected: ${socket.id}`);
  });
});

app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ error: 'Internal Server Error' });
});

db.authenticate()
  .then(() => db.sync())
  .then(() => {
    server.listen(config.port, () => {
      console.log(`Server is running on port ${config.port}`);
    });
  })
  .catch(err => {
    console.error('Unable to connect to the database:', err);
  });

module.exports = {app, io};
