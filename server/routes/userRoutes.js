const express = require("express");
const { requireFields } = require("../middleware/validate");
const { sendOtp, verifyOtp } = require("../controllers/otpController");

const router = express.Router();

router.post("/send-otp",   requireFields("phoneNumber"), sendOtp);
router.post("/verify-otp", requireFields("otp"), verifyOtp);

module.exports = router;
