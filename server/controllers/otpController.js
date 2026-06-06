const otpGenerator = require("otp-generator");
const OtpModel = require("../models/otp");

const sendOtp = async (req, res) => {
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

    // Twilio commented out for testing — returns OTP in message field
    // await twilioClient.messages.create({ body: `Your OTP is: ${otp}`, to: phoneNumber, from: twilioNumber });

    return res.status(200).json({ success: true, message: otp });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

const verifyOtp = async (req, res) => {
  try {
    const { otp } = req.body;
    const otpFound = await OtpModel.findOne({ otp });

    if (!otpFound) {
      return res.status(400).json({ success: false, message: "OTP Not Verified" });
    }

    return res.status(200).json({ success: true, message: "OTP Verified Successfully" });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

module.exports = { sendOtp, verifyOtp };
