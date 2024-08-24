import 'dart:convert';

import 'package:attend_ease/constants/url_constants.dart';
import 'package:attend_ease/globalobjects/variables.dart';
import 'package:attend_ease/helper/helper_functions.dart';
import 'package:attend_ease/models/attendanceModel.dart';
import 'package:http/http.dart' as http;

class AttendanceService {
  // to mark attendance
  Future<String> markAttendance(String? employeeName, String? InTime,
      String OutTime, String Date, bool isPresent) async {
    try {
      Uri url = Uri.parse(mark_attendance_url);

      attendanceModel attendance_body = attendanceModel(
          employeeName: employeeName,
          InTime: InTime,
          OutTime: OutTime,
          Date: Date,
          isPresent: isPresent);

      var res = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: attendance_body.toJson());
      var body = jsonDecode(res.body);
      if (res.statusCode == 200) {
        TotalDays = body['message'];
        return "Success";
      } else {
        return body['message'];
      }
    } catch (e) {
      return e.toString();
    }
  }

  // to get attendance data
  Future<String> getAttendance(String? employeeName, String date) async {
    try {
      Uri uri = Uri.parse(get_attendance_url);

      getAttendanceModel body =
          getAttendanceModel(employeeName: employeeName, Date: date);

      var res = await http.post(uri,
          headers: {
            'Content-Type': 'application/json',
          },
          body: body.toJson());

      var resBody = jsonDecode(res.body);
      var finalBody = resBody['message'];
      print("FInalbody is ${finalBody}");

      if (res.statusCode == 200) {
        InTime_Display = await HelperFunctions.getInTime();
        InTime = finalBody['InTime'];
        OutTime = finalBody['OutTime'];
        isPresent = finalBody['isPresent'];
        return "Success";
      } else {
        return resBody['message'];
      }
    } catch (e) {
      print(e.toString());
      return e.toString();
    }
  }

  // to get attendance days
  Future<String> getAttendanceDays(String? employeeName) async {
    try {
      Uri uri = Uri.parse(get_attendance_days_url);

      getAttendanceModel body =
          getAttendanceModel(employeeName: employeeName, Date: "");

      var res = await http.post(uri,
          headers: {
            'Content-Type': 'application/json',
          },
          body: body.toJson());

      var resBody = jsonDecode(res.body);

      if (res.statusCode == 200) {
        TotalDays = resBody['message'];

        return "Success";
      } else {
        return resBody['message'];
      }
    } catch (e) {
      return e.toString();
    }
  }
}
