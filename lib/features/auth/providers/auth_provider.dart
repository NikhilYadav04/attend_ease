import 'package:attend_ease/core/providers/base_provider.dart';
import 'package:attend_ease/core/storage/local_storage.dart';

class AuthProvider extends BaseProvider {
  // ── OTP / auth form state ──────────────────────────────────────────────────
  String phoneNumber = '';
  String otp = '';
  bool isAuthenticated = false;

  void setPhoneNumber(String v) {
    phoneNumber = v;
    notifyListeners();
  }

  void setOtp(String v) {
    otp = v;
    notifyListeners();
  }

  void setAuthenticated(bool v) {
    isAuthenticated = v;
    notifyListeners();
  }

  // ── Session state ──────────────────────────────────────────────────────────
  String? phone;
  String? cName;
  String? cID;
  String? adminName;
  String? eName;
  String? eID;
  String? eCName;

  bool get isCompanySession => cName != null && cName!.isNotEmpty;
  bool get isEmployeeSession => eName != null && eName!.isNotEmpty;

  Future<void> loadFromStorage() async {
    phone = await HelperFunctions.getPhone();
    cName = await HelperFunctions.getCompanyName();
    cID = await HelperFunctions.getCompanyID();
    adminName = await HelperFunctions.getAdminName();
    eName = await HelperFunctions.getEmployeeName();
    eID = await HelperFunctions.getEmployeeID();
    eCName = await HelperFunctions.getEmployeeCompany();
    notifyListeners();
  }

  void setCompanySession(String name, String id, {String? admin}) {
    cName = name;
    cID = id;
    if (admin != null) adminName = admin;
    notifyListeners();
  }

  void setEmployeeSession(String name, String id, String company) {
    eName = name;
    eID = id;
    eCName = company;
    notifyListeners();
  }

  Future<void> clearSession() async {
    await HelperFunctions.setStatus(false);
    await HelperFunctions.setPhone('');
    await HelperFunctions.setCompanyName('');
    await HelperFunctions.setCompanyID('');
    await HelperFunctions.setEmployeeName('');
    await HelperFunctions.setEmployeeID('');
    await HelperFunctions.setCompanyToken('');
    await HelperFunctions.setEmployeeToken('');
    phone = null;
    cName = null;
    cID = null;
    eName = null;
    eID = null;
    eCName = null;
    notifyListeners();
  }
}
