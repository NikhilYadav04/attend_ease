const express = require("express");
const verifyToken = require("../middleware/auth");
const { requireFields } = require("../middleware/validate");
const { requestLeave, myLeaves, pendingLeaves, actionLeave } = require("../controllers/leaveController");

const leaveRouter = express.Router();

leaveRouter.post("/request-leave", verifyToken, requireFields("leaveType", "fromDate", "toDate", "reason"), requestLeave);
leaveRouter.get("/my-leaves",      verifyToken, myLeaves);
leaveRouter.get("/pending-leaves", verifyToken, pendingLeaves);
leaveRouter.post("/action-leave",  verifyToken, requireFields("leaveId", "action"), actionLeave);

module.exports = leaveRouter;
