const mongoose = require("mongoose");

const employeeSchema = new mongoose.Schema({
  employeeName: {
    required: true,
    type: String,
  },
  employeeNumber: {
    required: true,
    type: String,
  },
  employeePosition: {
    required: true,
    type: String,
  },
  employeeID: {
    required: true,
    type: String,
  },
  employeeCompany: {
    required: true,
    type: String,
  },
});

employeeSchema.index({ employeeID: 1 }, { unique: true });
employeeSchema.index({ employeeName: 1, employeeCompany: 1 });

const employeeModel = mongoose.model("employees", employeeSchema);
module.exports = employeeModel;
