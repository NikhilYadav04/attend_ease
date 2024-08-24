import 'package:attend_ease/constants/colors.dart';
import 'package:attend_ease/constants/scale.dart';
import 'package:attend_ease/globalobjects/controllers.dart';
import 'package:attend_ease/globalobjects/variables.dart';
import 'package:attend_ease/helper/helper_functions.dart';
import 'package:attend_ease/screens/company_location_screen.dart';
import 'package:attend_ease/screens/employee_main_screen.dart';
import 'package:attend_ease/services/companyService.dart';
import 'package:attend_ease/widgets/company_setup_screen_widgets.dart';
import 'package:attend_ease/widgets/otp_auth_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:page_transition/page_transition.dart';

class CompanySetupScreen extends StatefulWidget {
  const CompanySetupScreen({super.key});

  @override
  State<CompanySetupScreen> createState() => _CompanySetupScreenState();
}

class _CompanySetupScreenState extends State<CompanySetupScreen> {
  bool isAlert = false;
  bool isLoading = false;
  final companyService CompanyService = companyService();

  void continueButtonPressed() async {
    companyName = companyNameController.text;
    companyHR = companyHRCountController.text;
    companyID = companyIDController.text;
    companyCity = companyCityController.text;
    setState(() {
      isLoading = true;
      cName = companyName;
      cID = companyID;
    });
    String res = await CompanyService.addCompany(
        companyName, companyHR, companyID, companyCity);
    await HelperFunctions.setCompanyName(companyName);
    await HelperFunctions.setCompanyID(companyID);

    if (res == "Success") {
      setState(() {
        isLoading = false;
      });
      Navigator.push(
          context,
          PageTransition(
              child: CompanyLocationScreen(companyName: companyName),
              type: PageTransitionType.rightToLeft));
    } else {
      setState(() {
        isLoading = false;
      });
      toastMessageError(context, "Error!", res);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentHeight = MediaQuery.of(context).size.height;
    final currentWidth = MediaQuery.of(context).size.width;
    // ignore: deprecated_member_use
    final textScale = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: appB(currentWidth, currentHeight, textScale, context),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: DARK_BLUE,
              ),
            )
          : Container(
              padding: EdgeInsets.symmetric(
                  horizontal: 11 * horizontalPaddingFactor(currentWidth)),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: responsiveContainerSize(
                          20, currentWidth, currentHeight),
                    ),
                    tileWidget(currentWidth, currentHeight, textScale),
                    SizedBox(
                      height: responsiveContainerSize(
                          30, currentWidth, currentHeight),
                    ),
                    textField(
                        currentWidth,
                        currentHeight,
                        textScale,
                        " ABC pvt. ltd.",
                        "Company Name",
                        companyNameController),
                    SizedBox(
                      height: responsiveContainerSize(
                          25, currentWidth, currentHeight),
                    ),
                    textField(currentWidth, currentHeight, textScale,
                        " Mr. Nikhil", "Company HR", companyHRCountController),
                    SizedBox(
                      height: responsiveContainerSize(
                          25, currentWidth, currentHeight),
                    ),
                    textField(currentWidth, currentHeight, textScale, " ABCX3",
                        "Company ID", companyIDController),
                    SizedBox(
                      height: responsiveContainerSize(
                          25, currentWidth, currentHeight),
                    ),
                    textField(currentWidth, currentHeight, textScale,
                        " eg. Mumbai", "Company City", companyCityController),
                    SizedBox(
                      height: responsiveContainerSize(
                          40, currentWidth, currentHeight),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Send free Whatsapp alerts",
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
                            value: isAlert,
                            onToggle: (val) {
                              setState(() {
                                isAlert = val;
                              });
                            }),
                      ],
                    ),
                    SizedBox(
                      height: responsiveContainerSize(
                          35, currentWidth, currentHeight),
                    ),
                    companyButton(continueButtonPressed, currentWidth,
                        currentHeight, textScale, context)
                  ],
                ),
              ),
            ),
    );
  }
}
