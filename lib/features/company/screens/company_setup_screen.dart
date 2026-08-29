import 'package:attend_ease/core/constants/app_colors.dart';
import 'package:attend_ease/core/constants/app_spacing.dart';
import 'package:attend_ease/core/constants/app_text_styles.dart';
import 'package:attend_ease/core/storage/local_storage.dart';
import 'package:attend_ease/core/utils/validators.dart';
import 'package:attend_ease/core/di/service_locator.dart';
import 'package:attend_ease/core/router/app_router.dart';
import 'package:attend_ease/features/company/services/company_service.dart';
import 'package:attend_ease/features/auth/providers/auth_provider.dart';
import 'package:attend_ease/features/auth/widgets/otp_auth_widgets.dart';
import 'package:attend_ease/shared/widgets/app_text_field.dart';
import 'package:attend_ease/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CompanySetupScreen extends StatefulWidget {
  const CompanySetupScreen({super.key});

  @override
  State<CompanySetupScreen> createState() => _CompanySetupScreenState();
}

class _CompanySetupScreenState extends State<CompanySetupScreen> {
  bool isLoading = false;
  final CompanyService _service = getIt<CompanyService>();

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _hrCtrl = TextEditingController();
  final TextEditingController _cityCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _hrCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  void _continue() async {
    final companyName = _nameCtrl.text.trim();
    final companyHR = _hrCtrl.text.trim();
    final companyCity = _cityCtrl.text.trim();

    final nameErr = Validators.required(companyName, field: 'Company name');
    final hrErr = Validators.required(companyHR, field: 'Admin name');
    final cityErr = Validators.required(companyCity, field: 'City');
    final firstErr = nameErr ?? hrErr ?? cityErr;
    if (firstErr != null) {
      toastMessageError(context, 'Missing fields', firstErr);
      return;
    }

    setState(() => isLoading = true);

    final otpToken = context.read<AuthProvider>().otpToken;
    final hrNumber = await HelperFunctions.getPhone() ?? '';

    final res = await _service.addCompany(
        companyName, companyHR, companyCity, hrNumber, otpToken);

    if (!mounted) return;
    setState(() => isLoading = false);

    if (res.success && res.data != null) {
      final token = res.data!['token']!;
      final companyID = res.data!['companyID']!;

      await HelperFunctions.setCompanyName(companyName);
      await HelperFunctions.setCompanyID(companyID);
      await HelperFunctions.setCompanyToken(token);
      await HelperFunctions.setAdminName(companyHR);

      if (!mounted) return;
      context.read<AuthProvider>().setCompanySession(companyName, companyID, admin: companyHR);
      context.push(AppRoutes.companyLocation, extra: companyName);
    } else {
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
        automaticallyImplyLeading: false,
        title: Text('Company Setup', style: AppTextStyles.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.textSecondary),
            onPressed: () async {
              await HelperFunctions.setStatus(false);
              await HelperFunctions.setCompanyName('');
              if (!mounted) return;
              context.go(AppRoutes.otp);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Register your company to start managing staff attendance. Your Company ID will be auto-generated.',
                      style: AppTextStyles.caption.copyWith(color: AppColors.primary),
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
              controller: _hrCtrl,
              label: 'Admin Name',
              hint: 'Mr. Nikhil',
              prefixIcon: Icons.person_rounded,
            ),
            const SizedBox(height: AppSpacing.lg),

            AppTextField(
              controller: _cityCtrl,
              label: 'City',
              hint: 'Mumbai',
              prefixIcon: Icons.location_city_rounded,
            ),
            const SizedBox(height: AppSpacing.xxl),

            PrimaryButton(
              label: 'Continue',
              onPressed: isLoading ? null : _continue,
              isLoading: isLoading,
              color: AppColors.secondary,
              icon: Icons.arrow_forward_rounded,
            ),
          ],
        ),
      ),
    );
  }
}
