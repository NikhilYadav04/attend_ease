require("dotenv").config();

const express = require("express");
const router = express.Router();

const otpGenerator = require("otp-generator");
const twilio = require("twilio");
const OtpModel = require("../models/otp");

const accountSid = process.env.TWILIO_ACCOUNT_SID;
const accountToken = process.env.TWILIO_ACCOUNT_TOKEN;
const twilioNumber = process.env.TWILIO_PHONE_NUMBER;

router.use(express.json());
const twilioClient = new twilio(accountSid, accountToken);

// send otp
router.post("/send-otp", async (req, res) => {
  try {
    const { phoneNumber } = req.body;

    const otp = otpGenerator.generate(6, {
      upperCaseAlphabets: false,
      lowerCaseAlphabets: false,
      specialChars: false,
    });

    await OtpModel.findOneAndUpdate(
      { phoneNumber },
      { otp },
      { upsert: true, new: true, setDefaultsOnInsert: true }
    );

    // await twilioClient.messages.create({
    //   body: `Your Otp is : ${otp}`,
    //   to: phoneNumber,
    //   from: twilioNumber,
    // });

    return res.status(200).json({
      success: true,
      message: otp,
    });
  } catch (e) {
    return res.status(500).json({
      success: false,
      message: e.message,
    });
  }
});

//verify otp
router.post("/verify-otp", async (req, res) => {
  try {
    const { otp } = req.body;
    console.log(otp);
    const otpFOund = await OtpModel.findOne({ otp });

    if (!otpFOund) {
      return res.status(400).json({
        success: false,
        message: "OTP Not Verified",
      });
    }

    return res.status(200).json({
      success: true,
      message: "OTP Verified Successfully",
    });
  } catch (e) {
    return res.status(500).json({
      success: false,
      message: e.message,
    });
  }
});

module.exports = router;
