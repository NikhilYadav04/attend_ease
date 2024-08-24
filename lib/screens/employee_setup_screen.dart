import 'package:attend_ease/constants/colors.dart';
import 'package:attend_ease/constants/scale.dart';
import 'package:attend_ease/globalobjects/controllers.dart';
import 'package:attend_ease/globalobjects/variables.dart';
import 'package:attend_ease/helper/helper_functions.dart';
import 'package:attend_ease/screens/company_login_screen.dart';
import 'package:attend_ease/screens/employee_main_screen.dart';
import 'package:attend_ease/services/employeeService.dart';
import 'package:attend_ease/widgets/company_setup_screen_widgets.dart';
import 'package:attend_ease/widgets/employee_setup_screen_widgets.dart';
import 'package:attend_ease/widgets/otp_auth_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:page_transition/page_transition.dart';

class EmployeeSetupScreen extends StatefulWidget {
  const EmployeeSetupScreen({super.key});

  @override
  State<EmployeeSetupScreen> createState() => _EmployeeSetupScreenState();
}

class _EmployeeSetupScreenState extends State<EmployeeSetupScreen> {
  final Employeeservice employeeservice = Employeeservice();
  bool isLoading = false;
  bool isLoadingScreen = false;

  void continueButtonPressed() async {
    setState(() {
      isLoadingScreen = true;
    });
    employeeCompanyName = employeeCompanyNameController.text;
    employeeID = employeeIDController.text;

    var res = await employeeservice.joinCOmpany(
        employeeCompanyName, employeeID.substring(employeeID.indexOf("_") + 1),
        employeeID.substring(0,employeeID.indexOf("_"))
        );
    InTime = "";
    OutTime = "";
    Date = "";
    isPresent = false;
    TotalDays = 0;
    if (res == "Success") {
      await HelperFunctions.setStatus(true);
      await HelperFunctions.setEmployeeCompany(employeeCompanyName);
      await HelperFunctions.setEMployeeName(
          employeeID.substring(0, employeeID.indexOf("_")));
      await HelperFunctions.setEMployeeID(employeeID);
      setState(() {
        isLoadingScreen = false;
        cName = employeeCompanyName;
        eName = employeeID.substring(0, employeeID.indexOf("_"));
        print("EName is :${eName}");
        eID = employeeID.substring(employeeID.indexOf("_") + 1);
      });
      Navigator.push(
          context,
          PageTransition(
              child: EmployeeMainScreen(),
              type: PageTransitionType.rightToLeft));
    } else {
      setState(() {
        isLoadingScreen = false;
      });
      toastMessageError(context, "Error!", res);
    }
  }

  void HRButtonPressed() async {
    Navigator.push(
        context,
        PageTransition(
            child: CompanyLoginScreen(), type: PageTransitionType.rightToLeft));
  }

  @override
  Widget build(BuildContext context) {
    final currentHeight = MediaQuery.of(context).size.height;
    final currentWidth = MediaQuery.of(context).size.width;
    // ignore: deprecated_member_use
    final textScale = MediaQuery.of(context).textScaleFactor;
    return Scaffold(
      appBar: appBEmployee(currentWidth, currentHeight, textScale, context),
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
                    tileWidgetEmployee(currentWidth, currentHeight, textScale),
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
                      employeeCompanyNameController,
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
                      "Employee ID",
                      employeeIDController,
                    ),
                    SizedBox(
                      height: responsiveContainerSize(
                          30, currentWidth, currentHeight),
                    ),
                    textFieldEmployee(
                      currentWidth,
                      currentHeight,
                      textScale,
                      "Intern_Unpaid",
                      "Branch (Optional)",
                      employeeBranchController,
                    ),
                    SizedBox(
                      height: responsiveContainerSize(
                          80, currentWidth, currentHeight),
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
                    SizedBox(
                      height: responsiveContainerSize(
                          8, currentWidth, currentHeight),
                    ),
                    Divider(
                      color: Colors.grey.shade700,
                      thickness: 2,
                    ),
                    SizedBox(
                      height: responsiveContainerSize(
                          8, currentWidth, currentHeight),
                    ),
                    companyLoginButton(HRButtonPressed, currentWidth,
                        currentHeight, textScale, context),
                  ],
                ),
              ),
            ),
    );
  }
}
