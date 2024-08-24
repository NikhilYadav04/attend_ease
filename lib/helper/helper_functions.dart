import 'package:shared_preferences/shared_preferences.dart';

class HelperFunctions {
  static String HR_KEY = "HR_TOKEN_KEY";
  static String COMPANY_NAME_KEY = "COMPANY_NAME_TOKEN";
  static String COMPANY_ID_KEY = "COMPANY_ID_TOKEN";
  static String EMPLOYEE_NAME_KEY = "EMPLOYEE_NAME_TOKEN";
  static String EMPLOYEE_ID_KEY = "EMPLOYEE_ID_TOKEN";
  static String EMPLOYEE_COMPANY_ID = "EMPLOYEE_COMPANY_TOKEN";
  static String IN_TIME_TOKEN = "IN_TIME_TOKEN";

// set to true when logged in and false when logged out
  static Future<bool> setStatus(bool isLogIN) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setBool(HR_KEY, isLogIN);
  }

// set company name
  static Future<bool> setCompanyName(String companyName) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString(COMPANY_NAME_KEY, companyName);
  }

// set company ID
  static Future<bool> setCompanyID(String companyID) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString(COMPANY_ID_KEY, companyID);
  }

// set Employee name
  static Future<bool> setEMployeeName(String companyName) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString(EMPLOYEE_NAME_KEY, companyName);
  }

// set Employee ID
  static Future<bool> setEMployeeID(String employeeID) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString(EMPLOYEE_ID_KEY, employeeID);
  }

// set employee company name
  static Future<bool?> setEmployeeCompany(String companyName) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString(EMPLOYEE_COMPANY_ID, companyName);
  }

// set the InTime
  static Future<bool?> setInTime(String inTime) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString(IN_TIME_TOKEN, inTime);
  }

// get the InTime
  static Future<String?> getInTime() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(IN_TIME_TOKEN);
  }

// get the status of logged in
  static Future<bool?> getStatus() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getBool(HR_KEY);
  }

// get company name
  static Future<String?> getCompanyName() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(COMPANY_NAME_KEY);
  }

// get company ID
  static Future<String?> getCompanyID() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(COMPANY_ID_KEY);
  }

// get EMployee name
  static Future<String?> getEmployeeName() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(EMPLOYEE_NAME_KEY);
  }

// get Employee ID
  static Future<String?> getEMployeeID() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(EMPLOYEE_ID_KEY);
  }

// get Employee COmpany
  static Future<String?> getEmployeeCOmpany() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(EMPLOYEE_COMPANY_ID);
  }
}
