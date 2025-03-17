const { Pool } = require("pg");
const dotenv = require("dotenv");
const path = require("path");

dotenv.config({ path: path.resolve(__dirname, "../../.env") });

console.log("Connecting to PostgreSQL with:");
console.log("DB_USER:", process.env.DB_USER);
console.log("DB_HOST:", process.env.DB_HOST);
console.log("DB_NAME:", process.env.DB_NAME);
console.log("DB_PORT:", process.env.DB_PORT);

const dbPassword = process.env.DB_PASSWORD ? String(process.env.DB_PASSWORD) : "";

const pool = new Pool({
  user: process.env.DB_USER || "postgres",
  password: dbPassword,
  host: process.env.DB_HOST || "localhost",
  port: process.env.DB_PORT ? parseInt(process.env.DB_PORT, 10) : 5432,
  database: process.env.DB_NAME || "carenest",
  ssl: false,
});

pool.connect()
  .then(() => console.log("✅ Successfully connected to PostgreSQL"))
  .catch((err) => console.error("❌ Database connection error:", err.message));

module.exports = pool;
