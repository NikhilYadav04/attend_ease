const express = require("express");
const verifyToken = require("../middleware/auth");
const { requireFields } = require("../middleware/validate");
const { storeLocation, getLocation, getCompanyLocation } = require("../controllers/locationController");

const locationRouter = express.Router();

locationRouter.post("/store-location",         verifyToken, requireFields("latitude", "longitude", "radius"), storeLocation);
locationRouter.get("/get-location",            verifyToken, getLocation);
locationRouter.get("/get-company-location",    verifyToken, getCompanyLocation);

module.exports = locationRouter;
