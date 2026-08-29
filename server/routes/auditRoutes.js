const express = require("express");
const verifyToken = require("../middleware/auth");
const { requireRole } = require("../middleware/auth");
const { getAuditLog } = require("../controllers/auditController");

const auditRouter = express.Router();
const hrOnly = [verifyToken, requireRole("company")];

auditRouter.get("/log", hrOnly, getAuditLog);

module.exports = auditRouter;
