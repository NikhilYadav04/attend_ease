require("dotenv").config();

const express = require("express");
const mongoose = require("mongoose");
const router = require("./routes/userRoutes");
const companyRouter = require("./routes/companyRoutes");
const locationRouter = require("./routes/locationRoute");
const employeeRouter = require("./routes/employeeRoute");
const attendanceRouter = require("./routes/attendanceRoutes");

const app = express();

const PORT = process.env.PORT || 2000;
const DB = process.env.DB;
app.use(
  express.urlencoded({
    extended: true,
  })
);

app.use("/api", router);
app.use("/company",companyRouter);
app.use("/location",locationRouter);
app.use("/employee",employeeRouter);
app.use("/attendance",attendanceRouter);

mongoose
  .connect(DB)
  .then(() => {
    console.log("Connected To Mongoose");
  })
  .catch((e) => {
    console.log(e);
  });

app.listen(PORT, () => {
  console.log(`Server Connected At ${PORT}`);
});
