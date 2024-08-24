const mongoose = require("mongoose");

const listSchema = new mongoose.Schema({
  isSubmit: {
    required: true,
    type: Boolean,
  },
  totalCount: {
    required: true,
    type: Number,
  },
  currentDate: {
    required: true,
    type: String,
  },
});

const staffReportSchema = new mongoose.Schema({
  companyName: {
    required: true,
    type: String,
  },
  list: [listSchema],
});

const staffReportModel = mongoose.model("staffReport", staffReportSchema);
module.exports = staffReportModel;
