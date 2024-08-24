const mongoose = require("mongoose");

const companySchema = new mongoose.Schema({
  companyName: {
    required: true,
    type: String,
  },
  companyHR: {
    required: true,
    type: String,
  },
  companyID: {
    required: true,
    type: String,
  },
  companyCity: {
    required: true,
    type: String,
  },
  companyMembers: {
    required: true,
    type: [String],
  },
});

const companyModel = mongoose.model("companyList", companySchema);
module.exports = companyModel;
