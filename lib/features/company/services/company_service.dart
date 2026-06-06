import 'package:attend_ease/core/network/api_endpoints.dart';
import 'package:attend_ease/core/network/api_response.dart';
import 'package:attend_ease/core/network/api_service.dart';
import 'package:attend_ease/core/storage/local_storage.dart';
import 'package:attend_ease/features/company/models/company_model.dart';

class CompanyService extends ApiService {
  // Add company — no auth, returns token + generated companyID
  Future<ApiResponse<Map<String, String>>> addCompany(
      String companyName, String companyHR, String companyCity, String hrNumber) async {
    final companyBody = CompanyModel(
        companyName: companyName,
        companyHR: companyHR,
        companyCity: companyCity,
        HRNumber: hrNumber);

    return post<Map<String, String>>(
      ApiEndpoints.addCompany,
      data: companyBody.toMap(),
      fromJson: (json) => {
        'token': json['token'] as String,
        'companyID': json['companyID'] as String,
      },
    );
  }

  // Login as HR — no auth, returns token
  Future<ApiResponse<String>> loginCompany(
      String companyName, String companyID) async {
    return post<String>(
      ApiEndpoints.loginCompany,
      data: {'companyName': companyName, 'companyID': companyID},
      fromJson: (json) => json['token'] as String,
    );
  }

  // Get staff list — GET, company token
  Future<ApiResponse<List<dynamic>>> getStaff() async {
    final token = await HelperFunctions.getCompanyToken();
    return get<List<dynamic>>(
      ApiEndpoints.reportCompany,
      token: token,
      fromJson: (json) => json as List<dynamic>,
    );
  }

  // Get staff count — GET, company token
  Future<ApiResponse<Map<String, dynamic>>> getCount() async {
    final token = await HelperFunctions.getCompanyToken();
    return get<Map<String, dynamic>>(
      ApiEndpoints.staffCount,
      token: token,
      fromJson: (json) => {
        'inCount': (json['In'] as num).toInt(),
        'outCount': (json['Out'] as num).toInt(),
        'totalCount': (json['Total'] as num).toInt(),
        'isSubmit': json['submit'] as bool? ?? false,
      },
    );
  }

  // Change staff count — POST, employee token (called by employee)
  Future<ApiResponse<void>> changeCount(
      int inCount, int outCount, int totalCount) async {
    final token = await HelperFunctions.getEmployeeToken();
    return post<void>(
      ApiEndpoints.staffChangeCount,
      token: token,
      data: {
        'inCount': inCount,
        'outCount': outCount,
        'TotalCount': totalCount,
      },
    );
  }

  // Store staff count history — POST, company token
  Future<ApiResponse<void>> storeCountHistory(
      int totalCount, String currentDate) async {
    final token = await HelperFunctions.getCompanyToken();
    return post<void>(
      ApiEndpoints.storeStaffHistory,
      token: token,
      data: {
        'totalCount': totalCount,
        'currentDate': currentDate,
      },
    );
  }

  // Get staff count history (returns isSubmit bool) — POST, company token
  Future<ApiResponse<bool>> getCountHistory(String employeeID) async {
    final token = await HelperFunctions.getCompanyToken();
    return post<bool>(
      ApiEndpoints.getStaffHistory,
      token: token,
      data: {'employeeID': employeeID},
      fromJson: (json) {
        if (json is! List || json.isEmpty) return false;
        final now = DateTime.now();
        final months = ['January','February','March','April','May','June',
            'July','August','September','October','November','December'];
        final today =
            '${now.day.toString().padLeft(2, '0')} ${months[now.month - 1]}';
        return json.any((e) =>
            e['currentDate'] == today && (e['isSubmit'] as bool? ?? false));
      },
    );
  }

  // Get staff count history list — GET, company token
  Future<ApiResponse<List<dynamic>>> getCountList() async {
    final token = await HelperFunctions.getCompanyToken();
    return get<List<dynamic>>(
      ApiEndpoints.staffListHistory,
      token: token,
      fromJson: (json) => json as List<dynamic>,
    );
  }

  // Send WhatsApp notification — POST, company token
  Future<ApiResponse<void>> sendNotify(String? employeeName) async {
    final token = await HelperFunctions.getCompanyToken();
    return post<void>(
      ApiEndpoints.sendNotifications,
      token: token,
      data: {'employeeName': employeeName},
    );
  }
}
