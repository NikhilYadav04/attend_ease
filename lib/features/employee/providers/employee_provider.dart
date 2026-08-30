import 'package:attend_ease/core/providers/base_provider.dart';

class EmployeeProvider extends BaseProvider {
  List<dynamic> report = [];

  void setReport(List<dynamic> r) {
    report = r;
    notifyListeners();
  }

  void reset() {
    report = [];
    notifyListeners();
  }
}
