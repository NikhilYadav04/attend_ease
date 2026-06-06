import 'package:attend_ease/core/network/api_endpoints.dart';
import 'package:attend_ease/core/network/api_response.dart';
import 'package:attend_ease/core/network/api_service.dart';
import 'package:attend_ease/core/storage/local_storage.dart';
import 'package:attend_ease/features/attendance/models/location_model.dart';

class LocationService extends ApiService {
  // Set location — POST, company token
  Future<ApiResponse<void>> setLocation(
      String? latitude, String? longitude, double radius,
      {String workStartTime = ''}) async {
    final token = await HelperFunctions.getCompanyToken();
    LocationModel locationBody = LocationModel(
      latitude: latitude,
      longitude: longitude,
      radius: radius,
      workStartTime: workStartTime.isNotEmpty ? workStartTime : null,
    );

    return post<void>(
      ApiEndpoints.setLocation,
      token: token,
      data: locationBody.toMap(),
    );
  }

  // Get location — GET, employee token
  Future<ApiResponse<Map<String, dynamic>>> getLocation() async {
    final token = await HelperFunctions.getEmployeeToken();
    return get<Map<String, dynamic>>(
      ApiEndpoints.getLocation,
      token: token,
      fromJson: (json) => {
        'latitude': double.parse(json['latitude'].toString()),
        'longitude': double.parse(json['longitude'].toString()),
        'radius': (json['radius'] as num).toDouble(),
        'workStartTime': json['workStartTime']?.toString() ?? '',
      },
    );
  }

  // Get company's own location — GET, company token
  Future<ApiResponse<Map<String, dynamic>>> getCompanyLocation() async {
    final token = await HelperFunctions.getCompanyToken();
    return get<Map<String, dynamic>>(
      ApiEndpoints.getCompanyLocation,
      token: token,
      fromJson: (json) => {
        'latitude': double.parse(json['latitude'].toString()),
        'longitude': double.parse(json['longitude'].toString()),
        'radius': (json['radius'] as num).toDouble(),
        'workStartTime': json['workStartTime']?.toString() ?? '',
      },
    );
  }
}
