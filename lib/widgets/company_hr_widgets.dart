import 'package:attend_ease/constants/colors.dart';
import 'package:attend_ease/constants/scale.dart';
import 'package:attend_ease/globalobjects/variables.dart';
import 'package:attend_ease/helper/helper_functions.dart';
import 'package:attend_ease/screens/add_staff_screen.dart';
import 'package:attend_ease/screens/otp_auth_screen.dart';
import 'package:attend_ease/services/companyService.dart';
import 'package:attend_ease/widgets/otp_auth_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

final companyService CompanyService = companyService();

List<String> images = [
  "assets/location_screen/add.png",
  "assets/location_screen/list.png",
  "assets/location_screen/video.png",
  "assets/location_screen/tasks.png"
];

List<String> title = [
  "Add Staff",
  "Check Staff Report",
  "Video Meeting",
  "Staff Count"
];

List subtitle = [
  "Staff can mark attendance via phone",
  "Check every employee's attendance list",
  "Conduct video meet with your staff live",
  "Check Report of Total Staff Count "
];

DateTime now = DateTime.now();

PreferredSizeWidget appBHR(double width, double height, double textScale) {
  return AppBar(
    title: Row(
      children: [
        Icon(
          Icons.account_circle_sharp,
          color: Colors.grey.shade800,
          size: responsiveContainerSize(32, width, height),
        ),
        SizedBox(
          width: responsiveContainerSize(12, width, height),
        ),
        Text(
          "HR Screen",
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
              fontSize: responsiveFontSize(23, width, height, textScale)),
        ),
      ],
    ),
    actions: [
      IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.notifications_none,
            size: responsiveContainerSize(32, width, height),
          )),
      IconButton(
        onPressed: () {},
        icon: Icon(
          Icons.help,
          size: responsiveContainerSize(32, width, height),
        ),
      )
    ],
  );
}

List<Widget> actionsHR(
    double width, double height, double textScale, BuildContext context) {
  return [
    IconButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          responsiveBorderRadius(6, width, height))),
                  backgroundColor: BUTTON_COLOR_2,
                  title: Center(
                    child: Text(
                      "Submit Info!!",
                      style: GoogleFonts.notoSansOldHungarian(
                          fontSize: responsiveContainerSize(26, width, height),
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  content: Container(
                    height: responsiveContainerSize(130, width, height),
                    child: Center(
                      child: Text(
                        "Remember to submit your staff data every day before day ends, Once you submit the counts will reset to zero and it will be displayed in the list.",
                        style: GoogleFonts.notoSansOldHungarian(
                            fontSize:
                                responsiveContainerSize(18, width, height),
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              });
        },
        icon: Icon(
          Icons.notifications_none,
          size: responsiveContainerSize(32, width, height),
        )),
    IconButton(
      onPressed: () async {
        await HelperFunctions.setStatus(false);
        await HelperFunctions.setCompanyName("");
        await HelperFunctions.setCompanyID("");
        Navigator.push(
            context,
            PageTransition(
                child: OtpAuthScreen(), type: PageTransitionType.fade));
      },
      icon: Icon(
        Icons.exit_to_app_rounded,
        size: responsiveContainerSize(32, width, height),
      ),
    )
  ];
}

Widget appBtitleHR(double width, double height, double textScale) {
  return AppBar(
    title: Row(
      children: [
        Icon(
          Icons.account_circle_sharp,
          color: Colors.grey.shade800,
          size: responsiveContainerSize(32, width, height),
        ),
        SizedBox(
          width: responsiveContainerSize(12, width, height),
        ),
        Text(
          "${cName}",
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
              fontSize: responsiveFontSize(23, width, height, textScale)),
        ),
      ],
    ),
  );
}

Widget attendCountWidget(
    double width, double height, double textScale, void Function() ontap) {
  return Container(
    height: responsiveContainerSize(200, width, height),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(6),
      gradient: const LinearGradient(
        colors: [
          GRADIENT_1,
          GRADIENT_2,
          GRADIENT_1,
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
    ),
    child: Center(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: 45 *
                    horizontalPaddingFactor(
                      width,
                    ),
                vertical: 10 * verticalPaddingFactor(height)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    rowCOntent(width, height, textScale, "In", inCount),
                    rowCOntent(width, height, textScale, "Out", outCount),
                    rowCOntentDate(
                        width, height, textScale, "Date", currentDate)
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: responsiveContainerSize(10, width, height),
          ),
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: 15 * horizontalPaddingFactor(width)),
            child: Divider(
              color: Colors.grey.shade300,
              height: 1,
            ),
          ),
          SizedBox(
            height: responsiveContainerSize(10, width, height),
          ),
          rowContent2(width, height, textScale, ontap),
        ],
      ),
    ),
  );
}

Widget rowCOntent(
    double width, double height, double textScale, String title, int Count) {
  return Column(
    children: [
      Text(
        title,
        style: TextStyle(
            color: Colors.white,
            fontFamily: "Tansek",
            fontSize: responsiveFontSize(36, width, height, textScale)),
      ),
      SizedBox(
        height: responsiveContainerSize(12, width, height),
      ),
      Text(
        "$Count",
        style: GoogleFonts.aDLaMDisplay(
            color: Colors.white,
            fontSize: responsiveFontSize(28, width, height, textScale)),
      )
    ],
  );
}

Widget rowCOntentDate(
    double width, double height, double textScale, String title, String date) {
  return Column(
    children: [
      Text(
        title,
        style: TextStyle(
            color: Colors.white,
            fontFamily: "Tansek",
            fontSize: responsiveFontSize(36, width, height, textScale)),
      ),
      SizedBox(
        height: responsiveContainerSize(12, width, height),
      ),
      Text(
        date,
        style: GoogleFonts.aDLaMDisplay(
            color: Colors.white,
            fontSize: responsiveFontSize(28, width, height, textScale)),
      )
    ],
  );
}

Widget rowContent2(
    double width, double height, double textScale, void Function() ontap) {
  return Container(
    padding:
        EdgeInsets.symmetric(horizontal: 18 * horizontalPaddingFactor(width)),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Total Staff - ${totalCount}",
          style: TextStyle(
              color: Colors.white,
              fontFamily: "Tansek",
              fontSize: responsiveContainerSize(30, width, height)),
        ),
        GestureDetector(
          onTap: ontap,
          child: Text(
            isSubmit ? "Submitted" : "Submit Attendance  >",
            style: TextStyle(
                color: Colors.white,
                fontFamily: "Tansek",
                fontSize: responsiveContainerSize(30, width, height)),
          ),
        )
      ],
    ),
  );
}

Widget floatButton(
    double width, double height, double textScale, BuildContext context) {
  return Container(
    height: responsiveContainerSize(50, width, height),
    width: responsiveContainerSize(152, width, height),
    child: FloatingActionButton(
        elevation: 2,
        backgroundColor: BUTTON_COLOR_1,
        onPressed: () {
          Navigator.push(
              context,
              PageTransition(
                  child: AddStaffScreen(), type: PageTransitionType.fade));
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              color: Colors.white,
              size: responsiveContainerSize(28, width, height),
            ),
            Text(
              " Add Staff",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: responsiveFontSize(20, width, height, textScale)),
            ),
          ],
        )),
  );
}

Widget listWidget(
    double width, double height, double textScale, BuildContext context) {
  return Column(
    children: [
      Container(
        height: responsiveContainerSize(400, width, height),
        child: ListView.builder(
            itemCount: 4,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  SizedBox(
                    height: responsiveContainerSize(10, width, height),
                  ),
                  ListTile(
                    leading: Image.asset(
                      images[index],
                      height: responsiveContainerSize(32, width, height),
                      width: responsiveContainerSize(32, width, height),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: responsiveContainerSize(18, width, height),
                    ),
                    title: Text(
                      title[index],
                      style: GoogleFonts.notoSansOldHungarian(
                          color: Colors.black,
                          fontSize:
                              responsiveFontSize(18, width, height, textScale),
                          fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(subtitle[index],
                        style: GoogleFonts.roboto(
                          color: Colors.black,
                          fontSize:
                              responsiveFontSize(15, width, height, textScale),
                        )),
                  ),
                  SizedBox(
                    height: responsiveContainerSize(10, width, height),
                  ),
                  Divider(
                    indent: 10,
                    endIndent: 10,
                    color: Colors.grey.shade300,
                    height: 5,
                    thickness: 2,
                  ),
                ],
              );
            }),
      ),
    ],
  );
}

Widget approveTextEmployee(
    double width, double height, double textScale, String text) {
  return Center(
    child: Text(text,
        style: GoogleFonts.notoSansOldHungarian(
          color: Colors.grey.shade900,
          fontWeight: FontWeight.bold,
          fontSize: responsiveFontSize(35, width, height, textScale),
        )),
  );
}

Widget listApproval(double width, double height, double textScale,
    BuildContext context, List<dynamic> staffList) {
  return Column(
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
                child: staffTextText(width, height, textScale, "Staff Present"),
              )),
              TableCell(
                child: Container(
                    height: 50,
                    child: staffTextText(width, height, textScale, "Date")),
              ),
              TableCell(
                  child: Container(
                height: 50,
                child: staffTextText(width, height, textScale, "Total Staff"),
              )),
            ])
          ],
        ),
      ),
      ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: staffList.length,
          itemBuilder: (context, index) {
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
                          staffList[index]['totalCount'].toString()),
                    )),
                    TableCell(
                        child: Container(
                      height: 50,
                      child: staffTextText(width, height, textScale,
                          staffList[index]['currentDate']),
                    )),
                    TableCell(
                        child: Container(
                      height: 50,
                      child: staffTextText(width, height, textScale, "60"),
                    )),
                  ])
                ],
              ),
            );
          })
    ],
  );
}

Widget staffText(double width, double height, double textScale, String text) {
  return Center(
    child: Text(text,
        style: GoogleFonts.notoSansOldHungarian(
          color: Colors.grey.shade900,
          fontWeight: FontWeight.bold,
          fontSize: responsiveFontSize(30, width, height, textScale),
        )),
  );
}

Widget staffReport(
  double width,
  double height,
  double textScale,
  BuildContext context,
  List<dynamic> staffReport,
) {
  return Column(
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
                child: staffTextText(width, height, textScale, "Employee"),
              )),
              TableCell(
                  child: Container(
                height: 50,
                child: staffTextText(width, height, textScale, "Percentage"),
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
                    child: staffTextText(width, height, textScale, "Meeting")),
              ),
            ])
          ],
        ),
      ),
      ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: staffReport.length,
          itemBuilder: (context, index) {
            int attendPer = staffReport[index]['daysPresent'];
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
                          staffReport[index]['employeeName']),
                    )),
                    TableCell(
                        child: Container(
                      height: 50,
                      child:
                          staffTextText(width, height, textScale, "$attendP%"),
                    )),
                    TableCell(
                        child: Center(
                      child: InkWell(
                        onTap: attendPercent > 73.0 ? () {} : () {},
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              vertical: 10 * horizontalPaddingFactor(width)),
                          height: responsiveContainerSize(40, width, height),
                          width: responsiveContainerSize(95, width, height),
                          decoration: BoxDecoration(
                            color: attendPercent > 73.0
                                ? Colors.green
                                : Colors.red,
                            borderRadius: BorderRadius.circular(
                                responsiveBorderRadius(10, width, height)),
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
                        onTap: () {},
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              vertical: 10 * horizontalPaddingFactor(width)),
                          height: responsiveContainerSize(40, width, height),
                          width: responsiveContainerSize(95, width, height),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade400,
                            borderRadius: BorderRadius.circular(
                                responsiveBorderRadius(10, width, height)),
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
  );
}

Widget staffTextText(
    double width, double height, double textScale, String text) {
  return Center(
    child: Text(text,
        style: GoogleFonts.notoSansOldHungarian(
          color: Colors.grey.shade900,
          fontWeight: FontWeight.bold,
          fontSize: responsiveFontSize(17, width, height, textScale),
        )),
  );
}

Widget VideoCallField(double width, double height, double textScale,
    String title, TextEditingController controller) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: title,
      labelStyle: TextStyle(
          color: Colors.grey.shade800,
          fontWeight: FontWeight.bold,
          fontSize: responsiveFontSize(20, width, height, textScale)),
      enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade800),
          borderRadius:
              BorderRadius.circular(responsiveBorderRadius(4, width, height))),
      border: OutlineInputBorder(
          borderSide: const BorderSide(color: BUTTON_COLOR_1),
          borderRadius:
              BorderRadius.circular(responsiveBorderRadius(4, width, height))),
    ),
  );
}

Widget VideoCallJoinButton(
    double width, double height, double textScale, void Function() onTap) {
  return ElevatedButton(
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.blue)),
      onPressed: onTap,
      child: Center(
          child: Text(
        "Join",
        style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: responsiveFontSize(20, width, height, textScale)),
      )));
}
