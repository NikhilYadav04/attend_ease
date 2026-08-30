import 'package:attend_ease/core/providers/base_provider.dart';

class CorrectionProvider extends BaseProvider {
  List<dynamic> myCorrections = [];
  List<dynamic> pendingCorrections = [];
  List<dynamic> allCorrections = [];

  void setMyCorrections(List<dynamic> list) {
    myCorrections = list;
    notifyListeners();
  }

  void setPendingCorrections(List<dynamic> list) {
    pendingCorrections = list;
    notifyListeners();
  }

  void setAllCorrections(List<dynamic> list) {
    allCorrections = list;
    notifyListeners();
  }

  void appendAllCorrections(List<dynamic> list) {
    allCorrections = [...allCorrections, ...list];
    notifyListeners();
  }

  void reset() {
    myCorrections = [];
    pendingCorrections = [];
    allCorrections = [];
    notifyListeners();
  }
}
