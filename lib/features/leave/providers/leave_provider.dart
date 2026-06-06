import 'package:attend_ease/core/providers/base_provider.dart';

class LeaveProvider extends BaseProvider {
  List<dynamic> myLeaves = [];
  List<dynamic> pendingLeaves = [];

  void setMyLeaves(List<dynamic> list) {
    myLeaves = list;
    notifyListeners();
  }

  void setPendingLeaves(List<dynamic> list) {
    pendingLeaves = list;
    notifyListeners();
  }
}
