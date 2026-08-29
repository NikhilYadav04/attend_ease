import 'package:attend_ease/core/network/api_endpoints.dart';
import 'package:attend_ease/core/network/api_response.dart';
import 'package:attend_ease/core/network/api_service.dart';
import 'package:attend_ease/core/storage/local_storage.dart';
import 'package:attend_ease/features/employee/models/employee_model.dart';

class EmployeeService extends ApiService {
  // Add employee — POST, company token
  Future<ApiResponse<void>> addEmployee(
      String employeeName,
      String employeeNumber,
      String employeePosition) async {
    final token = await HelperFunctions.getCompanyToken();
    EmployeeModel model = EmployeeModel(
        employeeName: employeeName,
        employeeNumber: employeeNumber,
        employeePosition: employeePosition);

    return post<void>(
      ApiEndpoints.addEmployee,
      token: token,
      data: model.toMap(),
    );
  }

  // Remove employee — POST, company token
  Future<ApiResponse<void>> removeEmployee(String employeeName) async {
    final token = await HelperFunctions.getCompanyToken();
    return post<void>(
      ApiEndpoints.removeEmployee,
      token: token,
      data: {'employeeName': employeeName},
    );
  }

  // Bulk-add employees — POST, company token. Returns per-row results.
  Future<ApiResponse<List<dynamic>>> bulkAddEmployees(
      List<Map<String, String>> employees) async {
    final token = await HelperFunctions.getCompanyToken();
    return post<List<dynamic>>(
      ApiEndpoints.bulkAddEmployees,
      token: token,
      data: {'employees': employees},
      fromJson: (json) => json as List<dynamic>,
    );
  }

  // Join company — POST, no auth, returns token
  Future<ApiResponse<String>> joinCompany(String employeeCompany,
      String employeeID, String employeeName, String otpToken) async {
    EmployeeJoinModel joinModel = EmployeeJoinModel(
        companyName: employeeCompany,
        employeeID: employeeID,
        employeeName: employeeName);

    return post<String>(
      ApiEndpoints.joinEmployee,
      data: {...joinModel.toMap(), 'otpToken': otpToken},
      fromJson: (json) => json['token'] as String,
    );
  }

  // List company holidays — GET, employee token
  Future<ApiResponse<List<dynamic>>> getHolidays() async {
    final token = await HelperFunctions.getEmployeeToken();
    return get<List<dynamic>>(
      ApiEndpoints.listHolidays,
      token: token,
      fromJson: (json) => json as List<dynamic>,
    );
  }

  // Get attendance report — GET, employee token
  Future<ApiResponse<List<dynamic>>> getReport() async {
    final token = await HelperFunctions.getEmployeeToken();
    return get<List<dynamic>>(
      ApiEndpoints.reportEmployee,
      token: token,
      fromJson: (json) => json as List<dynamic>,
    );
  }
}
