const jwt = require("jsonwebtoken");
const otpGenerator = require("otp-generator");
const prisma = require("../lib/prisma");

const SECRET = process.env.JWT_SECRET;
const isProd = process.env.NODE_ENV === "production";
const OTP_TTL_MS = 5 * 60 * 1000;

const sendOtp = async (req, res) => {
  try {
    const { phoneNumber } = req.body;

    const otp = otpGenerator.generate(6, {
      upperCaseAlphabets: false,
      lowerCaseAlphabets: false,
      specialChars: false,
    });

    await prisma.otp.upsert({
      where: { phoneNumber },
      update: { otp, createdAt: new Date() },
      create: { phoneNumber, otp },
    });

    // await twilioClient.messages.create({ body: `Your OTP is: ${otp}`, to: phoneNumber, from: twilioNumber });

    return res.status(200).json({
      success: true,
      message: isProd ? "OTP sent" : otp,
    });
  } catch (e) {
    console.error("[sendOtp]", e);
    return res.status(500).json({ success: false, message: "Failed to send OTP" });
  }
};

const verifyOtp = async (req, res) => {
  try {
    const { phoneNumber, otp } = req.body;
    const record = await prisma.otp.findUnique({ where: { phoneNumber } });

    const isExpired = record && Date.now() - record.createdAt.getTime() > OTP_TTL_MS;
    if (!record || record.otp !== otp || isExpired) {
      return res.status(400).json({ success: false, message: "OTP Not Verified" });
    }

    await prisma.otp.delete({ where: { id: record.id } });

    const otpToken = jwt.sign(
      { phone: phoneNumber, purpose: "otp" },
      SECRET,
      { expiresIn: "10m" }
    );

    return res.status(200).json({
      success: true,
      message: "OTP Verified Successfully",
      data: { otpToken },
    });
  } catch (e) {
    console.error("[verifyOtp]", e);
    return res.status(500).json({ success: false, message: "Failed to verify OTP" });
  }
};

module.exports = { sendOtp, verifyOtp };
