const express = require("express");
const verifyToken = require("../middleware/auth");
const { requireRole, requireActiveEmployee } = require("../middleware/auth");
const { requireFields } = require("../middleware/validate");
const { storeLocation, getLocation, getCompanyLocation } = require("../controllers/locationController");

const locationRouter = express.Router();
const hrOnly = [verifyToken, requireRole("company")];
const employeeOnly = [verifyToken, requireRole("employee"), requireActiveEmployee];

locationRouter.post("/store-location",      hrOnly, requireFields("latitude", "longitude", "radius"), storeLocation);
locationRouter.get("/get-location",         employeeOnly, getLocation);
locationRouter.get("/get-company-location", hrOnly, getCompanyLocation);

module.exports = locationRouter;
