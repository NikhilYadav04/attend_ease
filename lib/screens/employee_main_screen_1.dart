import 'package:attend_ease/constants/scale.dart';
import 'package:attend_ease/globalobjects/variables.dart';
import 'package:attend_ease/services/attendanceService.dart';
import 'package:attend_ease/services/employeeService.dart';
import 'package:attend_ease/widgets/employee_main_widgets.dart';
import 'package:attend_ease/widgets/otp_auth_widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class EmployeeMainScreen1 extends StatefulWidget {
  double width;
  double height;
  double textScaleFactor;

  EmployeeMainScreen1({
    Key? key,
    required this.width,
    required this.height,
    required this.textScaleFactor,
  }) : super(key: key);

  @override
  State<EmployeeMainScreen1> createState() => _EmployeeMainScreen1State();
}

class _EmployeeMainScreen1State extends State<EmployeeMainScreen1> {
  final AttendanceService _attendanceService = AttendanceService();
  final Employeeservice employeeservice = Employeeservice();
  DateTime now = DateTime.now();
  void _getData() async {
    String res = await _attendanceService.getAttendance(
        eName,  DateFormat('dd/MM/yy').format(now));
    await _attendanceService.getAttendanceDays(eName);
    print("Totaldays id ${TotalDays}");
    if (res == "Success") {
      setState(() {
        InTime_Display;
        InTime;
        OutTime;
        isPresent;
        TotalDays;
      });
    } else {
      setState(() {
        InTime_Display="00:00";
        InTime = "00:00";
        OutTime = "00:00";
        isPresent = false;
        TotalDays = 0;
      });
      toastMessageError(context, "Error!", res);
    }
  }

  void getList() async {
    report = await employeeservice.getReport(eName);
    // print("List is ${report[0]["InTime"]}");
    //  print("List is ${report[0]["OutTime"]}");
    //  print(report.length);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getData();
    getList();
  }

  @override
  Widget build(BuildContext context) {
    final currentHeight = MediaQuery.of(context).size.height;
    final currentWidth = MediaQuery.of(context).size.width;
    // ignore: deprecated_member_use
    final textScale = MediaQuery.of(context).textScaleFactor;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: 5 * horizontalPaddingFactor(currentWidth)),
          child: Column(
            children: [
              SizedBox(
                height:
                    responsiveContainerSize(15, currentWidth, currentHeight),
              ),
              attendCountWidgetEmployee(currentWidth, currentHeight, textScale),
              SizedBox(
                height:
                    responsiveContainerSize(25, currentWidth, currentHeight),
              ),
              Divider(
                color: Colors.grey.shade300,
                height: 5,
                thickness: 2,
                indent: 10,
                endIndent: 10,
              ),
              SizedBox(
                height:
                    responsiveContainerSize(10, currentWidth, currentHeight),
              ),
              listWidgetEMployee(
                  currentWidth, currentHeight, textScale, context),
              Center(
                  child: companyButtonEmployee(
                      () {}, currentWidth, currentHeight, textScale, context))
            ],
          ),
        ),
      ),
    );
  }
}
