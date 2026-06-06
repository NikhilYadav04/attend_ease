import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class EmployeeModel {
  String employeeName;
  String employeeNumber;
  String employeePosition;
  EmployeeModel({
    required this.employeeName,
    required this.employeeNumber,
    required this.employeePosition,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'employeeName': employeeName,
      'employeeNumber': employeeNumber,
      'employeePosition': employeePosition,
    };
  }

  factory EmployeeModel.fromMap(Map<String, dynamic> map) {
    return EmployeeModel(
      employeeName: map['employeeName'] as String,
      employeeNumber: map['employeeNumber'] as String,
      employeePosition: map['employeePosition'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory EmployeeModel.fromJson(String source) =>
      EmployeeModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

class EmployeeJoinModel {
  String companyName;
  String employeeID;
  String employeeName;
  EmployeeJoinModel({
    required this.companyName,
    required this.employeeID,
    required this.employeeName,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'companyName': companyName,
      'employeeID': employeeID,
      'employeeName': employeeName,
    };
  }

  factory EmployeeJoinModel.fromMap(Map<String, dynamic> map) {
    return EmployeeJoinModel(
      companyName: map['companyName'] as String,
      employeeID: map['employeeID'] as String,
      employeeName: map['employeeName'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory EmployeeJoinModel.fromJson(String source) =>
      EmployeeJoinModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
