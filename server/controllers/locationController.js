const locationModel = require("../models/location");

const storeLocation = async (req, res) => {
  try {
    const { latitude, longitude, radius, workStartTime } = req.body;
    const { companyName } = req.user;

    const update = { latitude, longitude, radius };
    if (workStartTime) update.workStartTime = workStartTime;

    const body = await locationModel.findOneAndUpdate(
      { companyName },
      update,
      { upsert: true, new: true, setDefaultsOnInsert: true }
    );

    return res.status(200).json({ success: true, message: "Location stored", data: body });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

const getLocation = async (req, res) => {
  try {
    const { employeeCompany } = req.user;
    const body = await locationModel.findOne({ companyName: employeeCompany });

    if (!body) {
      return res.status(200).json({ success: false, message: "Location not set" });
    }

    return res.status(200).json({ success: true, message: "OK", data: body });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

const getCompanyLocation = async (req, res) => {
  try {
    const { companyName } = req.user;
    const body = await locationModel.findOne({ companyName });

    if (!body) {
      return res.status(200).json({ success: false, message: "Location not set" });
    }

    return res.status(200).json({ success: true, message: "OK", data: body });
  } catch (e) {
    return res.status(500).json({ success: false, message: e.message });
  }
};

module.exports = { storeLocation, getLocation, getCompanyLocation };
