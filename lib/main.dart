import 'package:attend_ease/globalobjects/variables.dart';
import 'package:attend_ease/screens/company_hr_screen.dart';
import 'package:attend_ease/screens/employee_main_screen.dart';
import 'package:attend_ease/screens/employee_setup_screen.dart';
import 'package:attend_ease/screens/home_screen.dart';
import 'package:attend_ease/screens/otp_auth_screen.dart';
import 'package:flutter/material.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  // runApp(DevicePreview(enabled: !kReleaseMode, builder: (context) => MyApp()));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Attend Ease',
        home: HomeScreen());
  }
}
