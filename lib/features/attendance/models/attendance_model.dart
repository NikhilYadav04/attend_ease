import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class AttendanceModel {
  String? employeeName;
  String? InTime;
  String OutTime;
  String Date;
  bool isPresent;
  AttendanceModel({
    required this.employeeName,
    required this.InTime,
    required this.OutTime,
    required this.Date,
    required this.isPresent,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'employeeName': employeeName,
      'InTime': InTime,
      'OutTime': OutTime,
      'Date': Date,
      'isPresent': isPresent,
    };
  }

  factory AttendanceModel.fromMap(Map<String, dynamic> map) {
    return AttendanceModel(
      employeeName: map['employeeName'] as String,
      InTime: map['InTime'] as String,
      OutTime: map['OutTime'] as String,
      Date: map['Date'] as String,
      isPresent: map['isPresent'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory AttendanceModel.fromJson(String source) =>
      AttendanceModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

class GetAttendanceModel {
  String? employeeName;
  String Date;
  GetAttendanceModel({
    required this.employeeName,
    required this.Date,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'employeeName': employeeName,
      'Date': Date,
    };
  }

  factory GetAttendanceModel.fromMap(Map<String, dynamic> map) {
    return GetAttendanceModel(
      employeeName: map['employeeName'] as String,
      Date: map['Date'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory GetAttendanceModel.fromJson(String source) => GetAttendanceModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
