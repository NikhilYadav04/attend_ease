import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class Locationmodel {
  String? latitude;
  String? longitude;
  String companyName;
  double radius;
  Locationmodel({
    required this.latitude,
    required this.longitude,
    required this.companyName,
    required this.radius,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
      'companyName': companyName,
      'radius': radius,
    };
  }

  factory Locationmodel.fromMap(Map<String, dynamic> map) {
    return Locationmodel(
      latitude: map['latitude'] as String,
      longitude: map['longitude'] as String,
      companyName: map['companyName'] as String,
      radius: map['radius'] as double,
    );
  }

  String toJson() => json.encode(toMap());

  factory Locationmodel.fromJson(String source) =>
      Locationmodel.fromMap(json.decode(source) as Map<String, dynamic>);
}
