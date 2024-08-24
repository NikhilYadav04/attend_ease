import 'package:attend_ease/constants/colors.dart';
import 'package:attend_ease/constants/scale.dart';
import 'package:attend_ease/helper/helper_functions.dart';
import 'package:attend_ease/screens/otp_auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';

AppBar appB(double currentWidth, double currentHeight, double textScale,
    BuildContext context) {
  return AppBar(
    actions: [
      IconButton(
          onPressed: () async {
            await HelperFunctions.setStatus(false);
            await HelperFunctions.setCompanyName("");
            Navigator.push(
                context,
                PageTransition(
                    child: OtpAuthScreen(), type: PageTransitionType.fade));
          },
          icon: Icon(Icons.exit_to_app))
    ],
    automaticallyImplyLeading: false,
    backgroundColor: Colors.white,
    title: Text(
      "Setup your company account",
      style: TextStyle(
          color: Colors.black,
          fontFamily: "Tansek",
          fontWeight: FontWeight.w500,
          fontSize:
              responsiveFontSize(34, currentWidth, currentHeight, textScale)),
    ),
    toolbarHeight: responsiveContainerSize(75, currentWidth, currentHeight),
    elevation: 5,
    shadowColor: Colors.grey,
  );
}

Widget tileWidget(double currentWidth, double currentHeight, double textScale) {
  return Container(
    decoration: BoxDecoration(
        color: Colors.blue.shade50, borderRadius: BorderRadius.circular(4)),
    child: ListTile(
      title: Text(
        "Register your company detail's here",
        style: TextStyle(
            fontFamily: "Tansek",
            fontSize:
                responsiveFontSize(26, currentWidth, currentHeight, textScale),
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade800),
      ),
      subtitle: Text(
        "Keep a track of your Staff's Attendance",
        style: TextStyle(
            fontFamily: "Tansek",
            fontSize:
                responsiveFontSize(22, currentWidth, currentHeight, textScale),
            fontWeight: FontWeight.w500,
            color: Colors.blue.shade800),
      ),
      trailing: CircleAvatar(
        backgroundColor: Colors.white,
        radius: responsiveBorderRadius(22, currentWidth, currentHeight),
        child: Icon(
          Icons.security_update_good,
          color: Colors.blue.shade800,
          size: responsiveContainerSize(26, currentWidth, currentHeight),
        ),
      ),
    ),
  );
}

Widget textField(double currentWidth, double currentHeight, double textScale,
    String label, String title, TextEditingController textCOntroller) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: TextStyle(
          color: Colors.grey.shade700,
          fontSize:
              responsiveFontSize(16, currentWidth, currentHeight, textScale),
        ),
      ),
      SizedBox(
        height: responsiveContainerSize(10, currentWidth, currentHeight),
      ),
      FormField(builder: (context) {
        return TextField(
          controller: textCOntroller,
          decoration: InputDecoration(
            label: Text(
              label,
              style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize:
                      responsiveContainerSize(17, currentWidth, currentHeight)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: Colors.grey.shade500),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: BUTTON_COLOR_1),
            ),
          ),
        );
      })
    ],
  );
}

Widget companyButton(void Function() onTap, double width, double height,
    double textScaleFactor, BuildContext context) {
  return InkWell(
    onTap: onTap,
    child: Container(
      margin:
          EdgeInsets.symmetric(horizontal: 0 * horizontalPaddingFactor(width)),
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
            "Continue",
            style: TextStyle(
                color: Colors.white,
                fontSize:
                    responsiveFontSize(22, width, height, textScaleFactor),
                fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: Icon(
              Icons.arrow_circle_right,
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

Widget companyLoginButton(void Function() onTap, double width, double height,
    double textScaleFactor, BuildContext context) {
  return InkWell(
    onTap: onTap,
    child: Container(
      margin:
          EdgeInsets.symmetric(horizontal: 0 * horizontalPaddingFactor(width)),
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
            "Login as HR",
            style: TextStyle(
                color: Colors.white,
                fontSize:
                    responsiveFontSize(22, width, height, textScaleFactor),
                fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: Icon(
              Icons.arrow_circle_right,
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

Widget LoadingAnimationWidget(double width, double height, double textScale) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 18*horizontalPaddingFactor(width)),
    height: responsiveContainerSize(90, width, height),
    color: Colors.white,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        LottieBuilder.asset(
          "assets/animations/food.json",
          height: responsiveContainerSize(88, width, height),
        ),
        Text("Getting Your Location..",
            style: GoogleFonts.notoSansOldHungarian(
                fontWeight: FontWeight.bold,
                fontSize: responsiveFontSize(26, width, height, textScale),
                color: Colors.black))
      ],
    ),
  );
}
