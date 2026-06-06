import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class LocationModel {
  String? latitude;
  String? longitude;
  double radius;
  String? workStartTime;

  LocationModel({
    required this.latitude,
    required this.longitude,
    required this.radius,
    this.workStartTime,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
    };
    if (workStartTime != null && workStartTime!.isNotEmpty) {
      map['workStartTime'] = workStartTime;
    }
    return map;
  }

  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel(
      latitude: map['latitude'] as String,
      longitude: map['longitude'] as String,
      radius: map['radius'] as double,
      workStartTime: map['workStartTime'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory LocationModel.fromJson(String source) =>
      LocationModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
