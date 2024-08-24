import 'package:attend_ease/constants/colors.dart';
import 'package:attend_ease/constants/scale.dart';
import 'package:attend_ease/globalobjects/variables.dart';
import 'package:attend_ease/widgets/otp_auth_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:lottie/lottie.dart';

class BiomAuth extends StatefulWidget {
  const BiomAuth({super.key});

  @override
  State<BiomAuth> createState() => _BiomAuthState();
}

class _BiomAuthState extends State<BiomAuth> {
  late final LocalAuthentication auth;
  bool _supoortState = false;
  bool isValid = false;

  Future<void> _getBiometrics() async {
    List<BiometricType> availableBiometrics =
        await auth.getAvailableBiometrics();

    if (!mounted) {
      return;
    }

    authenticate();
  }

  Future<void> authenticate() async {
    try {
      bool authenticated = await auth.authenticate(
          options: const AuthenticationOptions(
            stickyAuth: true,
          ),
          localizedReason: "Authenticate your Fingerprint To proceed further.");
      setState(() {
        isValid = authenticated;
        isAuthenticate = isValid;
      });
      isValid
          ? Navigator.pop(context)
          : toastMessageError(context, "Error!", "Invalid Biometric ID");
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    auth = LocalAuthentication();
    auth.isDeviceSupported().then((bool isDeviceSupported) => setState(() {
          _supoortState = isDeviceSupported;
        }));
    if (!_supoortState) {
      print("Eroor ");
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentHeight = MediaQuery.of(context).size.height;
    final currentWidth = MediaQuery.of(context).size.width;
    // ignore: deprecated_member_use
    final textScale = MediaQuery.of(context).textScaleFactor;
    return SafeArea(
      child: Scaffold(
        body: Container(
          padding: EdgeInsets.symmetric(
              vertical: 70 * verticalPaddingFactor(currentHeight)),
          decoration: BoxDecoration(
              border: Border.all(color: BUTTON_COLOR_1, width: 10)),
          child: Center(
            child: Column(
              children: [
                LottieBuilder.asset(
                  "assets/animations/finger.json",
                  height:
                      responsiveContainerSize(350, currentWidth, currentHeight),
                  width:
                      responsiveContainerSize(350, currentWidth, currentHeight),
                ),
                Text(
                  "Click To Verify Biometric ID",
                  style: GoogleFonts.notoSansOldHungarian(
                      fontSize: responsiveFontSize(
                          28, currentWidth, currentHeight, textScale),
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                Text(
                  "For Attendance",
                  style: GoogleFonts.notoSansOldHungarian(
                      fontSize: responsiveFontSize(
                          28, currentWidth, currentHeight, textScale),
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                SizedBox(
                  height:
                      responsiveContainerSize(28, currentWidth, currentHeight),
                ),
                InkWell(
                  onTap: () {
                    _getBiometrics();
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: 70 * horizontalPaddingFactor(currentWidth),
                    ),
                    padding: EdgeInsets.symmetric(
                        horizontal: 5 * horizontalPaddingFactor(currentWidth),
                        vertical: 5 * verticalPaddingFactor(currentHeight)),
                    height: responsiveContainerSize(
                        60, currentWidth, currentHeight),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                            responsiveBorderRadius(
                                10, currentWidth, currentHeight)),
                        color: BUTTON_COLOR_1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Authenticate",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: responsiveFontSize(
                                  24, currentWidth, currentHeight, textScale),
                              fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.fingerprint,
                            color: Colors.white,
                            size: responsiveContainerSize(
                                26, currentWidth, currentHeight),
                          ),
                          onPressed: () {},
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
