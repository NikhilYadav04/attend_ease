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
  static const employeeSetup = '/employee/setup';
  static const employeeDashboard = '/employee/dashboard';
  static const employeeProfile = '/employee/profile';
  static const employeeBiometric = '/employee/biometric';
  static const employeeLeaveRequest = '/employee/leave-request';
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
