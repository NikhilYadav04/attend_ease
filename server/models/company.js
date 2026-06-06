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
  hrPhone: {
    required: true,
    type: String,
  },
  companyMembers: {
    required: true,
    type: [String],
  },
});

companySchema.index({ companyName: 1 }, { unique: true });
companySchema.index({ companyID: 1 }, { unique: true });

const companyModel = mongoose.model("companyList", companySchema);
module.exports = companyModel;
