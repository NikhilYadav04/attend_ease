import 'package:attend_ease/constants/colors.dart';
import 'package:attend_ease/constants/scale.dart';
import 'package:attend_ease/globalobjects/variables.dart';
import 'package:attend_ease/services/companyService.dart';
import 'package:attend_ease/services/employeeService.dart';
import 'package:attend_ease/widgets/company_hr_widgets.dart';
import 'package:attend_ease/widgets/otp_auth_widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CompanyHrScreen1 extends StatefulWidget {
  const CompanyHrScreen1({super.key});

  @override
  State<CompanyHrScreen1> createState() => _CompanyHrScreen1State();
}

class _CompanyHrScreen1State extends State<CompanyHrScreen1> {
  final companyService CompanyService = companyService();
  DateTime now = DateTime.now();
  bool await = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getReport();
    getStaffReport();
    getStaffReportList();
    getCount();
    setState(() {
      await = false;
      inCount;
      outCount;
      totalCount;
    });
  }

  void getStaffReportList() async {
    staffList = await CompanyService.getCountList(cName);
    setState(() {
      staffList;
    });
  }

  void getStaffReport() async {
    var res = await CompanyService.getCountHistory(cName);
    if (res == "true") {
      setState(() {
        isSubmit;
        isSubmit = false;
        inCount = 0;
        outCount = 0;
        totalCount = 0;
      });
    } else {
      toastMessageError(context, "Error", res);
    }
  }

  void submit() async {
    var res = await CompanyService.storeCountHistory(
        cName, totalCount, DateFormat("dd MMMM").format(now));
    if (res == "Success") {
      toastMessageSuccess(context, "Success!", "Report Submitted");
      setState(() {
        isSubmit = true;
        inCount = 0;
        outCount = 0;
        totalCount = 0;
      });
    } else {
      toastMessageError(context, "Error!", res);
    }
  }

  void getCount() async {
    var res = await CompanyService.getCount(cName);
    setState(() {
      inCount;
      outCount;
      totalCount;
      currentDate = DateFormat("dd MMMM").format(now);
    });
  }

  void getReport() async {
    reportStaff = await CompanyService.getSTaff(cName);
  }

  int index = 0;
  @override
  Widget build(BuildContext context) {
    final currentHeight = MediaQuery.of(context).size.height;
    final currentWidth = MediaQuery.of(context).size.width;
    final textScale = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      body: SingleChildScrollView(
        child: await
            ? const Center(
                child: CircularProgressIndicator(
                  color: DARK_BLUE,
                ),
              )
            : Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 5 * horizontalPaddingFactor(currentWidth)),
                child: Column(
                  children: [
                    SizedBox(
                      height: responsiveContainerSize(
                          15, currentWidth, currentHeight),
                    ),
                    attendCountWidget(
                        currentWidth, currentHeight, textScale, submit),
                    SizedBox(
                      height: responsiveContainerSize(
                          25, currentWidth, currentHeight),
                    ),
                    Divider(
                      color: Colors.grey.shade300,
                      height: 5,
                      thickness: 2,
                      indent: 10,
                      endIndent: 10,
                    ),
                    SizedBox(
                      height: responsiveContainerSize(
                          10, currentWidth, currentHeight),
                    ),
                    listWidget(currentWidth, currentHeight, textScale, context)
                  ],
                ),
              ),
      ),
      floatingActionButton:
          floatButton(currentWidth, currentHeight, textScale, context),
    );
  }
}
