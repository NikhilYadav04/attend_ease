const express = require("express");
const { Message } = require("twilio/lib/twiml/MessagingResponse");
const OtpModel = require("../models/otp");
const locationModel = require("../models/location");
const locationRouter = express.Router();

locationRouter.use(express.json());

//store location
locationRouter.post("/store-location", async (req, res) => {
  try {
    const { latitude, longitude, companyName, radius } = req.body;

    const body = await locationModel.findOneAndUpdate(
      {
        latitude,
        longitude,
        companyName,
      },
      { radius },
      { upsert: true, new: true, setDefaultsOnInsert: true }
    );
    console.log(body);
    return res.status(200).json({
      success: true,
      message: body,
    });
  } catch (e) {
    return res.status(500).json({
      success: false,
      message: e.message,
    });
  }
});

// get location
locationRouter.post("/get-location", async (req, res) => {
  try {
    const { companyName } = req.body;

    const body = await locationModel.findOne({ companyName });

    return res.status(200).json({
      success: true,
      message: body,
    });
  } catch (e) {
    return res.status(500).json({
      success: false,
      message: e.message,
    });
  }
});

module.exports = locationRouter;
