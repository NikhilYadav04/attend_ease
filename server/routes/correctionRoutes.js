const express = require("express");
const verifyToken = require("../middleware/auth");
const { requireRole, requireActiveEmployee } = require("../middleware/auth");
const { requireFields } = require("../middleware/validate");
const {
  requestCorrection,
  myCorrections,
  pendingCorrections,
  actionCorrection,
} = require("../controllers/correctionController");

const correctionRouter = express.Router();
const hrOnly = [verifyToken, requireRole("company")];
const employeeOnly = [verifyToken, requireRole("employee"), requireActiveEmployee];

correctionRouter.post("/request-correction", employeeOnly, requireFields("date", "reason"), requestCorrection);
correctionRouter.get("/my-corrections",      employeeOnly, myCorrections);
correctionRouter.get("/pending-corrections", hrOnly, pendingCorrections);
correctionRouter.post("/action-correction",  hrOnly, requireFields("correctionId", "action"), actionCorrection);

module.exports = correctionRouter;
