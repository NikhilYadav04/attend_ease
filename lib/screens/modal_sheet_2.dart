import 'package:attend_ease/constants/colors.dart';
import 'package:attend_ease/constants/scale.dart';
import 'package:attend_ease/globalobjects/controllers.dart';
import 'package:attend_ease/globalobjects/variables.dart';
import 'package:attend_ease/screens/home_screen.dart';
import 'package:attend_ease/services/otpService.dart';
import 'package:attend_ease/widgets/otp_auth_widgets.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class SheetScreen2 extends StatefulWidget {
  final double width;
  final double height;
  final double textScaleFactor;

  const SheetScreen2({
    Key? key,
    required this.width,
    required this.height,
    required this.textScaleFactor,
  }) : super(key: key);

  @override
  _SheetScreen2State createState() => _SheetScreen2State();
}

class _SheetScreen2State extends State<SheetScreen2> {
  bool isLoading = false;
  final otpService = OtpService();

  void continueButtonPressed() async {
    otp = otpController.text;

    if (otp.length == 6) {
      otpController.clear();
      numberController.clear();
      setState(() {
        isLoading = true;
      });
      String res = await otpService.verifyOTP(otp);
      setState(() {
        isLoading = false;
      });
      if (res == "Verified") {
        Navigator.push(
          context,
          PageTransition(
            child: HomeScreen(),
            type: PageTransitionType.bottomToTop,
          ),
        );
      } else {
        toastMessage(context, 'Error!', res);
      }
    } else {
      toastMessage(context, 'No OTP Entered!', 'Please Enter Your OTP');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: DARK_BLUE,
                ),
              )
            : Container(
                padding: EdgeInsets.symmetric(
                  vertical: 30 * verticalPaddingFactor(widget.height),
                  horizontal: 15 * horizontalPaddingFactor(widget.width),
                ),
                width: double.infinity,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              WoltModalSheet.of(context).showPrevious();
                            },
                            icon: Icon(
                              Icons.arrow_circle_left_outlined,
                              size: responsiveContainerSize(
                                35,
                                widget.width,
                                widget.height,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: Icon(
                              Icons.cancel_outlined,
                              size: responsiveContainerSize(
                                35,
                                widget.width,
                                widget.height,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: responsiveContainerSize(
                            10, widget.width, widget.height),
                      ),
                      titleText(
                        "Enter your Verification Code",
                        widget.width,
                        widget.height,
                        widget.textScaleFactor,
                      ),
                      descriptionText(
                        "We have sent OTP on +$phoneNumber",
                        widget.width,
                        widget.height,
                        widget.textScaleFactor,
                      ),
                      SizedBox(
                        height: responsiveContainerSize(
                            25, widget.width, widget.height),
                      ),
                      otpField(
                          widget.width, widget.height, widget.textScaleFactor),
                      SizedBox(
                        height: responsiveContainerSize(
                            485, widget.width, widget.height),
                      ),
                      continueButton2(
                        continueButtonPressed,
                        widget.width,
                        widget.height,
                        widget.textScaleFactor,
                        context,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
