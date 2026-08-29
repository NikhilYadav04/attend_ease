import 'package:attend_ease/core/network/api_endpoints.dart';
import 'package:attend_ease/core/network/api_response.dart';
import 'package:attend_ease/core/network/api_service.dart';
import 'package:attend_ease/core/storage/local_storage.dart';

class AttendanceService extends ApiService {
  // Mark In — POST, employee token — server stamps time and enforces geo-fence
  Future<ApiResponse<Map<String, dynamic>>> markIn(
      double latitude, double longitude) async {
    final token = await HelperFunctions.getEmployeeToken();
    return post<Map<String, dynamic>>(
      ApiEndpoints.markAttendanceIn,
      token: token,
      data: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
      },
      fromJson: (json) => {
        'inTime': json['InTime']?.toString() ?? '',
        'date': json['Date']?.toString() ?? '',
        'isLate': json['isLate'] as bool? ?? false,
      },
    );
  }

  // Mark Out — POST, employee token — server stamps time and enforces geo-fence
  Future<ApiResponse<Map<String, dynamic>>> markOut(
      double latitude, double longitude) async {
    final token = await HelperFunctions.getEmployeeToken();
    return post<Map<String, dynamic>>(
      ApiEndpoints.markAttendanceOut,
      token: token,
      data: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
      },
      fromJson: (json) => {
        'totalDays': (json['totalDays'] as num).toInt(),
        'outTime': json['OutTime']?.toString() ?? '',
      },
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
        'isLate': json['isLate'] as bool? ?? false,
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
