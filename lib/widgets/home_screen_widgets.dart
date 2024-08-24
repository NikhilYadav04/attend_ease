import 'package:attend_ease/constants/colors.dart';
import 'package:attend_ease/constants/scale.dart';
import 'package:flutter/material.dart';

Widget backgroundContainer(double currentWidth, double currentHeight) {
  return Container(
    color: DARK_BLUE,
    height: responsiveContainerSize(650, currentWidth, currentHeight),
  );
}

Widget titleWidget(double currentWidth, double currentHeight, double textScale,
    Animation<double> textAnimation) {
  return Center(
    child: ScaleTransition(
      scale: textAnimation,
      child: Text(
        "Welcome to Attend Ease",
        style: TextStyle(
            color: Colors.yellow.shade800,
            fontWeight: FontWeight.bold,
            fontSize:
                responsiveFontSize(52, currentWidth, currentHeight, textScale),
            fontFamily: "Tansek"),
      ),
    ),
  );
}

Widget Logo(double width, double height) {
  return Padding(
    padding: EdgeInsets.only(left: 0 * horizontalPaddingFactor(width)),
    child: Image.asset(
      "assets/home_screen/table.png",
      height: responsiveContainerSize(380, width, height),
      width: responsiveContainerSize(380, width, height),
    ),
  );
}

Widget welcomeText(double currentWidth, double currentHeight, double textScale,
    Animation<double> textAnimation) {
  return Padding(
    padding: EdgeInsets.only(right: 18 * horizontalPaddingFactor(currentWidth)),
    child: Center(
      child: ScaleTransition(
        scale: textAnimation,
        child: Text(
          "Manage your attendance in a single click.",
          style: TextStyle(
              color: Colors.yellow.shade800,
              fontWeight: FontWeight.bold,
              fontSize: responsiveFontSize(
                  29, currentWidth, currentHeight, textScale),
              fontFamily: "Tansek"),
        ),
      ),
    ),
  );
}

Widget companyButton(void Function() onTap, double width, double height,
    double textScaleFactor, BuildContext context) {
  return InkWell(
    onTap: onTap,
    child: Container(
      margin:
          EdgeInsets.symmetric(horizontal: 10 * horizontalPaddingFactor(width)),
      padding: EdgeInsets.symmetric(
          horizontal: 5 * horizontalPaddingFactor(width),
          vertical: 5 * verticalPaddingFactor(height)),
      height: responsiveContainerSize(55, width, height),
      decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(responsiveBorderRadius(6, width, height)),
          color: DARK_BLUE),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Create Company Account",
            style: TextStyle(
                color: Colors.white,
                fontSize:
                    responsiveFontSize(24, width, height, textScaleFactor),
                fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: Icon(
              Icons.arrow_circle_right_outlined,
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

Widget existText(double width, double height, double textScaleFactor) {
  return Center(
    child: Text(
      "Join Existing Company",
      style: TextStyle(
          color: DARK_BLUE,
          fontSize: responsiveContainerSize(24, width, height),
          fontWeight: FontWeight.bold,
          fontFamily: "Transek"),
    ),
  );
}

Widget widgetDivider(double currentWidth, double currentHeight) {
  return Container(
    padding: EdgeInsets.symmetric(
        horizontal: 10 * horizontalPaddingFactor(currentWidth)),
    child: const Divider(
      color: Color.fromARGB(255, 143, 141, 141),
      thickness: 2.0,
    ),
  );
}
