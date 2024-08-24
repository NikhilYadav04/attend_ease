import 'package:attend_ease/constants/colors.dart';
import 'package:attend_ease/constants/scale.dart';
import 'package:attend_ease/globalobjects/variables.dart';
import 'package:flutter/material.dart';

AppBar appBLocation(double currentWidth, double currentHeight, double textScale,
    BuildContext context) {
  return AppBar(
    actions: [
      IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.exit_to_app))
    ],
    automaticallyImplyLeading: false,
    backgroundColor: Colors.white,
    title: Text(
      "Setup Attendance Location",
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

Widget mapWidget() {
  return Image.asset("assets/location_screen/map.png");
}

Widget pageText(
    double currentWidth, double currentHeight, double textScale, String title) {
  return Text(
    title,
    style: TextStyle(
        color: Colors.black,
        fontSize:
            responsiveFontSize(18, currentWidth, currentHeight, textScale),
        fontWeight: FontWeight.w600),
  );
}

Widget geoForceText(
    double currentWidth, double currentHeight, double textScale) {
  return Text(
    "& set geofence radius",
    style: TextStyle(
      color: Colors.grey.shade800,
      fontSize: responsiveFontSize(16, currentWidth, currentHeight, textScale),
    ),
  );
}

Widget locationSetBox(
    double currentWidth, double currentHeight, double textScale,void Function() onTap) {
  return Container(
    padding: EdgeInsets.symmetric(
        horizontal: 10 * horizontalPaddingFactor(currentWidth)),
    height: responsiveContainerSize(52, currentWidth, currentHeight),
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade400)),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "${latitude},${longitude}",
          style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.bold,
              fontSize:
                  responsiveContainerSize(16, currentWidth, currentHeight)),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            "Set Location",
            style: TextStyle(
                color: Colors.blue.shade700,
                fontWeight: FontWeight.bold,
                fontSize:
                    responsiveContainerSize(18, currentWidth, currentHeight)),
          ),
        ),
      ],
    ),
  );
}

Widget locationRadiusBox(
    double currentWidth, double currentHeight, double textScale) {
  return ListTile(
    leading: Icon(
      Icons.location_on,
      color: Colors.grey.shade800,
      size: responsiveContainerSize(24, currentWidth, currentHeight),
    ),
    title: Text(
      "Maximum Attendance Radius",
      style: TextStyle(
          color: Colors.grey.shade900,
          fontSize: responsiveFontSize(17, currentWidth, currentHeight, textScale),
          fontWeight: FontWeight.w500),
    ),
    subtitle: Text(
      "Staff can mark attendance within this radius only",
      style: TextStyle(color: Colors.grey.shade900, fontSize: responsiveFontSize(13, currentWidth, currentHeight, textScale)),
    ),
  );
}

Widget rangeWidget(
    double currentWidth, double currentHeight, double textScale) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 8*horizontalPaddingFactor(currentWidth)),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "100 m",
          style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 15,
              fontWeight: FontWeight.w500),
        ),
        Text(
          "500 m",
          style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 15,
              fontWeight: FontWeight.w500),
        ),
      ],
    ),
  );
}

Widget continueButton(void Function() onTap, double width, double height,
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