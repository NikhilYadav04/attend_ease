import 'package:attend_ease/constants/colors.dart';
import 'package:attend_ease/constants/scale.dart';
import 'package:attend_ease/globalobjects/controllers.dart';
import 'package:attend_ease/globalobjects/variables.dart';
import 'package:attend_ease/screens/modal_sheet_2.dart';
import 'package:attend_ease/services/otpService.dart';
import 'package:attend_ease/widgets/otp_auth_widgets.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class SheetScreen1 extends StatefulWidget {
  final double width;
  final double height;
  final double textScaleFactor;

  SheetScreen1({
    required this.width,
    required this.height,
    required this.textScaleFactor,
  });

  @override
  _SheetScreen1State createState() => _SheetScreen1State();
}

class _SheetScreen1State extends State<SheetScreen1> {
  bool isLoading = false;
  final otpService = OtpService();

  void continueButtonPressed() async {
    // otp send logic
    phoneNumber = numberController.text;
    if (phoneNumber.length == 10) {
      numberController.clear();
      setState(() {
        isLoading = true;
      });
      String result = await otpService.sendOTP("+91${phoneNumber}");
      setState(() {
        isLoading = false;
      });
      if (result == "Success") {
        Navigator.push(
            context,
            PageTransition(
                child: SheetScreen2(
                    width: widget.width,
                    height: widget.height,
                    textScaleFactor: widget.textScaleFactor),
                type: PageTransitionType.rightToLeft));
      } else {
        toastMessage(context, 'Error!', result);
      }
      // Navigate to page once otp is sent
    } else {
      toastMessage(context, 'No Phone Number!', 'Please Enter Your Number');
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
                    horizontal: 10 * horizontalPaddingFactor(widget.width)),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Icon(
                                Icons.cancel_outlined,
                                size: responsiveContainerSize(
                                  35,
                                  widget.width,
                                  widget.height,
                                ),
                              )),
                          InkWell(
                              onTap: () {
                                WoltModalSheet.of(context).showNext();
                              },
                              child: Icon(
                                Icons.question_mark,
                                size: responsiveContainerSize(
                                  35,
                                  widget.width,
                                  widget.height,
                                ),
                              )),
                        ],
                      ),
                      SizedBox(
                        height: responsiveContainerSize(
                            20, widget.width, widget.height),
                      ),
                      titleText(
                        " Enter your mobile number",
                        widget.width,
                        widget.height,
                        widget.textScaleFactor,
                      ),
                      descriptionText(
                        " We will send OTP on this phone number",
                        widget.width,
                        widget.height,
                        widget.textScaleFactor,
                      ),
                      SizedBox(
                        height: responsiveContainerSize(
                            25, widget.width, widget.height),
                      ),
                      phoneNumberField(
                          widget.width, widget.height, widget.textScaleFactor),
                      SizedBox(
                        height: responsiveContainerSize(
                            485, widget.width, widget.height),
                      ),
                      continueButton2(() {
                        continueButtonPressed();
                      }, widget.width, widget.height, widget.textScaleFactor,
                          context)
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
