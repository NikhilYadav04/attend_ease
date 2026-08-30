import 'package:attend_ease/core/router/app_router.dart';
import 'package:attend_ease/features/attendance/providers/attendance_provider.dart';
import 'package:attend_ease/features/auth/providers/auth_provider.dart';
import 'package:attend_ease/features/company/providers/company_provider.dart';
import 'package:attend_ease/features/correction/providers/correction_provider.dart';
import 'package:attend_ease/features/employee/providers/employee_provider.dart';
import 'package:attend_ease/features/leave/providers/leave_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// Clears the JWT token, all session identity, and every feature provider's
/// cached lists so a second login on the same device never inherits stale
/// data or an already-verified biometric flag from the previous session.
Future<void> performLogout(BuildContext context) async {
  await context.read<AuthProvider>().clearSession();
  if (!context.mounted) return;
  context.read<CompanyProvider>().reset();
  context.read<AttendanceProvider>().reset();
  context.read<EmployeeProvider>().reset();
  context.read<LeaveProvider>().reset();
  context.read<CorrectionProvider>().reset();
  context.go(AppRoutes.otp);
}
