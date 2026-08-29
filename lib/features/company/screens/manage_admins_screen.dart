import 'package:attend_ease/core/constants/app_colors.dart';
import 'package:attend_ease/core/constants/app_spacing.dart';
import 'package:attend_ease/core/constants/app_text_styles.dart';
import 'package:attend_ease/features/auth/widgets/otp_auth_widgets.dart';
import 'package:attend_ease/features/company/services/company_service.dart';
import 'package:attend_ease/shared/widgets/app_card.dart';
import 'package:attend_ease/shared/widgets/app_text_field.dart';
import 'package:attend_ease/shared/widgets/primary_button.dart';
import 'package:attend_ease/shared/widgets/skeleton_box.dart';
import 'package:flutter/material.dart';

class ManageAdminsScreen extends StatefulWidget {
  const ManageAdminsScreen({super.key});

  @override
  State<ManageAdminsScreen> createState() => _ManageAdminsScreenState();
}

class _ManageAdminsScreenState extends State<ManageAdminsScreen> {
  final CompanyService _service = CompanyService();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  List<dynamic> _admins = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchAdmins());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchAdmins() async {
    setState(() => _loading = true);
    final res = await _service.getAdmins();
    if (!mounted) return;
    if (res.success && res.data != null) {
      setState(() => _admins = res.data!);
    }
    setState(() => _loading = false);
  }

  Future<void> _showAddDialog() async {
    _nameCtrl.clear();
    _phoneCtrl.clear();
    final added = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Add Admin', style: AppTextStyles.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              controller: _nameCtrl,
              label: 'Name',
              hint: 'Admin\'s full name',
              prefixIcon: Icons.person_rounded,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _phoneCtrl,
              label: 'Phone Number',
              hint: 'Their login phone number',
              prefixIcon: Icons.phone_rounded,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          PrimaryButton(
            label: 'Add',
            width: 112,
            height: 40,
            icon: Icons.add_rounded,
            onPressed: () {
              final name = _nameCtrl.text.trim();
              final phone = _phoneCtrl.text.trim();
              if (name.isEmpty || phone.isEmpty) return;
              Navigator.pop(context, true);
            },
          ),
        ],
      ),
    );
    if (added != true || !mounted) return;

    final res = await _service.addAdmin(_nameCtrl.text.trim(), _phoneCtrl.text.trim());
    if (!mounted) return;
    if (res.success) {
      toastMessageSuccess(context, 'Added', 'Admin added successfully.');
      _fetchAdmins();
    } else {
      toastMessageError(context, 'Error', res.message);
    }
  }

  Future<void> _confirmRemove(String name, String phone) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Remove $name?', style: AppTextStyles.title),
        content: Text(
          'They will immediately lose HR access to this company.',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          PrimaryButton(
            label: 'Remove',
            width: 132,
            height: 40,
            icon: Icons.person_remove_rounded,
            color: AppColors.error,
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final res = await _service.removeAdmin(phone);
    if (!mounted) return;
    if (res.success) {
      toastMessageSuccess(context, 'Removed', '$name has been removed.');
      _fetchAdmins();
    } else {
      toastMessageError(context, 'Error', res.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          title: Text('Manage Admins', style: AppTextStyles.title),
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
        ),
        body: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _fetchAdmins,
          child: _loading
              ? const _AdminListSkeleton()
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PrimaryButton(
                        label: 'Add Admin',
                        icon: Icons.person_add_rounded,
                        onPressed: _showAddDialog,
                        height: 46,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Admins', style: AppTextStyles.title),
                          Text('${_admins.length} total', style: AppTextStyles.caption),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _admins.length,
                        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final admin = _admins[index];
                          final name = admin['name'] as String? ?? '?';
                          final phone = admin['phone'] as String? ?? '';
                          return AppCard(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: AppColors.primaryContainer,
                                  child: Text(
                                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(name, style: AppTextStyles.bodyMedium),
                                      Text(phone,
                                          style: AppTextStyles.caption
                                              .copyWith(color: AppColors.textSecondary)),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.person_remove_rounded,
                                      color: AppColors.error, size: 20),
                                  onPressed: () => _confirmRemove(name, phone),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _AdminListSkeleton extends StatelessWidget {
  const _AdminListSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: List.generate(3, (_) => const Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.sm),
          child: SkeletonBox.wide(height: 60, borderRadius: 12),
        )),
      ),
    );
  }
}
