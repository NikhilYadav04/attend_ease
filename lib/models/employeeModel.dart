import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class employeeModel {
  String employeeName;
  String employeeNumber;
  String employeePosition;
  String? employeeCompany;
  String? companyID;
  employeeModel({
    required this.employeeName,
    required this.employeeNumber,
    required this.employeePosition,
    required this.employeeCompany,
    required this.companyID,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'employeeName': employeeName,
      'employeeNumber': employeeNumber,
      'employeePosition': employeePosition,
      'employeeCompany': employeeCompany,
      'companyID': companyID,
    };
  }

  factory employeeModel.fromMap(Map<String, dynamic> map) {
    return employeeModel(
      employeeName: map['employeeName'] as String,
      employeeNumber: map['employeeNumber'] as String,
      employeePosition: map['employeePosition'] as String,
      employeeCompany: map['employeeCompany'] as String,
      companyID: map['companyID'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory employeeModel.fromJson(String source) =>
      employeeModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

class EmployeeJoinModel {
  String companyName;
  String companyID;
  String employeeName;
  EmployeeJoinModel({
    required this.companyName,
    required this.companyID,
    required this.employeeName,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'companyName': companyName,
      'companyID': companyID,
      'employeeName': employeeName,
    };
  }

  factory EmployeeJoinModel.fromMap(Map<String, dynamic> map) {
    return EmployeeJoinModel(
      companyName: map['companyName'] as String,
      companyID: map['companyID'] as String,
      employeeName: map['employeeName'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory EmployeeJoinModel.fromJson(String source) =>
      EmployeeJoinModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
