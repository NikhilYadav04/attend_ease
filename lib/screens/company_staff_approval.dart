import 'package:attend_ease/constants/scale.dart';
import 'package:attend_ease/widgets/company_staff_widgets.dart';
import 'package:flutter/material.dart';

class CompanyStaffApproval extends StatefulWidget {
  const CompanyStaffApproval({super.key});

  @override
  State<CompanyStaffApproval> createState() => _CompanyStaffApprovalState();
}

class _CompanyStaffApprovalState extends State<CompanyStaffApproval> {
  @override
  Widget build(BuildContext context) {
    final currentHeight = MediaQuery.of(context).size.height;
    final currentWidth = MediaQuery.of(context).size.width;
    // ignore: deprecated_member_use
    final textScale = MediaQuery.of(context).textScaleFactor;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.grey, Colors.white, Colors.grey])),
        child: Center(
          child: Column(
            children: [
              SizedBox(
                height:
                    responsiveContainerSize(80, currentWidth, currentHeight),
              ),
              loadingWidget(currentWidth, currentHeight, textScale),
            ],
          ),
        ),
      ),
    );
  }
}
