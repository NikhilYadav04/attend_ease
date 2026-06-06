const express = require("express");
const verifyToken = require("../middleware/auth");
const { requireFields } = require("../middleware/validate");
const {
  addEmployee,
  joinEmployee,
  getHistory,
  changeCount,
  getCount,
} = require("../controllers/employeeController");

const employeeRouter = express.Router();

employeeRouter.post("/add-employee",  verifyToken, requireFields("employeeName", "employeeNumber", "employeePosition"), addEmployee);
employeeRouter.post("/join-employee", requireFields("companyName", "employeeID", "employeeName"), joinEmployee);
employeeRouter.get("/get-history",    verifyToken, getHistory);
employeeRouter.post("/change-count",  verifyToken, requireFields("inCount", "outCount", "TotalCount"), changeCount);
employeeRouter.get("/get-count",      verifyToken, getCount);

module.exports = employeeRouter;
