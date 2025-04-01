// require("dotenv").config();
const config = require("./controllers/config");
const PORT = config.PORT;

const express = require("express");
const cors = require("cors");
const bodyParser = require("body-parser");

const ordersRouter = require("./routes/orders");
const usersRouter = require("./routes/users");
const authRouter = require("./routes/auth");

const app = express();
//const PORT = process.env.PORT || 5000;

app.use(cors());
app.use(bodyParser.json());

app.use("/api/orders", ordersRouter);
app.use("/api/users", usersRouter);
app.use("/api/auth", authRouter);

app.get("/", (req, res) => {
  res.send("!API is running!");
});

app.listen(PORT, "0.0.0.0", () => {
  console.log(`✅ Server running on port ${PORT}`);
});
