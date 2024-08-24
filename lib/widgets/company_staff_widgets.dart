import 'package:attend_ease/constants/scale.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

Widget loadingWidget(double width, double height, double textScale) {
  return Container(
    padding: EdgeInsets.symmetric(
        horizontal: 5 * horizontalPaddingFactor(width),
        vertical: 25 * verticalPaddingFactor(height)),
    child: Column(
      children: [
        Text("Verifying Your Credentials..",
            style: TextStyle(
                shadows: [
                  Shadow(
                      color: Colors.white,
                      offset: const Offset(8, 8),
                      blurRadius: responsiveBorderRadius(20, width, height))
                ],
                fontFamily: "Tansek",
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: responsiveFontSize(48, width, height, textScale))),
        LottieBuilder.asset(
          "assets/animations/load.json",
          fit: BoxFit.fill,
        ),
        Text("Waiting For Approval from HR",
            style: TextStyle(
                shadows: [
                  Shadow(
                      color: Colors.white,
                      offset: const Offset(8, 8),
                      blurRadius: responsiveBorderRadius(20, width, height))
                ],
                fontFamily: "Tansek",
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: responsiveFontSize(44, width, height, textScale))),
        Text("To Gain Access To Attendance",
            style: TextStyle(
                shadows: [
                  Shadow(
                      color: Colors.white,
                      offset: const Offset(8, 8),
                      blurRadius: responsiveBorderRadius(20, width, height))
                ],
                fontFamily: "Tansek",
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: responsiveFontSize(44, width, height, textScale))),
      ],
    ),
  );
}


