import 'package:attend_ease/core/network/api_endpoints.dart';
import 'package:attend_ease/core/network/api_response.dart';
import 'package:attend_ease/core/network/api_service.dart';
import 'package:attend_ease/core/storage/local_storage.dart';

class LeaveService extends ApiService {
  Future<ApiResponse<void>> requestLeave(
      String leaveType, String fromDate, String toDate, String reason) async {
    final token = await HelperFunctions.getEmployeeToken();
    return post<void>(
      ApiEndpoints.requestLeave,
      token: token,
      data: {
        'leaveType': leaveType,
        'fromDate': fromDate,
        'toDate': toDate,
        'reason': reason,
      },
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getMyBalance() async {
    final token = await HelperFunctions.getEmployeeToken();
    return get<Map<String, dynamic>>(
      ApiEndpoints.myLeaveBalance,
      token: token,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<List<dynamic>>> getMyLeaves() async {
    final token = await HelperFunctions.getEmployeeToken();
    return get<List<dynamic>>(
      ApiEndpoints.myLeaves,
      token: token,
      fromJson: (json) => json as List<dynamic>,
    );
  }

  Future<ApiResponse<List<dynamic>>> getPendingLeaves() async {
    final token = await HelperFunctions.getCompanyToken();
    return get<List<dynamic>>(
      ApiEndpoints.pendingLeaves,
      token: token,
      fromJson: (json) => json as List<dynamic>,
    );
  }

  Future<ApiResponse<void>> actionLeave(String leaveId, String action) async {
    final token = await HelperFunctions.getCompanyToken();
    return post<void>(
      ApiEndpoints.actionLeave,
      token: token,
      data: {'leaveId': leaveId, 'action': action},
    );
  }
}
