import 'package:another_carousel_pro/another_carousel_pro.dart';
import 'package:attend_ease/core/constants/app_colors.dart';
import 'package:attend_ease/core/constants/app_dimensions.dart';
import 'package:attend_ease/core/constants/app_text_styles.dart';
import 'package:attend_ease/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:toastification/toastification.dart';

final Toastification toastification = Toastification();

Widget imageSlider(double width, double height, double textScaleFactor) {
  return Container(
    padding: EdgeInsets.only(top: 15 * verticalPaddingFactor(height)),
    height: responsiveContainerSize(670, width, height),
    color: DARK_BLUE,
    child: AnotherCarousel(
      images: [
        Image.asset("assets/login_screen/vector_1.png"),
        Image.asset("assets/login_screen/vector_2.png"),
        Image.asset("assets/login_screen/vector_3.png"),
      ],
      boxFit: BoxFit.fill,
    ),
  );
}

Widget loginButton(
    double width, double height, double textScaleFactor, BuildContext context) {
  return InkWell(
    onTap: () => context.push(AppRoutes.otpPhone),
    child: Container(
      margin:
          EdgeInsets.symmetric(horizontal: 10 * horizontalPaddingFactor(width)),
      padding: EdgeInsets.symmetric(
          horizontal: 5 * horizontalPaddingFactor(width),
          vertical: 5 * verticalPaddingFactor(height)),
      height: responsiveContainerSize(65, width, height),
      decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(responsiveBorderRadius(6, width, height)),
          color: DARK_BLUE),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Login With OTP ",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.white,
              fontFamily: "Tansek",
              fontSize: responsiveFontSize(38, width, height, textScaleFactor),
            ),
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

Widget bottomText(double width, double height, double textScaleFactor) {
  return RichText(
    text: TextSpan(
      style: TextStyle(
        fontFamily: "Tansek",
        fontSize: responsiveFontSize(25.2, width, height, textScaleFactor),
        color: Colors.grey.shade800,
      ),
      children: const [
        TextSpan(text: "By continuing, You agree to Our "),
        TextSpan(
          text: "Terms & Conditions",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        ),
      ],
    ),
  );
}

ToastificationItem toastMessage(
    BuildContext context, String title, String description) {
  return toastification.show(
    context: context,
    alignment: Alignment.bottomCenter,
    type: ToastificationType.warning,
    style: ToastificationStyle.flat,
    autoCloseDuration: const Duration(seconds: 3),
    primaryColor: AppColors.warning,
    backgroundColor: AppColors.surface,
    foregroundColor: AppColors.textPrimary,
    showProgressBar: false,
    borderRadius: BorderRadius.circular(12),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
    closeButtonShowType: CloseButtonShowType.onHover,
    showIcon: true,
    title: Text(title, style: AppTextStyles.bodyMedium),
    description: Text(description, style: AppTextStyles.caption),
  );
}

Widget continueButton2(void Function() onTap, double width, double height,
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
          color: BUTTON_COLOR_1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Continue",
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

Widget titleText(
    String title, double width, double height, double textScaleFactor) {
  return Text(
    title,
    style: TextStyle(
        color: Colors.black,
        fontFamily: "Tansek",
        fontSize: responsiveFontSize(42, width, height, textScaleFactor)),
  );
}

Widget descriptionText(
    String description, double width, double height, double textScaleFactor) {
  return Text(
    description,
    style: TextStyle(
        color: Colors.grey.shade800,
        fontFamily: "Tansek",
        fontSize: responsiveFontSize(29, width, height, textScaleFactor)),
  );
}

Widget phoneNumberField(double width, double height, double textScaleFactor,
    TextEditingController controller) {
  return Container(
    padding:
        EdgeInsets.symmetric(horizontal: 6 * horizontalPaddingFactor(width)),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Image.asset(
          "assets/login_screen/flag.png",
          height: responsiveContainerSize(32, width, height),
          width: responsiveContainerSize(32, width, height),
        ),
        Text(
          " +91  ",
          style: TextStyle(
              fontSize: responsiveFontSize(24, width, height, textScaleFactor),
              fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Container(
            height: responsiveContainerSize(50, width, height),
            child: FormField(builder: (context) {
              return TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                style: TextStyle(
                    fontSize:
                        responsiveFontSize(20, width, height, textScaleFactor),
                    color: Colors.black),
                decoration: InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    label: Center(
                      child: Text(
                        "Enter your Phone Number",
                        style: TextStyle(
                            fontSize: responsiveFontSize(
                                20, width, height, textScaleFactor),
                            color: Colors.grey.shade800),
                      ),
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          responsiveBorderRadius(4, width, height),
                        ),
                        borderSide: const BorderSide(color: Colors.grey)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          responsiveBorderRadius(4, width, height),
                        ),
                        borderSide: const BorderSide(color: BUTTON_COLOR_1)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          responsiveBorderRadius(4, width, height),
                        ),
                        borderSide: const BorderSide(color: Colors.grey))),
              );
            }),
          ),
        ),
      ],
    ),
  );
}

Widget otpField(double width, double height, double textScaleFactor,
    TextEditingController controller) {
  return Pinput(
    controller: controller,
    length: 6,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.center,
    defaultPinTheme: PinTheme(
        height: 50,
        width: 50,
        textStyle: TextStyle(
          fontSize: responsiveFontSize(20, width, height, textScaleFactor),
          color: Colors.black,
        ),
        decoration: BoxDecoration(
            color: Colors.blue.shade100,
            border: Border.all(color: Colors.grey.shade800),
            boxShadow: const [
              BoxShadow(
                  color: Colors.transparent, blurRadius: 100, spreadRadius: 100)
            ])),
  );
}

ToastificationItem toastMessageSuccess(
    BuildContext context, String title, String description) {
  return toastification.show(
    context: context,
    alignment: Alignment.bottomCenter,
    type: ToastificationType.success,
    style: ToastificationStyle.flat,
    autoCloseDuration: const Duration(seconds: 3),
    primaryColor: AppColors.success,
    backgroundColor: AppColors.surface,
    foregroundColor: AppColors.textPrimary,
    showProgressBar: false,
    borderRadius: BorderRadius.circular(12),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
    closeButtonShowType: CloseButtonShowType.onHover,
    showIcon: true,
    title: Text(title, style: AppTextStyles.bodyMedium),
    description: Text(description, style: AppTextStyles.caption),
  );
}

ToastificationItem toastMessageError(
    BuildContext context, String title, String description) {
  return toastification.show(
    context: context,
    alignment: Alignment.bottomCenter,
    type: ToastificationType.error,
    style: ToastificationStyle.flat,
    autoCloseDuration: const Duration(seconds: 3),
    primaryColor: AppColors.error,
    backgroundColor: AppColors.surface,
    foregroundColor: AppColors.textPrimary,
    showProgressBar: false,
    borderRadius: BorderRadius.circular(12),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
    closeButtonShowType: CloseButtonShowType.onHover,
    showIcon: true,
    title: Text(title, style: AppTextStyles.bodyMedium),
    description: Text(description, style: AppTextStyles.caption),
  );
}
