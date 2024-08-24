import 'package:attend_ease/constants/colors.dart';
import 'package:attend_ease/constants/scale.dart';
import 'package:attend_ease/screens/employee_main_screen_1.dart';
import 'package:attend_ease/screens/employee_main_screen_2.dart';
import 'package:attend_ease/screens/employee_main_screen_3.dart';
import 'package:attend_ease/widgets/employee_main_widgets.dart';
import 'package:flutter/material.dart';

class EmployeeMainScreen extends StatefulWidget {
  const EmployeeMainScreen({super.key});

  @override
  State<EmployeeMainScreen> createState() => _EmployeeMainScreenState();
}

class _EmployeeMainScreenState extends State<EmployeeMainScreen>
    with SingleTickerProviderStateMixin {
  late final TabController? tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentHeight = MediaQuery.of(context).size.height;
    final currentWidth = MediaQuery.of(context).size.width;
    // ignore: deprecated_member_use
    final textScale = MediaQuery.of(context).textScaleFactor;
    return DefaultTabController(
      length: 3,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            toolbarHeight:
                responsiveContainerSize(75, currentWidth, currentHeight),
            title: appBartitle(currentWidth, currentHeight, textScale),
            actions: actions(currentWidth, currentHeight, textScale, context),
          ),
          body: Column(
            children: [
              TabBar(
                  padding: EdgeInsets.only(
                      top: 4 * verticalPaddingFactor(currentHeight)),
                  indicatorColor: DARK_BLUE,
                  indicatorWeight: 1,
                  controller: tabController,
                  tabs: [
                    Tab(
                      icon: Icon(
                        Icons.home,
                        size: responsiveContainerSize(
                            34, currentWidth, currentHeight),
                        color: DARK_BLUE,
                      ),
                    ),
                    Tab(
                      icon: Icon(
                        Icons.person,
                        size: responsiveContainerSize(
                            34, currentWidth, currentHeight),
                        color: DARK_BLUE,
                      ),
                    ),
                    Tab(
                      icon: Icon(
                        Icons.list_alt,
                        size: responsiveContainerSize(
                            34, currentWidth, currentHeight),
                        color: DARK_BLUE,
                      ),
                    ),
                  ]),
              Expanded(
                  child: TabBarView(controller: tabController, children: [
                EmployeeMainScreen1(
                    width: currentWidth,
                    height: currentHeight,
                    textScaleFactor: textScale),
                EmployeeMainScreen2(
                    width: currentWidth,
                    height: currentHeight,
                    textScaleFactor: textScale),
                EmployeeMainScreen3(
                    width: currentWidth,
                    height: currentHeight,
                    textScaleFactor: textScale)
              ]))
            ],
          ),
        ),
      ),
    );
  }
}
