import 'package:attend_ease/core/providers/base_provider.dart';

class AttendanceProvider extends BaseProvider {
  String inTime = '';
  String inTimeDisplay = '00:00';
  String outTime = '';
  String date = '';
  bool isPresent = false;
  int totalDays = 0;
  double lat2 = 0;
  double lng2 = 0;

  void setInTime(String t) {
    inTime = t;
    inTimeDisplay = t;
    notifyListeners();
  }

  void setInTimeDisplay(String t) {
    inTimeDisplay = t;
    notifyListeners();
  }

  void setOutTime(String t) {
    outTime = t;
    notifyListeners();
  }

  void setDate(String d) {
    date = d;
    notifyListeners();
  }

  void setPresent(bool v) {
    isPresent = v;
    notifyListeners();
  }

  void setTotalDays(int v) {
    totalDays = v;
    notifyListeners();
  }

  void setCurrentPosition(double lat, double lng) {
    lat2 = lat;
    lng2 = lng;
    notifyListeners();
  }

  void reset() {
    inTime = '';
    inTimeDisplay = '00:00';
    outTime = '';
    date = '';
    isPresent = false;
    totalDays = 0;
    notifyListeners();
  }
}
