import 'package:attend_ease/core/network/api_config.dart';

const int kAppIDZego = 51194509;
const String kAppSignZego =
    'c93bf02ea4ad34788ea78aaaf76af17e38e7a5c31790a0d3b866c3d299a2bc47';

class ApiEndpoints {
  static String get _base => ApiConfig.baseUrl;

  // OTP Verification
  static String get sendOtp => '$_base/api/v1/otp/send-otp';
  static String get verifyOtp => '$_base/api/v1/otp/verify-otp';

  // Role identification
  static String get identify => '$_base/api/v1/auth/identify';

  // Company setup
  static String get addCompany => '$_base/api/v1/company/add-company';
  static String get loginCompany => '$_base/api/v1/company/login-company';

  // Location
  static String get setLocation => '$_base/api/v1/location/store-location';
  static String get getLocation => '$_base/api/v1/location/get-location';
  static String get getCompanyLocation => '$_base/api/v1/location/get-company-location';

  // Employee add and setup
  static String get addEmployee => '$_base/api/v1/employee/add-employee';
  static String get bulkAddEmployees => '$_base/api/v1/employee/bulk-add-employees';
  static String get removeEmployee => '$_base/api/v1/employee/remove-employee';
  static String get joinEmployee => '$_base/api/v1/employee/join-employee';
  static String get myProfile => '$_base/api/v1/employee/my-profile';
  static String get updateProfile => '$_base/api/v1/employee/update-profile';

  // Attendance
  static String get markAttendanceIn => '$_base/api/v1/attendance/mark-in';
  static String get markAttendanceOut => '$_base/api/v1/attendance/mark-out';
  static String get getAttendance => '$_base/api/v1/attendance/get-attend';
  static String get getAttendanceDays => '$_base/api/v1/attendance/get-attend-days';

  // Reports
  static String get reportEmployee => '$_base/api/v1/employee/get-history';
  static String get reportCompany => '$_base/api/v1/company/get-report';

  // Staff count
  static String get staffCount => '$_base/api/v1/employee/get-count';
  static String get staffChangeCount => '$_base/api/v1/employee/change-count';

  // Staff count history
  static String get storeStaffHistory => '$_base/api/v1/company/store-history';
  static String get getStaffHistory => '$_base/api/v1/company/get-history';
  static String get staffListHistory => '$_base/api/v1/company/history-list';

  // Notifications
  static String get sendNotifications => '$_base/api/v1/company/send-notifications';

  // Company Admins
  static String get addAdmin => '$_base/api/v1/company/add-admin';
  static String get listAdmins => '$_base/api/v1/company/admins';
  static String get removeAdmin => '$_base/api/v1/company/remove-admin';

  // Analytics
  static String get companyAnalytics => '$_base/api/v1/company/analytics';

  // Company Settings
  static String get getCompanySettings => '$_base/api/v1/company/settings';
  static String get updateCompanySettings => '$_base/api/v1/company/update-settings';

  // Leave Management
  static String get requestLeave => '$_base/api/v1/leave/request-leave';
  static String get myLeaves => '$_base/api/v1/leave/my-leaves';
  static String get pendingLeaves => '$_base/api/v1/leave/pending-leaves';
  static String get allLeaves => '$_base/api/v1/leave/all-leaves';
  static String get actionLeave => '$_base/api/v1/leave/action-leave';

  // Attendance Corrections
  static String get requestCorrection => '$_base/api/v1/correction/request-correction';
  static String get myCorrections => '$_base/api/v1/correction/my-corrections';
  static String get pendingCorrections => '$_base/api/v1/correction/pending-corrections';
  static String get allCorrections => '$_base/api/v1/correction/all-corrections';
  static String get actionCorrection => '$_base/api/v1/correction/action-correction';

  // Leave balance
  static String get myLeaveBalance => '$_base/api/v1/leave/my-balance';

  // Holidays
  static String get addHoliday => '$_base/api/v1/holiday/add-holiday';
  static String get listHolidays => '$_base/api/v1/holiday/list';
  static String get removeHoliday => '$_base/api/v1/holiday/remove-holiday';

  // Audit log
  static String get auditLog => '$_base/api/v1/audit/log';
}
