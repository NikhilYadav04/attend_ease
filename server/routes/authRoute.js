const express = require("express");
const { identify } = require("../controllers/authController");
const { requireFields } = require("../middleware/validate");

const authRouter = express.Router();

authRouter.post("/identify", requireFields("phone", "otpToken"), identify);

module.exports = authRouter;
