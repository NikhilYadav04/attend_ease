import 'package:attend_ease/features/attendance/screens/biometric_auth_screen.dart';
import 'package:attend_ease/features/auth/screens/home_screen.dart';
import 'package:attend_ease/features/auth/screens/onboarding_screen.dart';
import 'package:attend_ease/features/auth/screens/modal_sheet_1.dart';
import 'package:attend_ease/features/auth/screens/modal_sheet_2.dart';
import 'package:attend_ease/features/auth/screens/otp_auth_screen.dart';
import 'package:attend_ease/features/communication/screens/video_call_screen.dart';
import 'package:attend_ease/features/company/screens/add_staff_screen.dart';
import 'package:attend_ease/features/company/screens/admin_profile_screen.dart';
import 'package:attend_ease/features/company/screens/company_hr_screen.dart';
import 'package:attend_ease/features/company/screens/company_location_screen.dart';
import 'package:attend_ease/features/company/screens/company_setup_screen.dart';
import 'package:attend_ease/features/company/screens/bulk_import_screen.dart';
import 'package:attend_ease/features/company/screens/company_analytics_screen.dart';
import 'package:attend_ease/features/company/screens/company_settings_screen.dart';
import 'package:attend_ease/features/company/screens/manage_admins_screen.dart';
import 'package:attend_ease/features/company/screens/manage_holidays_screen.dart';
import 'package:attend_ease/features/company/screens/audit_log_screen.dart';
import 'package:attend_ease/features/company/screens/team_leave_calendar_screen.dart';
import 'package:attend_ease/features/correction/screens/hr_correction_screen.dart';
import 'package:attend_ease/features/correction/screens/my_corrections_screen.dart';
import 'package:attend_ease/features/employee/screens/employee_main_screen.dart';
import 'package:attend_ease/features/employee/screens/employee_setup_screen.dart';
import 'package:attend_ease/features/employee/screens/employee_profile_screen.dart';
import 'package:attend_ease/features/leave/screens/hr_leave_screen.dart';
import 'package:attend_ease/features/leave/screens/leave_request_screen.dart';
import 'package:go_router/go_router.dart';

/// Named route constants — use these everywhere instead of raw strings.
abstract class AppRoutes {
  static const onboarding = '/onboarding';
  static const otp = '/otp';
  static const otpPhone = '/otp/phone';
  static const otpVerify = '/otp/verify';
  static const home = '/home';
  static const companySetup = '/company/setup';
  static const companyLogin = '/company/login';
  static const companyLocation = '/company/location';
  static const companyDashboard = '/company/dashboard';
  static const adminProfile = '/company/profile';
  static const companyAddStaff = '/company/add-staff';
  static const companyLeaveRequests = '/company/leave-requests';
  static const companyCorrectionRequests = '/company/correction-requests';
  static const companyManageAdmins = '/company/manage-admins';
  static const companyAnalytics = '/company/analytics';
  static const companySettings = '/company/settings';
  static const bulkImportStaff = '/company/bulk-import';
  static const companyHolidays = '/company/holidays';
  static const companyAuditLog = '/company/audit-log';
  static const companyTeamLeaveCalendar = '/company/team-leave-calendar';
  static const employeeSetup = '/employee/setup';
  static const employeeDashboard = '/employee/dashboard';
  static const employeeProfile = '/employee/profile';
  static const employeeBiometric = '/employee/biometric';
  static const employeeLeaveRequest = '/employee/leave-request';
  static const employeeCorrections = '/employee/corrections';
  static const call = '/call';
}

/// Top-level router instance — can be called from anywhere in the app,
/// including the 401 `ApiService.onUnauthorized` callback.
final goRouter = GoRouter(
  initialLocation: AppRoutes.otp,
  routes: [
    // ── Auth ─────────────────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.otp,
      builder: (context, state) => const OtpAuthScreen(),
    ),
    GoRoute(
      path: AppRoutes.otpPhone,
      builder: (context, state) => const SheetScreen1(),
    ),
    GoRoute(
      path: AppRoutes.otpVerify,
      builder: (context, state) => const SheetScreen2(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),

    // ── Company ───────────────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.companySetup,
      builder: (context, state) => const CompanySetupScreen(),
    ),
    GoRoute(
      path: AppRoutes.companyLocation,
      // extra: String? (setup) OR Map<String,dynamic> {companyName, isEditing} (edit)
      builder: (context, state) {
        final extra = state.extra;
        if (extra is Map<String, dynamic>) {
          return CompanyLocationScreen(
            companyName: extra['companyName'] as String?,
            isEditing: extra['isEditing'] as bool? ?? false,
          );
        }
        return CompanyLocationScreen(companyName: extra as String?);
      },
    ),
    GoRoute(
      path: AppRoutes.companyDashboard,
      builder: (context, state) => const CompanyHrScreen(),
    ),
    GoRoute(
      path: AppRoutes.adminProfile,
      builder: (context, state) => const AdminProfileScreen(),
    ),
    GoRoute(
      path: AppRoutes.companyAddStaff,
      builder: (context, state) => const AddStaffScreen(),
    ),
    GoRoute(
      path: AppRoutes.companyLeaveRequests,
      builder: (context, state) => const HrLeaveScreen(),
    ),
    GoRoute(
      path: AppRoutes.companyCorrectionRequests,
      builder: (context, state) => const HrCorrectionScreen(),
    ),
    GoRoute(
      path: AppRoutes.companyManageAdmins,
      builder: (context, state) => const ManageAdminsScreen(),
    ),
    GoRoute(
      path: AppRoutes.companyAnalytics,
      builder: (context, state) => const CompanyAnalyticsScreen(),
    ),
    GoRoute(
      path: AppRoutes.companySettings,
      builder: (context, state) => const CompanySettingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.bulkImportStaff,
      builder: (context, state) => const BulkImportScreen(),
    ),
    GoRoute(
      path: AppRoutes.companyHolidays,
      builder: (context, state) => const ManageHolidaysScreen(),
    ),
    GoRoute(
      path: AppRoutes.companyAuditLog,
      builder: (context, state) => const AuditLogScreen(),
    ),
    GoRoute(
      path: AppRoutes.companyTeamLeaveCalendar,
      builder: (context, state) => const TeamLeaveCalendarScreen(),
    ),

    // ── Employee ──────────────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.employeeSetup,
      builder: (context, state) => const EmployeeSetupScreen(),
    ),
    GoRoute(
      path: AppRoutes.employeeDashboard,
      builder: (context, state) => const EmployeeMainScreen(),
    ),
    GoRoute(
      path: AppRoutes.employeeProfile,
      builder: (context, state) => const EmployeeProfileScreen(),
    ),
    GoRoute(
      path: AppRoutes.employeeBiometric,
      builder: (context, state) => const BiomAuth(),
    ),
    GoRoute(
      path: AppRoutes.employeeLeaveRequest,
      builder: (context, state) => const LeaveRequestScreen(),
    ),
    GoRoute(
      path: AppRoutes.employeeCorrections,
      builder: (context, state) => const MyCorrectionsScreen(),
    ),

    // ── Shared ────────────────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.call,
      // extra: Map<String, String> — {'callID': ..., 'username': ...}
      builder: (context, state) {
        final extra = state.extra as Map<String, String>;
        return CallScreen(
          CallID: extra['callID']!,
          Username: extra['username']!,
        );
      },
    ),
  ],
);
