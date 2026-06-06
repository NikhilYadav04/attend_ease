import 'package:attend_ease/core/network/api_endpoints.dart';
import 'package:attend_ease/core/network/api_response.dart';
import 'package:attend_ease/core/network/api_service.dart';
import 'package:attend_ease/core/storage/local_storage.dart';

class AttendanceService extends ApiService {
  // Mark In — POST, employee token
  Future<ApiResponse<void>> markIn(
      String inTime, String date, bool isPresent, String month, String year) async {
    final token = await HelperFunctions.getEmployeeToken();
    return post<void>(
      ApiEndpoints.markAttendanceIn,
      token: token,
      data: {
        'InTime': inTime,
        'Date': date,
        'isPresent': isPresent,
        'Month': month,
        'Year': year,
      },
    );
  }

  // Mark Out — POST, employee token — returns totalDays
  Future<ApiResponse<int>> markOut(
      String inTime, String outTime, String date, bool isPresent,
      String month, String year) async {
    final token = await HelperFunctions.getEmployeeToken();
    return post<int>(
      ApiEndpoints.markAttendanceOut,
      token: token,
      data: {
        'InTime': inTime,
        'OutTime': outTime,
        'Date': date,
        'isPresent': isPresent,
        'Month': month,
        'Year': year,
      },
      fromJson: (json) => (json['totalDays'] as num).toInt(),
    );
  }

  // Get attendance — POST, employee token
  Future<ApiResponse<Map<String, dynamic>>> getAttendance(String date) async {
    final token = await HelperFunctions.getEmployeeToken();
    return post<Map<String, dynamic>>(
      ApiEndpoints.getAttendance,
      token: token,
      data: {'Date': date},
      fromJson: (json) => {
        'inTime': json['InTime']?.toString() ?? '',
        'outTime': json['OutTime']?.toString() ?? '',
        'isPresent': json['isPresent'] as bool? ?? false,
      },
    );
  }

  // Get total days present — GET, employee token
  Future<ApiResponse<int>> getAttendanceDays() async {
    final token = await HelperFunctions.getEmployeeToken();
    return get<int>(
      ApiEndpoints.getAttendanceDays,
      token: token,
      fromJson: (json) {
        if (json is List) {
          return json.fold<int>(
              0, (sum, e) => sum + (e['daysPresent'] as num).toInt());
        }
        return 0;
      },
    );
  }
}
