import 'dart:convert';

class CompanyModel {
  String companyName;
  String companyHR;
  String companyCity;
  String HRNumber;

  CompanyModel({
    required this.companyName,
    required this.companyHR,
    required this.companyCity,
    required this.HRNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'companyName': companyName,
      'companyHR': companyHR,
      'companyCity': companyCity,
      'HRNumber': HRNumber,
    };
  }

  String toJson() => json.encode(toMap());
}
