import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore: camel_case_types
class attendanceModel {
  String? employeeName;
  String? InTime;
  String OutTime;
  String Date;
  bool isPresent;
  attendanceModel({
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

  factory attendanceModel.fromMap(Map<String, dynamic> map) {
    return attendanceModel(
      employeeName: map['employeeName'] as String,
      InTime: map['InTime'] as String,
      OutTime: map['OutTime'] as String,
      Date: map['Date'] as String,
      isPresent: map['isPresent'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory attendanceModel.fromJson(String source) =>
      attendanceModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

class getAttendanceModel {
  String? employeeName;
  String Date;
  getAttendanceModel({
    required this.employeeName,
    required this.Date,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'employeeName': employeeName,
      'Date': Date,
    };
  }

  factory getAttendanceModel.fromMap(Map<String, dynamic> map) {
    return getAttendanceModel(
      employeeName: map['employeeName'] as String,
      Date: map['Date'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory getAttendanceModel.fromJson(String source) => getAttendanceModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
