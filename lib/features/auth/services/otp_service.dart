import 'package:attend_ease/core/network/api_endpoints.dart';
import 'package:attend_ease/core/network/api_response.dart';
import 'package:attend_ease/core/network/api_service.dart';

class OtpService extends ApiService {
  Future<ApiResponse<void>> sendOTP(String phoneNumber) async {
    return post<void>(
      ApiEndpoints.sendOtp,
      data: {'phoneNumber': phoneNumber},
    );
  }

  Future<ApiResponse<String>> verifyOTP(String phoneNumber, String otp) async {
    return post<String>(
      ApiEndpoints.verifyOtp,
      data: {'phoneNumber': phoneNumber, 'otp': otp},
      fromJson: (json) => json['otpToken'] as String,
    );
  }
}
