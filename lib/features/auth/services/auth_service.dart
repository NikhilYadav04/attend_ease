import 'package:attend_ease/core/network/api_endpoints.dart';
import 'package:attend_ease/core/network/api_response.dart';
import 'package:attend_ease/core/network/api_service.dart';

class IdentifyResult {
  final String role; // 'hr' | 'employee' | 'none'
  final String? token;
  final String? companyName;
  final String? companyID;
  final String? adminName;
  final String? employeeName;
  final String? employeeID;
  final String? employeeCompany;

  IdentifyResult({
    required this.role,
    this.token,
    this.companyName,
    this.companyID,
    this.adminName,
    this.employeeName,
    this.employeeID,
    this.employeeCompany,
  });

  factory IdentifyResult.fromJson(dynamic json) {
    return IdentifyResult(
      role: json['role'] as String,
      token: json['token'] as String?,
      companyName: json['companyName'] as String?,
      companyID: json['companyID'] as String?,
      adminName: json['companyHR'] as String?,
      employeeName: json['employeeName'] as String?,
      employeeID: json['employeeID'] as String?,
      employeeCompany: json['employeeCompany'] as String?,
    );
  }
}

class AuthService extends ApiService {
  Future<ApiResponse<IdentifyResult>> identify(String phone, String otpToken) async {
    return post<IdentifyResult>(
      ApiEndpoints.identify,
      data: {'phone': phone, 'otpToken': otpToken},
      fromJson: IdentifyResult.fromJson,
    );
  }
}
