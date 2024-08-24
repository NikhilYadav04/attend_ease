require("dotenv").config();

const express = require("express");
const companyModel = require("../models/company");
const reportModel = require("../models/attendance");
const staffCountModel = require("../models/staffCount");
const staffReportModel = require("../models/staffReport");
const twilio = require("twilio");
const employeeModel = require("../models/employee");

const accountSid = process.env.TWILIO_ACCOUNT_SID;
const accountToken = process.env.TWILIO_ACCOUNT_TOKEN;
const twilioNumber = process.env.TWILIO_PHONE_NUMBER;

const twilioClient = new twilio(accountSid, accountToken);

const companyRouter = express.Router();

companyRouter.use(express.json());

// add company
companyRouter.post("/add-company", async (req, res) => {
  try {
    const { companyName, companyHR, companyID, companyCity } = req.body;

    const companyFOund = await companyModel.findOne({ companyName, companyID });

    if (companyFOund) {
      return res.status(401).json({
        success: true,
        message: "Company Already Exists",
      });
    }

    const body = await companyModel.findOneAndUpdate(
      { companyName, companyHR, companyID, companyCity },
      { $push: { companyMembers: `${companyHR}_HR` } },
      { upsert: true, new: true, setDefaultsOnInsert: true }
    );

    //create staffcount model
    let staffCountBody = new staffCountModel({
      companyName,
      In: 0,
      Out: 0,
      Total: 0,
    });

    await staffCountBody.save();

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

// login as HR
companyRouter.post("/login-company", async (req, res) => {
  try {
    const { companyName, companyID } = req.body;

    const company = await companyModel.findOne({ companyName, companyID });

    if (!company) {
      return res.status(401).json({
        success: true,
        message: "Company Details Invalid",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Company Login Success",
    });
  } catch (e) {
    return res.status(500).json({
      success: true,
      message: e.message,
    });
  }
});

//get staff report
companyRouter.post("/get-report", async (req, res) => {
  try {
    const { employeeCompany } = req.body;

    const body = await reportModel.find({ employeeCompany });

    return res.status(200).json({
      success: true,
      message: body,
    });
  } catch (e) {
    return res.status(500).json({
      success: true,
      message: e.message,
    });
  }
});

// store staff count history
companyRouter.post("/store-history", async (req, res) => {
  try {
    const { companyName, totalCount, currentDate } = req.body;

    let historyBody = await staffReportModel.findOneAndUpdate(
      { companyName },
      {
        $push: {
          list: {
            isSubmit: true,
            totalCount,
            currentDate,
          },
        },
      },
      { new: true, upsert: true }
    );

    const body = await staffReportModel.findOne({ companyName });

    //reset the counts of in and out after submission
    const countBody = await staffCountModel.findOne({ companyName });
    if (countBody) {
      countBody["In"] = 0;
      countBody["Out"] = 0;
      countBody["Total"] = 0;

      await countBody.save(); // Save the changes to the database
    }

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

// get staff count history
companyRouter.post("/get-history", async (req, res) => {
  try {
    const { companyName } = req.body;

    const body = await staffReportModel.findOne({ companyName });
    const countList = body.list;

    return res.status(200).json({
      success: true,
      message: countList,
    });
  } catch (e) {
    return res.status(500).json({
      success: false,
      message: e.message,
    });
  }
});

//get staff count history in form of list
companyRouter.post("/history-list", async (req, res) => {
  try {
    const { companyName } = req.body;

    const body = await staffReportModel.findOne({ companyName });
    const countList = await body.list;

    return res.status(200).json({
      success: true,
      message: countList,
    });
  } catch (e) {
    return res.status(500).json({
      success: false,
      message: e.message,
    });
  }
});

//send whatsapp notification
companyRouter.post("/send-notifications", async (req, res) => {
  try {
    const { employeeName } = req.body;

    const body = await employeeModel.findOne({ employeeName });
    const number = body["employeeNumber"];
    console.log(number);

    // await twilioClient.messages.create({
    //   body: "Your attendance is very less,meet HR tomorrow in the office",
    //   from: "whatsapp:+14155238886",
    //   to: `whatsapp:+91${number}`,
    // });

    return res.status(200).json({
      success: true,
      message: number,
    });
  } catch (e) {
    return res.status(500).json({
      success: false,
      message: e.message,
    });
  }
});


module.exports = companyRouter;
