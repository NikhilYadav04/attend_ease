import 'package:shared_preferences/shared_preferences.dart';

class HelperFunctions {
  static String HR_KEY = "HR_TOKEN_KEY";
  static String COMPANY_NAME_KEY = "COMPANY_NAME_TOKEN";
  static String COMPANY_ID_KEY = "COMPANY_ID_TOKEN";
  static String EMPLOYEE_NAME_KEY = "EMPLOYEE_NAME_TOKEN";
  static String EMPLOYEE_ID_KEY = "EMPLOYEE_ID_TOKEN";
  static String EMPLOYEE_COMPANY_ID = "EMPLOYEE_COMPANY_TOKEN";
  static String IN_TIME_TOKEN = "IN_TIME_TOKEN";
  static String COMPANY_JWT_KEY = "COMPANY_JWT_TOKEN";
  static String EMPLOYEE_JWT_KEY = "EMPLOYEE_JWT_TOKEN";
  static String PHONE_KEY = "PHONE_KEY";
  static String ADMIN_NAME_KEY = "ADMIN_NAME_KEY";

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
  static Future<bool> setEmployeeName(String companyName) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString(EMPLOYEE_NAME_KEY, companyName);
  }

// set Employee ID
  static Future<bool> setEmployeeID(String employeeID) async {
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
  static Future<String?> getEmployeeID() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(EMPLOYEE_ID_KEY);
  }

// get Employee COmpany
  static Future<String?> getEmployeeCompany() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(EMPLOYEE_COMPANY_ID);
  }

// set phone number
  static Future<bool> setPhone(String phone) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString(PHONE_KEY, phone);
  }

// get phone number
  static Future<String?> getPhone() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(PHONE_KEY);
  }

// set admin name
  static Future<bool> setAdminName(String name) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString(ADMIN_NAME_KEY, name);
  }

// get admin name
  static Future<String?> getAdminName() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(ADMIN_NAME_KEY);
  }

// set company JWT token
  static Future<bool> setCompanyToken(String token) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString(COMPANY_JWT_KEY, token);
  }

// get company JWT token
  static Future<String?> getCompanyToken() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(COMPANY_JWT_KEY);
  }

// set employee JWT token
  static Future<bool> setEmployeeToken(String token) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.setString(EMPLOYEE_JWT_KEY, token);
  }

// get employee JWT token
  static Future<String?> getEmployeeToken() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(EMPLOYEE_JWT_KEY);
  }

  static const _onboardingKey = 'ONBOARDING_SEEN';

// mark onboarding as completed
  static Future<void> setOnboardingSeen() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    await sf.setBool(_onboardingKey, true);
  }

// check if onboarding has been seen
  static Future<bool> getOnboardingSeen() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getBool(_onboardingKey) ?? false;
  }
}
