import 'package:attend_ease/constants/colors.dart';
import 'package:attend_ease/constants/scale.dart';
import 'package:attend_ease/globalobjects/variables.dart';
import 'package:attend_ease/helper/helper_functions.dart';
import 'package:attend_ease/screens/biom_auth.dart';
import 'package:attend_ease/services/attendanceService.dart';
import 'package:attend_ease/services/companyService.dart';
import 'package:attend_ease/services/employeeService.dart';
import 'package:attend_ease/services/locationService.dart';
import 'package:attend_ease/widgets/company_setup_screen_widgets.dart';
import 'package:attend_ease/widgets/employee_main_widgets.dart';
import 'package:attend_ease/widgets/otp_auth_widgets.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

// ignore: must_be_immutable
class EmployeeMainScreen2 extends StatefulWidget {
  double width;
  double height;
  double textScaleFactor;

  EmployeeMainScreen2({
    Key? key,
    required this.width,
    required this.height,
    required this.textScaleFactor,
  }) : super(key: key);

  @override
  State<EmployeeMainScreen2> createState() => _EmployeeMainScreen2State();
}

class _EmployeeMainScreen2State extends State<EmployeeMainScreen2> {
  bool locationVerified = false;

  final AttendanceService attendanceService = AttendanceService();
  final locationService LocationService = locationService();
  final companyService CompanyService = companyService();

  void verifyLocation() async {
    eCName = await HelperFunctions.getEmployeeCOmpany();
    String res = await LocationService.getLocation(eCName);
    if (res == "Success") {
      setState(() {
        eCName;
        Latitude1;
        Longitude1;
        radius;
      });
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        // ignore: unused_local_variable
        LocationPermission ask = await Geolocator.requestPermission();
      } else {
        Position currentPosition = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best);
        setState(() {
          Latitude2 = currentPosition.latitude;
          Longitude2 = currentPosition.longitude;
        });
      }

      double distance = Geolocator.distanceBetween(
          Latitude1, Longitude2, Latitude2, Longitude2);

      if (distance > radius) {
        toastMessageError(context, "Error!", "Stay within office location!!");
      } else {
        print("Latitude1 is ${Latitude1}");
        print("Longitude is ${Longitude1}");
        print("Latitude2 is ${Latitude2}");
        print("Longityude2 is ${Longitude2}");
        print("distanceis ${distance}");
        setState(() {
          locationVerified = true;
        });
      }
    } else {
      print(res);
      toastMessageError(context, "Error!", res);
    }
  }

  void InPressed() async {
    setState(() {
      DateTime now = DateTime.now();
      InTime = DateFormat('HH:mm').format(now);
      InTime_Display = InTime;
      toastMessageSuccess(context, "Time", InTime);
    });
    await HelperFunctions.setInTime(InTime);
    await CompanyService.changeCount(cName, 1, 0, 1);
  }

  void OutPressed() async {
    if (isAuthenticate) {
      setState(() {
        DateTime now = DateTime.now();
        if (InTime != "") {
          OutTime = DateFormat('HH:mm').format(now);
        }
        Date = DateFormat('dd/MM/yy').format(now);
        isPresent = true;
        TotalDays;
      });
      if (InTime != "00:00" && OutTime != "00:00") {
        InTime_Display = await HelperFunctions.getInTime();
        String res = await attendanceService.markAttendance(
            eName, InTime_Display, OutTime, Date, isPresent);
        if (res == "Success") {
          toastMessageSuccess(context, "Done!", "TIme Marked");
        } else {
          toastMessageError(context, "Sorry!", res);
        }
        await CompanyService.changeCount(cName, 0, 1, 0);
      }else{
        toastMessageError(context, "Invalid", "Authenticate Your Biometric ID");
      }
    } else {
      toastMessageError(context, "Mark !!", "Mark Your InTIme And OutTime");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    verifyLocation();

    setState(() {
      isAuthenticate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: BUTTON_COLOR_2,
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: responsiveContainerSize(0, widget.width, widget.height),
            ),
            upperBar(
                widget.width, widget.height, widget.textScaleFactor, context),
            cameraAuthenticate(
              () {
                Navigator.push(
                    context,
                    PageTransition(
                        child: BiomAuth(), type: PageTransitionType.fade));
              },
              widget.width,
              widget.height,
              widget.textScaleFactor,
              context,
              isAuthenticate,
              Text(
                isAuthenticate
                    ? "Your Biometric ID Is Verified"
                    : "Click Here For Biometric Authentication",
                style: GoogleFonts.notoSansOldHungarian(
                    fontSize: responsiveFontSize(21.5, widget.width,
                        widget.height, widget.textScaleFactor),
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ),
            isPresent
                ? attendCompleteText(
                    widget.width, widget.height, widget.textScaleFactor)
                : locationVerified
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          attendButtonIn(InPressed, widget.width, widget.height,
                              widget.textScaleFactor),
                          attendButtonOut(OutPressed, widget.width,
                              widget.height, widget.textScaleFactor),
                        ],
                      )
                    : LoadingAnimationWidget(
                        widget.width, widget.height, widget.textScaleFactor),
            isPresent
                ? locationWidget(widget.width, widget.height,
                    widget.textScaleFactor, "See You The Next Day....")
                : locationVerified
                    ? locationWidget(widget.width, widget.height,
                        widget.textScaleFactor, "Your Location is Verified...")
                    : locationWidget(
                        widget.width,
                        widget.height,
                        widget.textScaleFactor,
                        "Verifying Your Location Radius..."),
          ],
        ),
      ),
    );
  }
}
