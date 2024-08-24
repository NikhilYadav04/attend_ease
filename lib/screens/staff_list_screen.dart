import 'package:attend_ease/constants/colors.dart';
import 'package:attend_ease/constants/scale.dart';
import 'package:attend_ease/globalobjects/controllers.dart';
import 'package:attend_ease/globalobjects/variables.dart';
import 'package:attend_ease/screens/video_call_screen.dart';
import 'package:attend_ease/widgets/company_hr_widgets.dart';
import 'package:attend_ease/widgets/otp_auth_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';

class StaffListScreen extends StatefulWidget {
  const StaffListScreen({super.key});

  @override
  State<StaffListScreen> createState() => _StaffListScreenState();
}

class _StaffListScreenState extends State<StaffListScreen> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    // ignore: deprecated_member_use
    final textScale = MediaQuery.of(context).textScaleFactor;
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: 3 * horizontalPaddingFactor(height)),
        child: Column(
          children: [
            SizedBox(
              height: responsiveContainerSize(15, width, height),
            ),
            staffText(width, height, textScale, "Staff Report"),
            SizedBox(
              height: responsiveContainerSize(20, width, height),
            ),
            // staffReport(
            //     currentWidth, currentHeight, textScale, context,reportStaff)
            Column(
              children: [
                Container(
                  color: BUTTON_COLOR_1,
                  child: Table(
                    border: TableBorder.all(
                      color: Colors.black,
                      style: BorderStyle.solid,
                      width: 1,
                    ),
                    children: [
                      TableRow(children: [
                        TableCell(
                            child: Container(
                          height: 50,
                          child: staffTextText(
                              width, height, textScale, "Employee"),
                        )),
                        TableCell(
                            child: Container(
                          height: 50,
                          child: staffTextText(
                              width, height, textScale, "Percentage"),
                        )),
                        TableCell(
                          child: Container(
                              height: 50,
                              child: staffTextText(
                                  width, height, textScale, "Notification")),
                        ),
                        TableCell(
                          child: Container(
                              height: 50,
                              child: staffTextText(
                                  width, height, textScale, "Meeting")),
                        ),
                      ])
                    ],
                  ),
                ),
                ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: reportStaff.length,
                    itemBuilder: (context, index) {
                      int attendPer = reportStaff[index]['daysPresent'];
                      attendPer = attendPer % 30;
                      double attendPercent = (attendPer / 30) * 100;
                      String attendP = attendPercent.toStringAsFixed(2);
                      return Container(
                        child: Table(
                          border: TableBorder.all(
                            color: Colors.black,
                            style: BorderStyle.solid,
                            width: 1,
                          ),
                          children: [
                            TableRow(children: [
                              TableCell(
                                  child: Container(
                                height: 50,
                                child: staffTextText(width, height, textScale,
                                    reportStaff[index]['employeeName']),
                              )),
                              TableCell(
                                  child: Container(
                                height: 50,
                                child: Center(
                                  child: Text("$attendP%",
                                      style: GoogleFonts.notoSansOldHungarian(
                                        color: attendPercent > 75.0
                                            ? Colors.green
                                            : Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: responsiveFontSize(
                                            20, width, height, textScale),
                                      )),
                                ),
                                //  staffTextText(

                                //     width, height, textScale, "$attendP%",
                                //     ),
                              )),
                              TableCell(
                                  child: Center(
                                child: GestureDetector(
                                  onTap: () async {
                                    var res = await CompanyService.sendNotify(
                                        reportStaff[index]['employeeName']);
                                    if (res.length == 10) {
                                      toastMessageSuccess(context, "Success",
                                          "Notification Sent!!");
                                    } else {
                                      toastMessageError(context, "Error", res);
                                    }
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(
                                        vertical: 10 *
                                            horizontalPaddingFactor(width)),
                                    height: responsiveContainerSize(
                                        40, width, height),
                                    width: responsiveContainerSize(
                                        95, width, height),
                                    decoration: BoxDecoration(
                                      color: attendPercent > 73.0
                                          ? Colors.green
                                          : Colors.red,
                                      borderRadius: BorderRadius.circular(
                                          responsiveBorderRadius(
                                              10, width, height)),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Send Alert",
                                        style: GoogleFonts.notoSansOldHungarian(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: responsiveFontSize(
                                                15, width, height, textScale)),
                                      ),
                                    ),
                                  ),
                                ),
                              )),
                              TableCell(
                                  child: Center(
                                child: InkWell(
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        responsiveBorderRadius(
                                                            6, width, height))),
                                            backgroundColor: BUTTON_COLOR_2,
                                            title: Center(
                                              child: Text(
                                                "Setup Video Call",
                                                style: GoogleFonts
                                                    .notoSansOldHungarian(
                                                        fontSize:
                                                            responsiveContainerSize(
                                                                26,
                                                                width,
                                                                height),
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold),
                                              ),
                                            ),
                                            content: Container(
                                                height: responsiveContainerSize(
                                                    200, width, height),
                                                child: Column(
                                                  children: [
                                                    VideoCallField(
                                                        width,
                                                        height,
                                                        textScale,
                                                        "Enter Call ID",
                                                        CallIDController),
                                                    SizedBox(
                                                      height:
                                                          responsiveContainerSize(
                                                              20,
                                                              width,
                                                              height),
                                                    ),
                                                    VideoCallField(
                                                        width,
                                                        height,
                                                        textScale,
                                                        "Enter Username",
                                                        UserNameController),
                                                    SizedBox(
                                                      height:
                                                          responsiveContainerSize(
                                                              20,
                                                              width,
                                                              height),
                                                    ),
                                                    VideoCallJoinButton(width,
                                                        height, textScale, () {
                                                      Navigator.push(
                                                          context,
                                                          PageTransition(
                                                              child: CallScreen(
                                                                  CallID: CallIDController
                                                                      .text
                                                                      .toString(),
                                                                  Username:
                                                                      UserNameController
                                                                          .text
                                                                          .toString()),
                                                              type:
                                                                  PageTransitionType
                                                                      .fade));
                                                      setState(() {
                                                        CallIDController
                                                            .clear();
                                                        UserNameController
                                                            .clear();
                                                      });
                                                    })
                                                  ],
                                                )),
                                          );
                                        });
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(
                                        vertical: 10 *
                                            horizontalPaddingFactor(width)),
                                    height: responsiveContainerSize(
                                        40, width, height),
                                    width: responsiveContainerSize(
                                        95, width, height),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade400,
                                      borderRadius: BorderRadius.circular(
                                          responsiveBorderRadius(
                                              10, width, height)),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Video Meet",
                                        style: GoogleFonts.notoSansOldHungarian(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: responsiveFontSize(
                                                15, width, height, textScale)),
                                      ),
                                    ),
                                  ),
                                ),
                              )),
                            ])
                          ],
                        ),
                      );
                    })
              ],
            )
          ],
        ),
      ),
    );
  }
}
