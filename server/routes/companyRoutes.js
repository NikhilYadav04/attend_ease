const express = require("express");
const verifyToken = require("../middleware/auth");
const { requireRole } = require("../middleware/auth");
const { requireFields } = require("../middleware/validate");
const {
  addCompany,
  getReport,
  storeHistory,
  getHistory,
  historyList,
  sendNotifications,
  addAdmin,
  listAdmins,
  removeAdmin,
  getAnalytics,
  getCompanySettings,
  updateCompanySettings,
} = require("../controllers/companyController");

const companyRouter = express.Router();
const hrOnly = [verifyToken, requireRole("company")];

companyRouter.post("/add-company",   requireFields("companyName", "companyHR", "companyCity", "HRNumber", "otpToken"), addCompany);
companyRouter.get("/get-report",     hrOnly, getReport);
companyRouter.post("/store-history", hrOnly, requireFields("totalCount", "currentDate"), storeHistory);
companyRouter.post("/get-history",   hrOnly, getHistory);
companyRouter.get("/history-list",   hrOnly, historyList);
companyRouter.post("/send-notifications", hrOnly, requireFields("employeeName"), sendNotifications);
companyRouter.post("/add-admin",     hrOnly, requireFields("name", "phone"), addAdmin);
companyRouter.get("/admins",         hrOnly, listAdmins);
companyRouter.post("/remove-admin",  hrOnly, requireFields("phone"), removeAdmin);
companyRouter.get("/analytics",      hrOnly, getAnalytics);
companyRouter.get("/settings",         hrOnly, getCompanySettings);
companyRouter.post("/update-settings", hrOnly, requireFields("companyCity", "overtimeThresholdHours"), updateCompanySettings);

module.exports = companyRouter;
