import 'package:attend_ease/core/constants/app_colors.dart';
import 'package:attend_ease/core/constants/app_text_styles.dart';
import 'package:attend_ease/features/company/screens/approval_req_screen.dart';
import 'package:attend_ease/features/company/screens/company_hr_screen_1.dart';
import 'package:attend_ease/features/company/screens/staff_list_screen.dart';
import 'package:attend_ease/features/auth/providers/auth_provider.dart';
import 'package:attend_ease/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CompanyHrScreen extends StatefulWidget {
  const CompanyHrScreen({super.key});

  @override
  State<CompanyHrScreen> createState() => _CompanyHrScreenState();
}

class _CompanyHrScreenState extends State<CompanyHrScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _switchTab(int index) {
    _tabController.animateTo(index);
  }

  @override
  Widget build(BuildContext context) {
    final cName = context.watch<AuthProvider>().cName ?? 'Company';

    return DefaultTabController(
      length: 3,
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
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primaryContainer,
                  child: const Icon(Icons.business_rounded,
                      color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    cName,
                    style: AppTextStyles.title,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline_rounded,
                    color: AppColors.textSecondary),
                onPressed: () => _showInfoDialog(context),
              ),
              IconButton(
                icon: const Icon(Icons.account_circle_rounded,
                    color: AppColors.textSecondary),
                onPressed: () => context.push(AppRoutes.adminProfile),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              indicatorWeight: 2,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              tabs: const [
                Tab(icon: Icon(Icons.dashboard_rounded), text: 'Dashboard'),
                Tab(
                    icon: Icon(Icons.check_circle_outline_rounded),
                    text: 'Approvals'),
                Tab(icon: Icon(Icons.people_rounded), text: 'Staff'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              CompanyHrScreen1(onSwitchTab: _switchTab),
              const ApprovalReqScreen(),
              const StaffListScreen(),
            ],
          ),
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Daily Submission', style: AppTextStyles.headline),
        content: Text(
          'Remember to submit your staff data every day before the day ends. '
          'Once submitted, counts reset to zero and appear in the history list.',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
