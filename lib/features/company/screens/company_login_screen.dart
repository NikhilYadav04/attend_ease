import 'package:attend_ease/core/constants/app_colors.dart';
import 'package:attend_ease/core/constants/app_spacing.dart';
import 'package:attend_ease/core/constants/app_text_styles.dart';
import 'package:attend_ease/core/storage/local_storage.dart';
import 'package:attend_ease/core/di/service_locator.dart';
import 'package:attend_ease/core/router/app_router.dart';
import 'package:attend_ease/core/utils/validators.dart';
import 'package:attend_ease/features/auth/providers/auth_provider.dart';
import 'package:attend_ease/features/auth/widgets/otp_auth_widgets.dart';
import 'package:attend_ease/features/company/services/company_service.dart';
import 'package:attend_ease/shared/widgets/app_text_field.dart';
import 'package:attend_ease/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CompanyLoginScreen extends StatefulWidget {
  const CompanyLoginScreen({super.key});

  @override
  State<CompanyLoginScreen> createState() => _CompanyLoginScreenState();
}

class _CompanyLoginScreenState extends State<CompanyLoginScreen> {
  bool isLoading = false;
  final CompanyService _service = getIt<CompanyService>();

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _idCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _idCtrl.dispose();
    super.dispose();
  }

  void _login() async {
    final companyName = _nameCtrl.text.trim();
    final companyID = _idCtrl.text.trim();

    final nameErr = Validators.required(companyName, field: 'Company name');
    final idErr = Validators.companyId(companyID);
    final firstErr = nameErr ?? idErr;
    if (firstErr != null) {
      toastMessageError(context, 'Missing fields', firstErr);
      return;
    }

    setState(() => isLoading = true);

    final res = await _service.loginCompany(companyName, companyID);

    if (!mounted) return;

    if (res.success) {
      await HelperFunctions.setStatus(true);
      await HelperFunctions.setCompanyName(companyName);
      await HelperFunctions.setCompanyID(companyID);
      if (res.data != null) await HelperFunctions.setCompanyToken(res.data!);
      context.read<AuthProvider>().setCompanySession(companyName, companyID);
      if (!mounted) return;
      context.go(AppRoutes.companyDashboard);
    } else {
      setState(() => isLoading = false);
      toastMessageError(context, 'Error', res.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        automaticallyImplyLeading: true,
        title: Text('HR Login', style: AppTextStyles.title),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.admin_panel_settings_rounded,
                            color: AppColors.primary, size: 20),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Login with your Company Name and ID to access the HR dashboard.',
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  AppTextField(
                    controller: _nameCtrl,
                    label: 'Company Name',
                    hint: 'ABC Pvt. Ltd.',
                    prefixIcon: Icons.business_rounded,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  AppTextField(
                    controller: _idCtrl,
                    label: 'Company ID',
                    hint: 'ABCX3',
                    prefixIcon: Icons.tag_rounded,
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  PrimaryButton(
                    label: 'Login as HR',
                    onPressed: _login,
                    icon: Icons.login_rounded,
                  ),
                ],
              ),
            ),
    );
  }
}
