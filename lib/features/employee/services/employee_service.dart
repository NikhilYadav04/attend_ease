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

  // Join company — POST, no auth, returns token
  Future<ApiResponse<String>> joinCompany(
      String employeeCompany, String employeeID, String employeeName) async {
    EmployeeJoinModel joinModel = EmployeeJoinModel(
        companyName: employeeCompany,
        employeeID: employeeID,
        employeeName: employeeName);

    return post<String>(
      ApiEndpoints.joinEmployee,
      data: joinModel.toMap(),
      fromJson: (json) => json['token'] as String,
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
