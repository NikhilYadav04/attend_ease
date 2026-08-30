import 'package:attend_ease/core/providers/base_provider.dart';

class LeaveProvider extends BaseProvider {
  List<dynamic> myLeaves = [];
  List<dynamic> pendingLeaves = [];
  List<dynamic> allLeaves = [];

  void setMyLeaves(List<dynamic> list) {
    myLeaves = list;
    notifyListeners();
  }

  void setPendingLeaves(List<dynamic> list) {
    pendingLeaves = list;
    notifyListeners();
  }

  void setAllLeaves(List<dynamic> list) {
    allLeaves = list;
    notifyListeners();
  }

  void appendAllLeaves(List<dynamic> list) {
    allLeaves = [...allLeaves, ...list];
    notifyListeners();
  }

  void reset() {
    myLeaves = [];
    pendingLeaves = [];
    allLeaves = [];
    notifyListeners();
  }
}
