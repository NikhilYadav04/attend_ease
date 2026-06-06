import 'package:attend_ease/features/attendance/services/attendance_service.dart';
import 'package:attend_ease/features/company/services/company_service.dart';
import 'package:attend_ease/features/employee/services/employee_service.dart';
import 'package:attend_ease/features/attendance/services/location_service.dart';
import 'package:attend_ease/features/auth/services/auth_service.dart';
import 'package:attend_ease/features/auth/services/otp_service.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  getIt.registerLazySingleton<OtpService>(() => OtpService());
  getIt.registerLazySingleton<AuthService>(() => AuthService());
  getIt.registerLazySingleton<CompanyService>(() => CompanyService());
  getIt.registerLazySingleton<EmployeeService>(() => EmployeeService());
  getIt.registerLazySingleton<AttendanceService>(() => AttendanceService());
  getIt.registerLazySingleton<LocationService>(() => LocationService());
}
