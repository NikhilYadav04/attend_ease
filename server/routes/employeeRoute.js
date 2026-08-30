const express = require("express");
const verifyToken = require("../middleware/auth");
const { requireRole, requireActiveEmployee } = require("../middleware/auth");
const { requireFields } = require("../middleware/validate");
const {
  addEmployee,
  bulkAddEmployees,
  joinEmployee,
  getHistory,
  changeCount,
  getCount,
  removeEmployee,
  getProfile,
  updateProfile,
} = require("../controllers/employeeController");

const employeeRouter = express.Router();
const hrOnly = [verifyToken, requireRole("company")];
const employeeOnly = [verifyToken, requireRole("employee"), requireActiveEmployee];

employeeRouter.post("/add-employee",       hrOnly, requireFields("employeeName", "employeeNumber", "employeePosition"), addEmployee);
employeeRouter.post("/bulk-add-employees", hrOnly, requireFields("employees"), bulkAddEmployees);
employeeRouter.post("/remove-employee",    hrOnly, requireFields("employeeName"), removeEmployee);
employeeRouter.post("/join-employee",   requireFields("companyName", "employeeID", "employeeName", "otpToken"), joinEmployee);
employeeRouter.get("/get-history",      employeeOnly, getHistory);
employeeRouter.post("/change-count",    employeeOnly, requireFields("inCount", "outCount", "TotalCount"), changeCount);
employeeRouter.get("/get-count",        hrOnly, getCount);
employeeRouter.get("/my-profile",       employeeOnly, getProfile);
employeeRouter.post("/update-profile",  employeeOnly, requireFields("employeePosition"), updateProfile);

module.exports = employeeRouter;
