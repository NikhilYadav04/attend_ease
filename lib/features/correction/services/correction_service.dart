import 'package:attend_ease/core/network/api_endpoints.dart';
import 'package:attend_ease/core/network/api_response.dart';
import 'package:attend_ease/core/network/api_service.dart';
import 'package:attend_ease/core/storage/local_storage.dart';

class CorrectionService extends ApiService {
  Future<ApiResponse<void>> requestCorrection(
      String date, String? requestedInTime, String? requestedOutTime, String reason) async {
    final token = await HelperFunctions.getEmployeeToken();
    return post<void>(
      ApiEndpoints.requestCorrection,
      token: token,
      data: {
        'date': date,
        if (requestedInTime != null) 'requestedInTime': requestedInTime,
        if (requestedOutTime != null) 'requestedOutTime': requestedOutTime,
        'reason': reason,
      },
    );
  }

  Future<ApiResponse<List<dynamic>>> getMyCorrections() async {
    final token = await HelperFunctions.getEmployeeToken();
    return get<List<dynamic>>(
      ApiEndpoints.myCorrections,
      token: token,
      fromJson: (json) => json as List<dynamic>,
    );
  }

  Future<ApiResponse<List<dynamic>>> getPendingCorrections() async {
    final token = await HelperFunctions.getCompanyToken();
    return get<List<dynamic>>(
      ApiEndpoints.pendingCorrections,
      token: token,
      fromJson: (json) => json as List<dynamic>,
    );
  }

  Future<ApiResponse<void>> actionCorrection(String correctionId, String action) async {
    final token = await HelperFunctions.getCompanyToken();
    return post<void>(
      ApiEndpoints.actionCorrection,
      token: token,
      data: {'correctionId': correctionId, 'action': action},
    );
  }
}
