import 'package:attend_ease/constants/colors.dart';
import 'package:attend_ease/constants/scale.dart';
import 'package:attend_ease/screens/approval_req_screen.dart';
import 'package:attend_ease/screens/company_hr_screen_1.dart';
import 'package:attend_ease/screens/staff_list_screen.dart';
import 'package:attend_ease/widgets/company_hr_widgets.dart';
import 'package:flutter/material.dart';

class CompanyHrScreen extends StatefulWidget {
  const CompanyHrScreen({super.key});

  @override
  State<CompanyHrScreen> createState() => _CompanyHrScreenState();
}

class _CompanyHrScreenState extends State<CompanyHrScreen>
    with SingleTickerProviderStateMixin {
  late final TabController tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    tabController.dispose();
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
            automaticallyImplyLeading: false,
            elevation: 0,
            toolbarHeight:
                responsiveContainerSize(75, currentWidth, currentHeight),
            title: appBtitleHR(currentWidth, currentHeight, textScale),
            actions: actionsHR(currentWidth, currentHeight, textScale,context),
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
                        Icons.list,
                        size: responsiveContainerSize(
                            34, currentWidth, currentHeight),
                        color: DARK_BLUE,
                      ),
                    ),
                    Tab(
                      icon: Icon(
                        Icons.list_alt_sharp,
                        size: responsiveContainerSize(
                            34, currentWidth, currentHeight),
                        color: DARK_BLUE,
                      ),
                    ),
                  ]),
              Expanded(
                  child: TabBarView(controller: tabController, children: const [
                CompanyHrScreen1(),
                ApprovalReqScreen(),
                StaffListScreen()
              ]))
            ],
          ),
        ),
      ),
    );
  }
}
