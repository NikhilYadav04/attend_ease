import 'package:attend_ease/core/constants/app_colors.dart';
import 'package:attend_ease/core/constants/app_text_styles.dart';
import 'package:attend_ease/core/storage/local_storage.dart';
import 'package:attend_ease/features/employee/screens/employee_main_screen_1.dart';
import 'package:attend_ease/features/employee/screens/employee_main_screen_2.dart';
import 'package:attend_ease/features/employee/screens/employee_main_screen_3.dart';
import 'package:attend_ease/features/leave/screens/my_leaves_screen.dart';
import 'package:attend_ease/features/auth/providers/auth_provider.dart';
import 'package:attend_ease/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class EmployeeMainScreen extends StatefulWidget {
  const EmployeeMainScreen({super.key});

  @override
  State<EmployeeMainScreen> createState() => _EmployeeMainScreenState();
}

class _EmployeeMainScreenState extends State<EmployeeMainScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void switchTab(int index) {
    _tabController.animateTo(index);
  }

  @override
  Widget build(BuildContext context) {
    final eName = context.watch<AuthProvider>().eName ?? 'Employee';

    return DefaultTabController(
      length: 4,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: AppColors.surface,
            elevation: 0,
            titleSpacing: 16,
            title: Row(
              children: [
                GestureDetector(
                  onTap: () => context.push(AppRoutes.employeeProfile),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.secondaryLight,
                    child: Text(
                      eName.isNotEmpty ? eName[0].toUpperCase() : 'E',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.secondary),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(eName,
                          style: AppTextStyles.title,
                          overflow: TextOverflow.ellipsis),
                      Text('Employee', style: AppTextStyles.caption),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_rounded,
                    color: AppColors.textSecondary),
                onPressed: () async {
                  await HelperFunctions.setStatus(false);
                  await HelperFunctions.setEmployeeName('');
                  await HelperFunctions.setEmployeeID('');
                  if (!context.mounted) return;
                  context.go(AppRoutes.otp);
                },
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.secondary,
              indicatorWeight: 2,
              labelColor: AppColors.secondary,
              unselectedLabelColor: AppColors.textSecondary,
              tabs: const [
                Tab(icon: Icon(Icons.home_rounded), text: 'Home'),
                Tab(icon: Icon(Icons.fingerprint_rounded), text: 'Attendance'),
                Tab(icon: Icon(Icons.calendar_month_rounded), text: 'History'),
                Tab(icon: Icon(Icons.event_note_rounded), text: 'Leaves'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              EmployeeMainScreen1(onSwitchTab: switchTab),
              const EmployeeMainScreen2(),
              const EmployeeMainScreen3(),
              const MyLeavesScreen(),
            ],
          ),
        ),
      ),
    );
  }
}
