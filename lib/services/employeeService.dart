import 'dart:convert';

import 'package:attend_ease/constants/url_constants.dart';
import 'package:attend_ease/models/employeeModel.dart';
import 'package:http/http.dart' as http;

class Employeeservice {
  // to add employee
  Future<String> addEmployee(
      String employeeName,
      String employeeNumber,
      String employeePosition,
      String? employeeCompany,
      String? companyID) async {
    Uri url = Uri.parse(add_employee_baseURl);

    employeeModel EmployeeModel = employeeModel(
        employeeName: employeeName,
        employeeNumber: employeeNumber,
        employeePosition: employeePosition,
        employeeCompany: employeeCompany,
        companyID: companyID);

    try {
      var res = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: EmployeeModel.toJson());

      var body = jsonDecode(res.body);

      if (res.statusCode == 200) {
        return "Success";
      } else if (res.statusCode == 400) {
        return body['message'];
      } else {
        return body['message'];
      }
    } catch (e) {
      return e.toString();
    }
  }

  // to join company
  Future<String> joinCOmpany(
      String employeeCompany, String companyID, String employeeName) async {
    Uri url = Uri.parse(login_employee_baseURl);

    EmployeeJoinModel employeeJoinModel = EmployeeJoinModel(
        companyName: employeeCompany,
        companyID: companyID,
        employeeName: employeeName);

    try {
      var res = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: employeeJoinModel.toJson());

      var body = jsonDecode(res.body);

      if (res.statusCode == 200) {
        return "Success";
      } else if (res.statusCode == 401) {
        return body['message'];
      } else {
        return body['message'];
      }
    } catch (e) {
      return e.toString();
    }
  }

  // to get attendance report
  Future<List<dynamic>> getReport(String? employeeName) async {
    try {
      Uri url = Uri.parse(report_employee_baseURl);

      var body = {"employeeName": employeeName};

      var res = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(body));

      var resBody = jsonDecode(res.body);

      if (res.statusCode == 200) {
        List<dynamic> report = resBody['message'];
        return report;
      } else {
        return [];
      }
    } catch (e) {
      print("Error is ${e}");
      return [];
    }
  }

}
