const express = require("express");
const verifyToken = require("../middleware/auth");
const { requireRole } = require("../middleware/auth");
const { requireFields } = require("../middleware/validate");
const { addHoliday, listHolidays, removeHoliday } = require("../controllers/holidayController");

const holidayRouter = express.Router();
const hrOnly = [verifyToken, requireRole("company")];

holidayRouter.post("/add-holiday",    hrOnly, requireFields("date", "name"), addHoliday);
holidayRouter.get("/list",            verifyToken, listHolidays);
holidayRouter.post("/remove-holiday", hrOnly, requireFields("holidayId"), removeHoliday);

module.exports = holidayRouter;
