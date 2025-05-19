// backend/config/database.config.js
require('dotenv').config();

const { Sequelize } = require('sequelize');

const db = new Sequelize(
  process.env.DB_NAME || 'carenestdb',
  process.env.DB_USER || 'postgres',
  process.env.DB_PASSWORD || 'kiyotakaa24',
  {
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 5432,
    dialect: 'postgres',
    logging: console.log, // or false to disable
  }
);

// Test the database connection
async function testConnection() {
  try {
    await db.authenticate();
    console.log('Database connection has been established successfully.');
  } catch (error) {
    console.error('Unable to connect to the database:', error);
  }
}

testConnection();

module.exports = { db };
