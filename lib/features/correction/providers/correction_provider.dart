import 'package:attend_ease/core/providers/base_provider.dart';

class CorrectionProvider extends BaseProvider {
  List<dynamic> myCorrections = [];
  List<dynamic> pendingCorrections = [];

  void setMyCorrections(List<dynamic> list) {
    myCorrections = list;
    notifyListeners();
  }

  void setPendingCorrections(List<dynamic> list) {
    pendingCorrections = list;
    notifyListeners();
  }
}
