import 'package:attend_ease/constants/colors.dart';
import 'package:attend_ease/constants/scale.dart';
import 'package:attend_ease/globalobjects/controllers.dart';
import 'package:attend_ease/globalobjects/variables.dart';
import 'package:attend_ease/helper/helper_functions.dart';
import 'package:attend_ease/screens/company_hr_screen.dart';
import 'package:attend_ease/services/companyService.dart';
import 'package:attend_ease/widgets/company_login_widgets.dart';
import 'package:attend_ease/widgets/company_setup_screen_widgets.dart';
import 'package:attend_ease/widgets/employee_setup_screen_widgets.dart';
import 'package:attend_ease/widgets/otp_auth_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:page_transition/page_transition.dart';

class CompanyLoginScreen extends StatefulWidget {
  const CompanyLoginScreen({super.key});

  @override
  State<CompanyLoginScreen> createState() => _CompanyLoginScreenState();
}

class _CompanyLoginScreenState extends State<CompanyLoginScreen> {
  bool isLoadingScreen = false;
  bool isLoading = false;
  final companyService CompanyService = companyService();

  void continueButtonPressed() async {
    setState(() {
      isLoadingScreen = true;
    });
    companyLoginName = companyLoginNameController.text;
    companyLoginID = companyLoginIDController.text;
    String res = await CompanyService.loginCompany(companyLoginName, companyLoginID);
    await HelperFunctions.setStatus(true);
    if (res == "Success") {
      setState(() {
        cName = companyLoginName;
        cID = companyLoginID;
      });
      Navigator.push(
          context,
          PageTransition(
              child: CompanyHrScreen(), type: PageTransitionType.rightToLeft));
    } else {
      setState(() {
        isLoadingScreen = false;
      });
      toastMessageError(context, "Error", res);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentHeight = MediaQuery.of(context).size.height;
    final currentWidth = MediaQuery.of(context).size.width;
    // ignore: deprecated_member_use
    final textScale = MediaQuery.of(context).textScaleFactor;
    return Scaffold(
      appBar: appBLoginCompany(currentWidth, currentHeight, textScale, context),
      body: isLoadingScreen
          ? const Center(
              child: CircularProgressIndicator(
                color: DARK_BLUE,
              ),
            )
          : Container(
              padding: EdgeInsets.symmetric(
                horizontal: 11 * horizontalPaddingFactor(currentWidth),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: responsiveContainerSize(
                          20, currentWidth, currentHeight),
                    ),
                    tileWidgetLoginCompany(
                        currentWidth, currentHeight, textScale),
                    SizedBox(
                      height: responsiveContainerSize(
                          30, currentWidth, currentHeight),
                    ),
                    textFieldEmployee(
                      currentWidth,
                      currentHeight,
                      textScale,
                      " ABC pvt. ltd.",
                      "Company Name",
                      companyLoginNameController,
                    ),
                    SizedBox(
                      height: responsiveContainerSize(
                          30, currentWidth, currentHeight),
                    ),
                    textFieldEmployee(
                      currentWidth,
                      currentHeight,
                      textScale,
                      "XXX_123",
                      "Company ID",
                      companyLoginIDController,
                    ),
                    SizedBox(
                      height: responsiveContainerSize(
                          280, currentWidth, currentHeight),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Receive free Whatsapp alerts",
                          style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: responsiveContainerSize(
                                  17, currentWidth, currentHeight)),
                        ),
                        FlutterSwitch(
                            activeColor: BUTTON_COLOR_1,
                            inactiveColor: Colors.grey.shade700,
                            height: responsiveContainerSize(
                                38, currentWidth, currentWidth),
                            width: responsiveContainerSize(
                                65, currentWidth, currentWidth),
                            value: isLoading,
                            onToggle: (val) {
                              setState(() {
                                isLoading = val;
                              });
                            }),
                      ],
                    ),
                    SizedBox(
                      height: responsiveContainerSize(
                          30, currentWidth, currentHeight),
                    ),
                    companyButton(continueButtonPressed, currentWidth,
                        currentHeight, textScale, context),
                  ],
                ),
              ),
            ),
    );
  }
}
