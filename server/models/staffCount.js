const mongoose = require("mongoose");

const staffSchema = new mongoose.Schema({
    
  companyName: {
    required: true,
    type: String,
  },
  In: {
    required: true,
    type: Number,
  },
  Out: {
    required: true,
    type: Number,
  },
  Total: {
    required: true,
    type: Number,
  },
});

const staffCountModel = mongoose.model("staffCount", staffSchema);
module.exports = staffCountModel;
