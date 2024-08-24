import 'package:attend_ease/constants/scale.dart';
import 'package:attend_ease/globalobjects/variables.dart';
import 'package:attend_ease/widgets/company_hr_widgets.dart';
import 'package:flutter/material.dart';

class ApprovalReqScreen extends StatefulWidget {

  const ApprovalReqScreen({super.key});

  @override
  State<ApprovalReqScreen> createState() => _ApprovalReqScreenState();
}

class _ApprovalReqScreenState extends State<ApprovalReqScreen> {
  @override
  Widget build(BuildContext context) {
    final currentHeight = MediaQuery.of(context).size.height;
    final currentWidth = MediaQuery.of(context).size.width;
    // ignore: deprecated_member_use
    final textScale = MediaQuery.of(context).textScaleFactor;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: responsiveContainerSize(15, currentWidth, currentHeight),
            ),
            approveTextEmployee(
                currentWidth, currentHeight, textScale, "Staff Count List"),
            SizedBox(
              height: responsiveContainerSize(15, currentWidth, currentHeight),
            ),
            listApproval(currentWidth, currentHeight, textScale, context,staffList)
          ],
        ),
      ),
    );
  }
}
