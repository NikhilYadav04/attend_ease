const express = require("express");
const verifyToken = require("../middleware/auth");
const { requireRole, requireActiveEmployee } = require("../middleware/auth");
const { requireFields } = require("../middleware/validate");
const { requestLeave, myLeaves, myBalance, pendingLeaves, actionLeave } = require("../controllers/leaveController");

const leaveRouter = express.Router();
const hrOnly = [verifyToken, requireRole("company")];
const employeeOnly = [verifyToken, requireRole("employee"), requireActiveEmployee];

leaveRouter.post("/request-leave", employeeOnly, requireFields("leaveType", "fromDate", "toDate", "reason"), requestLeave);
leaveRouter.get("/my-leaves",      employeeOnly, myLeaves);
leaveRouter.get("/my-balance",     employeeOnly, myBalance);
leaveRouter.get("/pending-leaves", hrOnly, pendingLeaves);
leaveRouter.post("/action-leave",  hrOnly, requireFields("leaveId", "action"), actionLeave);

module.exports = leaveRouter;
