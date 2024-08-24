require("dotenv").config();

const express = require("express");
const employeeModel = require("../models/employee");
const companyModel = require("../models/company");
const reportModel = require("../models/attendance");
const staffCountModel = require("../models/staffCount");
const employeeRouter = express.Router();

employeeRouter.use(express.json());

//add staff
employeeRouter.post("/add-employee", async (req, res) => {
  try {
    const {
      employeeName,
      employeeNumber,
      employeePosition,
      employeeCompany,
      companyID,
    } = req.body;

    // we take details of employee and his company name and update employee list
    const body = await employeeModel.findOneAndUpdate(
      { employeeName, employeeNumber, employeePosition, employeeCompany },
      { employeeID: `${employeeName}_${companyID}` },
      { upsert: true, new: true, setDefaultsOnInsert: true }
    );

    // then we update members list of specific company
    const updateMember = await companyModel.updateOne(
      { companyID },
      { $push: { companyMembers: `${employeeName}_${employeeCompany}` } }
    );

    if (!updateMember) {
      return res.status(400).json({
        success: false,
        message: "Failed TO Join",
      });
    }

    // then we make attendance field of that employee
    let attendanceBody = new reportModel({
      employeeName,
      employeeCompany,
      daysPresent: 1,
      attendance: [
        {
          InTime: "00:00",
          OutTime: "00:00",
          Date: "17/04/2004",
          isPresent: false,
        },
      ],
    });

    await attendanceBody.save();

    //then we create employees

    return res.status(200).json({
      success: true,
      message: attendanceBody,
    });
  } catch (e) {
    return res.status(500).json({
      success: false,
      message: e.message,
    });
  }
});

//join company
employeeRouter.post("/join-employee", async (req, res) => {
  try {
    const { companyName, companyID, employeeName } = req.body;

    const company = await companyModel.findOne({ companyName, companyID });
    const employee = await employeeModel.findOne({ employeeName });

    // check if company with id and name exists
    if (!company) {
      return res.status(401).json({
        success: false,
        message: "Invalid Details Found",
      });
    }

    if (!employee) {
      return res.status(401).json({
        success: false,
        message: "Invalid Details Found",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Congrats joined",
    });
  } catch (e) {
    return res.status(500).json({
      success: false,
      message: e.message,
    });
  }
});

//get attedance history
employeeRouter.post("/get-history", async (req, res) => {
  try {
    const { employeeName } = req.body;

    const body = await reportModel.findOne({ employeeName });

    const list = body.attendance;

    return res.status(200).json({
      success: true,
      message: list,
    });
  } catch (e) {
    return res.status(500).json({
      success: false,
      message: e.message,
    });
  }
});

//change the in and out count
employeeRouter.post("/change-count", async (req, res) => {
  try {
    const { companyName, inCount, outCount, TotalCount } = req.body;

    const updatedEmployee = await staffCountModel.findOneAndUpdate(
      { companyName: companyName },
      {
        $inc: {
          In: inCount,
          Out: outCount,
          Total: TotalCount,
        },
      },
      { new: true }
    );

    return res.status(200).json({
      success: true,
      message: updatedEmployee,
    });
  } catch (e) {
    return res.status(500).json({
      success: false,
      message: e.message,
    });
  }
});

//get the in and out count
employeeRouter.post("/get-count", async (req, res) => {
  try {
    const { companyName } = req.body;

    const body = await staffCountModel.findOne({ companyName });
    // console.log(body)

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

module.exports = employeeRouter;
