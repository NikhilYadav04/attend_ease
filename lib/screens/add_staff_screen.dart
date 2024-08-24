import 'package:attend_ease/constants/colors.dart';
import 'package:attend_ease/constants/scale.dart';
import 'package:attend_ease/globalobjects/controllers.dart';
import 'package:attend_ease/globalobjects/variables.dart';
import 'package:attend_ease/services/employeeService.dart';
import 'package:attend_ease/widgets/add_staff_widgets.dart';
import 'package:attend_ease/widgets/otp_auth_widgets.dart';
import 'package:flutter/material.dart';

class AddStaffScreen extends StatefulWidget {
  const AddStaffScreen({super.key});

  @override
  State<AddStaffScreen> createState() => _AddStaffScreenState();
}

class _AddStaffScreenState extends State<AddStaffScreen> {
  final Employeeservice employeeservice = Employeeservice();
  bool isLoading = false;

  void continueButtonPressed() async {
    setState(() {
      isLoading = true;
    });
    addEmployeeName = addEmployeeNameController.text;
    addEmployeePosition = addEmployeePositionController.text;
    addEmployeeNumber = addEmployeeNumberController.text;

    String res = await employeeservice.addEmployee(
        addEmployeeName, addEmployeeNumber, addEmployeePosition, cName, cID);
    if (res == "Success") {
      setState(() {
        isLoading = false;
      });
      toastMessageSuccess(context, "Success", "Employee Added");
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
    final textScale = MediaQuery.of(context).textScaleFactor;
    return Scaffold(
      appBar: appBStaff(currentWidth, currentHeight, textScale, context),
      body: SingleChildScrollView(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: DARK_BLUE,
                ),
              )
            : Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 15 * horizontalPaddingFactor(currentWidth)),
                child: Column(
                  children: [
                    SizedBox(
                      height: responsiveContainerSize(
                          25, currentWidth, currentHeight),
                    ),
                    multipleWidget(currentWidth, currentHeight, textScale),
                    SizedBox(
                      height: responsiveContainerSize(
                          20, currentWidth, currentHeight),
                    ),
                    textFieldStaff(
                        currentWidth,
                        currentHeight,
                        textScale,
                        "Enter Name",
                        "Employee Name",
                        addEmployeeNameController,
                        addEmployeeName),
                    SizedBox(
                      height: responsiveContainerSize(
                          20, currentWidth, currentHeight),
                    ),
                    textFieldStaff(
                        currentWidth,
                        currentHeight,
                        textScale,
                        "Employee",
                        "Position",
                        addEmployeePositionController,
                        addEmployeePosition),
                    SizedBox(
                      height: responsiveContainerSize(
                          20, currentWidth, currentHeight),
                    ),
                    numberFieldStaff(
                        currentWidth,
                        currentHeight,
                        textScale,
                        "Enter Phone Number",
                        "Phone Number",
                        addEmployeeNumberController,
                        addEmployeeNumber),
                    SizedBox(
                      height: responsiveContainerSize(
                          25, currentWidth, currentHeight),
                    ),
                    addText(currentWidth, currentHeight, textScale),
                    SizedBox(
                      height: responsiveContainerSize(
                          210, currentWidth, currentHeight),
                    ),
                    addEmployeeButton(continueButtonPressed, currentWidth,
                        currentHeight, textScale, context)
                  ],
                ),
              ),
      ),
    );
  }
}
