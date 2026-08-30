import 'package:attend_ease/core/providers/base_provider.dart';

class CompanyProvider extends BaseProvider {
  int inCount = 0;
  int outCount = 0;
  int totalCount = 0;
  String currentDate = '';
  List<dynamic> reportStaff = [];
  List<dynamic> staffList = [];
  bool isSubmit = false;

  // location setup
  double sliderValue = 202.25;
  String? latitude;
  String? longitude;
  double radius = 0;
  double lat1 = 0;
  double lng1 = 0;
  String workStartTime = '';

  void updateCounts(int inC, int outC, int total) {
    inCount = inC;
    outCount = outC;
    totalCount = total;
    notifyListeners();
  }

  void setDate(String date) {
    currentDate = date;
    notifyListeners();
  }

  void setStaffReport(List<dynamic> list) {
    reportStaff = list;
    notifyListeners();
  }

  void setStaffList(List<dynamic> list) {
    staffList = list;
    notifyListeners();
  }

  void setSubmit(bool v) {
    isSubmit = v;
    notifyListeners();
  }

  void setCurrentLocation(String? lat, String? lng) {
    latitude = lat;
    longitude = lng;
    notifyListeners();
  }

  void setSlider(double v) {
    sliderValue = v;
    notifyListeners();
  }

  void setOfficeLocation(double lat, double lng, double r) {
    lat1 = lat;
    lng1 = lng;
    radius = r;
    notifyListeners();
  }

  void setWorkStartTime(String t) {
    workStartTime = t;
    notifyListeners();
  }

  void resetCounts() {
    inCount = 0;
    outCount = 0;
    totalCount = 0;
    notifyListeners();
  }

  void reset() {
    inCount = 0;
    outCount = 0;
    totalCount = 0;
    currentDate = '';
    reportStaff = [];
    staffList = [];
    isSubmit = false;
    sliderValue = 202.25;
    latitude = null;
    longitude = null;
    radius = 0;
    lat1 = 0;
    lng1 = 0;
    workStartTime = '';
    notifyListeners();
  }
}
