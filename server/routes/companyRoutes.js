const express = require("express");
const verifyToken = require("../middleware/auth");
const { requireFields } = require("../middleware/validate");
const {
  addCompany,
  getReport,
  storeHistory,
  getHistory,
  historyList,
  sendNotifications,
} = require("../controllers/companyController");

const companyRouter = express.Router();

companyRouter.post("/add-company",   requireFields("companyName", "companyHR", "companyCity", "HRNumber"), addCompany);
companyRouter.get("/get-report",     verifyToken, getReport);
companyRouter.post("/store-history", verifyToken, requireFields("totalCount", "currentDate"), storeHistory);
companyRouter.post("/get-history",   verifyToken, getHistory);
companyRouter.get("/history-list",   verifyToken, historyList);
companyRouter.post("/send-notifications", verifyToken, requireFields("employeeName"), sendNotifications);

module.exports = companyRouter;
