import 'package:attend_ease/constants/colors.dart';
import 'package:attend_ease/constants/scale.dart';
import 'package:attend_ease/globalobjects/variables.dart';
import 'package:attend_ease/helper/helper_functions.dart';
import 'package:attend_ease/screens/company_hr_screen.dart';
import 'package:attend_ease/screens/company_setup_screen.dart';
import 'package:attend_ease/screens/employee_main_screen.dart';
import 'package:attend_ease/services/locationService.dart';
import 'package:attend_ease/widgets/company_location_screen_widgets.dart';
import 'package:attend_ease/widgets/otp_auth_widgets.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:page_transition/page_transition.dart';

class CompanyLocationScreen extends StatefulWidget {
  final String? companyName;
  CompanyLocationScreen({super.key, required this.companyName});

  @override
  State<CompanyLocationScreen> createState() => _CompanyLocationScreenState();
}

class _CompanyLocationScreenState extends State<CompanyLocationScreen> {
  final locationService LocationService = locationService();
  void getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      toastMessageError(context, "Error!", "Permission Denied");
      // ignore: unused_local_variable
      LocationPermission ask = await Geolocator.requestPermission();
    } else {
      Position currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);

      setState(() {
        latitude = currentPosition.latitude.toString();
        longitude = currentPosition.longitude.toString();
      });
      String res = await LocationService.setLocation(
          latitude, longitude, companyName, sliderValue);
      if (res == "Stored") {
        toastMessageSuccess(
            context, "Success!", "Your location is Set Successfully");
      } else {
        toastMessageError(context, "Error!", res);
      }
    }
  }

  void checkSTatus() async {
    if (longitude != "") {
      await HelperFunctions.setStatus(true);
      // await HelperFunctions.setCompanyName(companyName);
      Navigator.push(
          context,
          PageTransition(
              child: CompanyHrScreen(), type: PageTransitionType.rightToLeft));
    } else {
      toastMessageError(
          context, "Error!", "Set Your Location Co-ordinates First");
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentHeight = MediaQuery.of(context).size.height;
    final currentWidth = MediaQuery.of(context).size.width;
    final textScale = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      appBar: appBLocation(currentWidth, currentHeight, textScale, context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            mapWidget(),
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: 12 * horizontalPaddingFactor(currentWidth)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: responsiveContainerSize(
                        20, currentWidth, currentHeight),
                  ),
                  pageText(currentWidth, currentHeight, textScale,
                      "Tell us your company address!"),
                  geoForceText(currentWidth, currentHeight, textScale),
                  SizedBox(
                    height: responsiveContainerSize(
                        30, currentWidth, currentHeight),
                  ),
                  pageText(currentWidth, currentHeight, textScale,
                      "Company location"),
                  SizedBox(
                    height: responsiveContainerSize(
                        10, currentWidth, currentHeight),
                  ),
                  locationSetBox(currentWidth, currentHeight, textScale,
                      getCurrentLocation),
                  SizedBox(
                    height: responsiveContainerSize(
                        20, currentWidth, currentHeight),
                  ),
                  Container(
                      padding: EdgeInsets.symmetric(
                          horizontal:
                              5 * horizontalPaddingFactor(currentWidth)),
                      height: responsiveContainerSize(
                          170, currentWidth, currentHeight),
                      decoration: BoxDecoration(
                        color: BUTTON_COLOR_2,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Column(
                        children: [
                          locationRadiusBox(
                              currentWidth, currentHeight, textScale),
                          Expanded(
                            child: Slider(
                                activeColor: BUTTON_COLOR_1,
                                value: sliderValue,
                                label: "$sliderValue m",
                                max: 500,
                                divisions: 400,
                                onChanged: (val) {
                                  setState(() {
                                    sliderValue = val;
                                  });
                                }),
                          ),
                          rangeWidget(currentWidth, currentHeight, textScale),
                          SizedBox(
                            height: responsiveContainerSize(
                                15, currentWidth, currentHeight),
                          ),
                        ],
                      )),
                  SizedBox(
                    height: responsiveContainerSize(
                        30, currentWidth, currentHeight),
                  ),
                  continueButton(checkSTatus, currentWidth, currentHeight,
                      textScale, context)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
