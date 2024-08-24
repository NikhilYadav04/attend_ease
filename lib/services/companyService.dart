import 'dart:convert';
import 'dart:ffi';

import 'package:attend_ease/constants/url_constants.dart';
import 'package:attend_ease/globalobjects/variables.dart';
import 'package:attend_ease/models/companyModel.dart';
import 'package:http/http.dart' as http;

class companyService {
  //add Company
  Future<String> addCompany(String companyName, String companyHR,
      String companyID, String companyCity) async {
    try {
      Uri url = Uri.parse(add_company_baseUrl);

      CompanyModel companyBody = CompanyModel(
          companyName: companyName,
          companyHR: companyHR,
          companyID: companyID,
          companyCity: companyCity);

      var res = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: companyBody.toJson());

      if (res.statusCode == 200) {
        var body = jsonDecode(res.body);

        return "Success";
      } else if (res.statusCode == 401) {
        var body = jsonDecode(res.body);
        return body['message'];
      } else {
        var body = jsonDecode(res.body);
        print(body['message']);
        return body['message'];
      }
    } catch (e) {
      return e.toString();
    }
  }

  //login as HR
  Future<String> loginCompany(String companyName, String companyID) async {
    try {
      Uri url = Uri.parse(login_company_baseUrl);

      CompanyModel companyModel = CompanyModel(
          companyName: companyName,
          companyHR: "",
          companyID: companyID,
          companyCity: "");

      var res = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: companyModel.toJson());

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

//get staff list
  Future<List<dynamic>> getSTaff(String? employeeCompany) async {
    try {
      Uri uri = Uri.parse(report_company_baseURl);

      var body = {"employeeCompany": employeeCompany};

      var res = await http.post(uri,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(body));

      var resBody = jsonDecode(res.body);
      List<dynamic> report = resBody['message'];

      if (res.statusCode == 200) {
        return report;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

//get staff count
  Future<String> getCount(String? companyName) async {
    try {
      Uri uri = Uri.parse(staff_count);

      var body = {"companyName": companyName};

      var res = await http.post(uri,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(body));

      var resBody = jsonDecode(res.body);
      var staffCount = resBody['message'];
      print("COuntBody is ${staffCount}");

      if (res.statusCode == 200) {
        inCount = staffCount['In'];
        outCount = staffCount['Out'];
        totalCount = staffCount['Total'];
        return "Success";
      } else {
        return resBody['message'];
      }
    } catch (e) {
      return e.toString();
    }
  }

//change staff count
  Future<String> changeCount(
      String? companyName, int inCount, int outCount, int TotalCount) async {
    try {
      Uri uri = Uri.parse(staff_change_count);

      var body = {
        "companyName": companyName,
        "inCount": inCount,
        "outCount": outCount,
        "TotalCount": TotalCount
      };

      var res = await http.post(uri,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(body));

      var resBody = jsonDecode(res.body);

      if (res.statusCode == 200) {
        return resBody['message'];
      } else {
        return resBody['message'];
      }
    } catch (e) {
      return e.toString();
    }
  }

//store staff count history
  Future<String> storeCountHistory(
      String? companyName, int totalCount, String currentDate) async {
    try {
      Uri uri = Uri.parse(store_staff_history);

      var body = {
        "companyName": companyName,
        "totalCount": totalCount,
        "currentDate": currentDate
      };

      var res = await http.post(uri,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(body));

      var resBody = jsonDecode(res.body);

      if (res.statusCode == 200) {
        return "Success";
      } else {
        return resBody['message'];
      }
    } catch (e) {
      return e.toString();
    }
  }

//get staff count history
  Future<String> getCountHistory(String? companyName) async {
    try {
      Uri uri = Uri.parse(get_staff_history);

      var body = {"companyName": companyName};

      var res = await http.post(uri,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(body));
      var resBody = jsonDecode(res.body);
      List<dynamic> message = resBody['message'];

      isSubmit = message[0]['isSubmit'];

      if (res.statusCode == 200) {
        return isSubmit.toString();
      } else {
        return resBody['message'];
      }
    } catch (e) {
      return e.toString();
    }
  }

//get staff count history in form of list
  Future<List<dynamic>> getCountList(String? companyName) async {
    try {
      Uri uri = Uri.parse(staff_list_history);

      var body = {"companyName": companyName};

      var res = await http.post(uri,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(body));
      var resBody = jsonDecode(res.body);
      List<dynamic> resList = resBody['message'];
      if (res.statusCode == 200) {
        return resList;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

// send notifications whatsapp
  Future<String> sendNotify(String? employeeName) async {
    try {
      Uri url = Uri.parse(notify);

      var body = {"employeeName": employeeName};

      var res = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(body));
      var resBody = jsonDecode(res.body);

      if (res.statusCode == 200) {
        return resBody['message'];
      } else {
        return resBody['message'];
      }
    } catch (e) {
      return e.toString();
    }
  }
}
