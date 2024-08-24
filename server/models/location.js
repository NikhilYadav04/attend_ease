const mongoose = require("mongoose");

const locationSchema = new mongoose.Schema({
  latitude: {
    type: String,
    required: true,
  },
  longitude: {
    type: String,
    required: true,
  },
  companyName: {
    type: String,
    required: true,
  },
  radius :{
    type: Number,
    required : true
  }
});

const locationModel = mongoose.model("location", locationSchema);
module.exports = locationModel;
