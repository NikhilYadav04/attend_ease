import 'package:attend_ease/constants/colors.dart';
import 'package:attend_ease/constants/scale.dart';
import 'package:attend_ease/globalobjects/variables.dart';
import 'package:attend_ease/helper/helper_functions.dart';
import 'package:attend_ease/screens/otp_auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:table_calendar/table_calendar.dart';

List<String> imagesEmployee = [
  "assets/location_screen/face.png",
  "assets/location_screen/group.png",
  "assets/location_screen/list.png",
];

List<String> titleEmployee = [
  "Mark Attendance",
  "Check Other Staff",
  "Check Attendance History",
];

List subtitleEmployee = [
  "Mark your Attendance for Today ( Face )",
  "Check other employee's attendance list",
  "Check your Attendance History Report",
];

Widget appBartitle(
  double width,
  double height,
  double textScale,
) {
  return Row(
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
        "${eName}",
        style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: responsiveFontSize(23, width, height, textScale)),
      ),
    ],
  );
}

List<Widget> actions(
    double width, double height, double textScale, BuildContext context) {
  return [
    IconButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        icon: Icon(
          Icons.notifications_none,
          size: responsiveContainerSize(32, width, height),
        )),
    IconButton(
      onPressed: () async {
        await HelperFunctions.setStatus(false);
        await HelperFunctions.setEMployeeName("");
        await HelperFunctions.setEMployeeID("");
        Navigator.push(
            context,
            PageTransition(
                child: OtpAuthScreen(), type: PageTransitionType.fade));
      },
      icon: Icon(
        Icons.exit_to_app,
        size: responsiveContainerSize(32, width, height),
      ),
    ),
  ];
}

Widget upperBar(
    double width, double height, double textScale, BuildContext context) {
  return Container(
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(
        bottom: BorderSide(
          color: Colors.red, // Choose your color here
          width: 5.0, // Choose the width of the border
        ),
      ),
    ),
    padding: EdgeInsets.symmetric(
        horizontal: 10 * horizontalPaddingFactor(width),
        vertical: 5 * verticalPaddingFactor(height)),
    height: responsiveContainerSize(110, width, height),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Mark Your Attendance",
                style: GoogleFonts.notoSansOldHungarian(
                  color: Colors.grey.shade900,
                  fontWeight: FontWeight.bold,
                  fontSize: responsiveFontSize(22, width, height, textScale),
                )),
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
                              "Stay Within Radius",
                              style: GoogleFonts.notoSansOldHungarian(
                                  fontSize: responsiveContainerSize(
                                      26, width, height),
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          content: Container(
                            height: responsiveContainerSize(130, width, height),
                            child: Center(
                              child: Text(
                                "Please stay within 100 to 500 m from office location otherwise you will be not able to mark attendance . ",
                                style: GoogleFonts.notoSansOldHungarian(
                                    fontSize: responsiveContainerSize(
                                        18, width, height),
                                    color: Colors.grey.shade800,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        );
                      });
                },
                icon: Icon(
                  Icons.help,
                  size: responsiveContainerSize(32, width, height),
                )),
          ],
        ),
        SizedBox(
          height: responsiveContainerSize(15, width, height),
        ),
        dateWidget(width, height, textScale)
      ],
    ),
  );
}

Widget dateWidget(double width, double height, double textScale) {
  return Center(
    child: RichText(
      text: TextSpan(
        text: '24 August  ',
        style: GoogleFonts.notoSansOldHungarian(
          color: Colors.grey.shade900,
          fontWeight: FontWeight.w600,
          fontSize: responsiveFontSize(20, width, height, textScale),
        ),
        children: <TextSpan>[
          TextSpan(
            text: isPresent ? "Present" : "Absent",
            style: GoogleFonts.notoSansOldHungarian(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: responsiveFontSize(20, width, height, textScale),
            ),
          )
        ],
      ),
    ),
  );
}

Widget cameraAuthenticate(void Function() onTap, double width, double height,
    double textScale, BuildContext context, bool isAuthenticate, Text text) {
  return Container(
    decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.red, width: 5))),
    padding: EdgeInsets.symmetric(
        horizontal: 5 * horizontalPaddingFactor(width),
        vertical: 15 * verticalPaddingFactor(height)),
    child: Column(
      children: [
        SizedBox(
          height: responsiveContainerSize(64, width, height),
        ),
        Center(
          child: Image.asset(
            "assets/home_screen/biom.png",
            height: responsiveContainerSize(140, width, height),
            width: responsiveContainerSize(140, width, height),
          ),
        ),
        SizedBox(
          height: responsiveContainerSize(20, width, height),
        ),
        cameraButton(onTap, width, height, textScale, context),
        SizedBox(
          height: responsiveContainerSize(20, width, height),
        ),
        text,
        SizedBox(
          height: responsiveContainerSize(100, width, height),
        ),
      ],
    ),
  );
}

Widget attendButtonIn(
    void Function() onTap, double width, double height, double textScale) {
  return InkWell(
    onTap: onTap,
    child: Container(
      height: responsiveContainerSize(90, width, height),
      color: Colors.grey.shade900,
      child: buttonWIdget(onTap, width, height, textScale, "Punch In"),
    ),
  );
}

Widget attendButtonOut(
    void Function() onTap, double width, double height, double textScale) {
  return InkWell(
    onTap: onTap,
    child: Container(
      height: responsiveContainerSize(90, width, height),
      color: Colors.grey.shade900,
      child: buttonWIdget(onTap, width, height, textScale, "Punch Out"),
    ),
  );
}

Widget buttonWIdget(
  void Function() onTap,
  double width,
  double height,
  double textScaleFactor,
  String title,
) {
  return InkWell(
    onTap: onTap,
    child: Container(
      margin: EdgeInsets.symmetric(
          horizontal: 20 * horizontalPaddingFactor(width),
          vertical: 20 * verticalPaddingFactor(height)),
      padding: EdgeInsets.symmetric(
          horizontal: 12 * horizontalPaddingFactor(width),
          vertical: 5 * verticalPaddingFactor(height)),
      height: responsiveContainerSize(30, width, height),
      decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(responsiveBorderRadius(2, width, height)),
          color: BUTTON_COLOR_1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
                color: Colors.white,
                fontSize:
                    responsiveFontSize(21, width, height, textScaleFactor),
                fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: Icon(
              Icons.back_hand,
              color: Colors.white,
              size: responsiveContainerSize(23, width, height),
            ),
            onPressed: () {},
          )
        ],
      ),
    ),
  );
}

Widget locationWidget(
    double width, double height, double textScale, String text) {
  return Container(
    height: responsiveContainerSize(55, width, height),
    color: Colors.blue.shade300,
    child: Center(
      child: Text(
        text,
        style: TextStyle(
            color: Colors.black,
            fontSize: responsiveFontSize(22, width, height, textScale),
            fontWeight: FontWeight.bold),
      ),
    ),
  );
}

Widget tableText(double width, double height, double textScale, String text) {
  return Center(
    child: Text(
      text,
      style: TextStyle(
          fontFamily: "Kumbh-Med",
          fontWeight: FontWeight.bold,
          fontSize: responsiveFontSize(17, width, height, textScale)),
      // style: GoogleFonts.notoSansOldHungarian(
      //   color: Colors.grey.shade900,
      //   fontWeight: FontWeight.bold,
      //   fontSize: responsiveFontSize(16, width, height, textScale),
      // )
    ),
  );
}

Widget attendanceText(
    double width, double height, double textScale, String text) {
  return Container(
    child: Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: GoogleFonts.montserrat(
                shadows: [
                  Shadow(
                      color: Colors.yellow,
                      blurRadius: responsiveBorderRadius(2, width, height))
                ],
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: responsiveFontSize(30, width, height, textScale)),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.calendar_month),
            iconSize: responsiveContainerSize(35, width, height),
          )
        ],
      ),
    ),
  );
}

Widget attendanceReport(double width, double height, double textScale,
    BuildContext context, List<dynamic> report) {
  print("List is ${report}");
  return Column(
    children: [
      ListView.builder(
          shrinkWrap: true,
          itemCount: report.length,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Container(
              margin: EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                border: Border.all(
                  color: Colors.black,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  radius: responsiveBorderRadius(17, width, height),
                  backgroundColor: Colors.blue,
                  child: Center(
                    child: Text(
                      "${index + 1}",
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: "Kumbh-Med",
                          fontWeight: FontWeight.bold,
                          fontSize: responsiveFontSize(
                              16.5, width, height, textScale)),
                    ),
                  ),
                ),
                title: Text(
                    style: TextStyle(
                        color: Colors.black,
                        fontFamily: "Kumbh-Med",
                        fontWeight: FontWeight.bold,
                        fontSize:
                            responsiveFontSize(18, width, height, textScale)),
                    report[index]["Date"]),
                trailing: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      report[index]["InTime"],
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: "Kumbh-Med",
                          fontWeight: FontWeight.bold,
                          fontSize:
                              responsiveFontSize(18, width, height, textScale)),
                    ),
                    Text(
                      report[index]["OutTime"],
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: "Kumbh-Med",
                          fontWeight: FontWeight.bold,
                          fontSize:
                              responsiveFontSize(18, width, height, textScale)),
                    ),
                  ],
                ),
              ),
            );
          })
    ],
  );
  // return Column(
  //   children: [
  //     Container(
  //       color: BUTTON_COLOR_1,
  //       child: Table(
  //         border: TableBorder.all(
  //           color: Colors.black,
  //           style: BorderStyle.solid,
  //           width: 1,
  //         ),
  //         children: [
  //           TableRow(children: [
  //             TableCell(
  //                 child: Container(
  //               height: 50,
  //               child: tableText(width, height, textScale, "In Time"),
  //             )),
  //             TableCell(
  //                 child: Container(
  //               height: 50,
  //               child: tableText(width, height, textScale, "Out Time"),
  //             )),
  //             TableCell(
  //                 child: Container(
  //               height: 50,
  //               child: tableText(width, height, textScale, "Date"),
  //             )),
  //             TableCell(
  //               child: Container(
  //                   height: 50,
  //                   child: tableText(width, height, textScale, "Status")),
  //             )
  //           ])
  //         ],
  //       ),
  //     ),
  //     ListView.builder(
  //         shrinkWrap: true,
  //         physics: NeverScrollableScrollPhysics(),
  //         itemCount: report.length,
  //         itemBuilder: (context, index) {
  //           return Container(
  //             child: Table(
  //               border: TableBorder.all(
  //                 color: Colors.black,
  //                 style: BorderStyle.solid,
  //                 width: 1,
  //               ),
  //               children: [
  //                 TableRow(children: [
  //                   TableCell(
  //                       child: Container(
  //                     height: 50,
  //                     child: tableText(
  //                         width, height, textScale, report[index]["InTime"]),
  //                   )),
  //                   TableCell(
  //                       child: Container(
  //                     height: 50,
  //                     child: tableText(
  //                         width, height, textScale, report[index]["OutTime"]),
  //                   )),
  //                   TableCell(
  //                       child: Container(
  //                     height: 50,
  //                     child: tableText(
  //                         width, height, textScale, report[index]["Date"]),
  //                   )),
  //                   TableCell(
  //                     child: Container(
  //                         height: 50,
  //                         child: tableText(width, height, textScale,
  //                             report[index]["isPresent"].toString())),
  //                   )
  //                 ])
  //               ],
  //             ),
  //           );
  //         })
  //   ],
  // );
}

Widget attendCountWidgetEmployee(
    double width, double height, double textScale) {
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
                    rowCOntentEmployee1(
                        width, height, textScale, "In", InTime_Display),
                    rowCOntentEmployee(
                        width, height, textScale, "Out", OutTime),
                    rowCOntentEmployee(
                        width, height, textScale, "Status", "Yes")
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
          rowContentEMployee2(width, height, textScale),
        ],
      ),
    ),
  );
}

Widget rowCOntentEmployee(double width, double height, double textScale,
    String title, String status) {
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
        "${status}",
        style: GoogleFonts.aDLaMDisplay(
            color: Colors.white,
            fontSize: responsiveFontSize(28, width, height, textScale)),
      )
    ],
  );
}

Widget rowCOntentEmployee1(double width, double height, double textScale,
    String title, String? status) {
  return Column(
    children: [
      Text(
        "${title}",
        style: TextStyle(
            color: Colors.white,
            fontFamily: "Tansek",
            fontSize: responsiveFontSize(36, width, height, textScale)),
      ),
      SizedBox(
        height: responsiveContainerSize(12, width, height),
      ),
      Text(
        "${status}",
        style: GoogleFonts.aDLaMDisplay(
            color: Colors.white,
            fontSize: responsiveFontSize(28, width, height, textScale)),
      )
    ],
  );
}

Widget rowContentEMployee2(double width, double height, double textScale) {
  return Container(
    padding:
        EdgeInsets.symmetric(horizontal: 18 * horizontalPaddingFactor(width)),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Toal Days Present : ${TotalDays - 1}",
          style: TextStyle(
              color: Colors.white,
              fontFamily: "Tansek",
              fontSize: responsiveContainerSize(28, width, height)),
        ),
        Text(
          isPresent ? "Status - Present " : "Status - Absent ",
          style: TextStyle(
              color: Colors.white,
              fontFamily: "Tansek",
              fontSize: responsiveContainerSize(28, width, height)),
        )
      ],
    ),
  );
}

Widget listWidgetEMployee(
    double width, double height, double textScale, BuildContext context) {
  return Column(
    children: [
      Container(
        height: responsiveContainerSize(350, width, height),
        child: ListView.builder(
            itemCount: 3,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  SizedBox(
                    height: responsiveContainerSize(10, width, height),
                  ),
                  ListTile(
                    leading: Image.asset(
                      imagesEmployee[index],
                      height: responsiveContainerSize(34, width, height),
                      width: responsiveContainerSize(34, width, height),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: responsiveContainerSize(18, width, height),
                    ),
                    title: Text(
                      titleEmployee[index],
                      style: GoogleFonts.notoSansOldHungarian(
                          color: Colors.black,
                          fontSize:
                              responsiveFontSize(18, width, height, textScale),
                          fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(subtitleEmployee[index],
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

Widget companyButtonEmployee(void Function() onTap, double width, double height,
    double textScaleFactor, BuildContext context) {
  return InkWell(
    onTap: onTap,
    child: Container(
      margin: EdgeInsets.symmetric(
        horizontal: 10 * horizontalPaddingFactor(width),
      ),
      padding: EdgeInsets.symmetric(
          horizontal: 5 * horizontalPaddingFactor(width),
          vertical: 5 * verticalPaddingFactor(height)),
      height: responsiveContainerSize(55, width, height),
      decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(responsiveBorderRadius(6, width, height)),
          color: BUTTON_COLOR_1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Office Chatroom",
            style: TextStyle(
                color: Colors.white,
                fontSize:
                    responsiveFontSize(22, width, height, textScaleFactor),
                fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: Icon(
              Icons.chat,
              color: Colors.white,
              size: responsiveContainerSize(30, width, height),
            ),
            onPressed: () {},
          )
        ],
      ),
    ),
  );
}

Widget attendCompleteText(double width, double height, double textScale) {
  return Container(
    height: responsiveContainerSize(90, width, height),
    color: Colors.grey.shade900,
    child: Center(
      child: Text(
        "Your Attendance for Today Is Complete",
        style: TextStyle(
            color: Colors.white,
            fontSize: responsiveFontSize(21.5, width, height, textScale),
            fontWeight: FontWeight.bold),
      ),
    ),
  );
}

Widget cameraButton(void Function() onTap, double width, double height,
    double textScaleFactor, BuildContext context) {
  return InkWell(
    onTap: onTap,
    child: Container(
      margin: EdgeInsets.symmetric(
        horizontal: 90 * horizontalPaddingFactor(width),
      ),
      padding: EdgeInsets.symmetric(
          horizontal: 5 * horizontalPaddingFactor(width),
          vertical: 5 * verticalPaddingFactor(height)),
      height: responsiveContainerSize(50, width, height),
      decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(responsiveBorderRadius(10, width, height)),
          color: BUTTON_COLOR_1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Authenticate",
            style: TextStyle(
                color: Colors.white,
                fontSize:
                    responsiveFontSize(23, width, height, textScaleFactor),
                fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: Icon(
              Icons.camera,
              color: Colors.white,
              size: responsiveContainerSize(25, width, height),
            ),
            onPressed: () {},
          )
        ],
      ),
    ),
  );
}

