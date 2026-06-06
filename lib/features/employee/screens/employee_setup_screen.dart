import 'package:attend_ease/core/constants/app_colors.dart';
import 'package:attend_ease/core/constants/app_spacing.dart';
import 'package:attend_ease/core/constants/app_text_styles.dart';
import 'package:attend_ease/core/storage/local_storage.dart';
import 'package:attend_ease/core/di/service_locator.dart';
import 'package:attend_ease/core/router/app_router.dart';
import 'package:attend_ease/core/utils/validators.dart';
import 'package:attend_ease/features/attendance/providers/attendance_provider.dart';
import 'package:attend_ease/features/auth/providers/auth_provider.dart';
import 'package:attend_ease/features/auth/widgets/otp_auth_widgets.dart';
import 'package:attend_ease/features/employee/services/employee_service.dart';
import 'package:attend_ease/shared/widgets/app_text_field.dart';
import 'package:attend_ease/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class EmployeeSetupScreen extends StatefulWidget {
  const EmployeeSetupScreen({super.key});

  @override
  State<EmployeeSetupScreen> createState() => _EmployeeSetupScreenState();
}

class _EmployeeSetupScreenState extends State<EmployeeSetupScreen> {
  final EmployeeService _service = getIt<EmployeeService>();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final TextEditingController _companyCtrl = TextEditingController();
  final TextEditingController _idCtrl = TextEditingController();

  @override
  void dispose() {
    _companyCtrl.dispose();
    _idCtrl.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final employeeCompanyName = _companyCtrl.text.trim();
    final employeeID = _idCtrl.text.trim();
    final employeeName = employeeID.substring(0, employeeID.indexOf('_'));

    setState(() => _isLoading = true);

    final res =
        await _service.joinCompany(employeeCompanyName, employeeID, employeeName);
    context.read<AttendanceProvider>().reset();

    if (!mounted) return;

    if (res.success) {
      await HelperFunctions.setStatus(true);
      await HelperFunctions.setEmployeeCompany(employeeCompanyName);
      await HelperFunctions.setEmployeeName(employeeName);
      await HelperFunctions.setEmployeeID(employeeID);
      if (res.data != null) await HelperFunctions.setEmployeeToken(res.data!);

      final eID = employeeID.substring(employeeID.indexOf('_') + 1);
      context.read<AuthProvider>().setEmployeeSession(
            employeeName,
            eID,
            employeeCompanyName,
          );

      if (!mounted) return;
      context.go(AppRoutes.employeeDashboard);
    } else {
      setState(() => _isLoading = false);
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
        title: Text('Join Company', style: AppTextStyles.title),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Step indicator ─────────────────────────────
                    _StepIndicator(),
                    const SizedBox(height: AppSpacing.xl),

                    // ── Info banner ────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryLight,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline_rounded,
                              color: AppColors.secondary, size: 18),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'Your Employee ID is provided by your HR.\n'
                              'Format: Name_XXXXXX  (e.g. Nikhil_a3b4c5)',
                              style: AppTextStyles.caption
                                  .copyWith(color: AppColors.secondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // ── Company name ───────────────────────────────
                    AppTextField(
                      controller: _companyCtrl,
                      label: 'Company Name',
                      hint: 'ABC Pvt. Ltd.',
                      prefixIcon: Icons.business_rounded,
                      validator: (v) =>
                          Validators.required(v, field: 'Company name'),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // ── Employee ID ────────────────────────────────
                    AppTextField(
                      controller: _idCtrl,
                      label: 'Employee ID',
                      hint: 'Nikhil_a3b4c5',
                      prefixIcon: Icons.badge_rounded,
                      validator: Validators.employeeId,
                      suffix: ValueListenableBuilder(
                        valueListenable: _idCtrl,
                        builder: (_, value, __) {
                          final text = value.text;
                          final valid = text.contains('_') &&
                              text.indexOf('_') > 0 &&
                              text.indexOf('_') < text.length - 1;
                          if (text.isEmpty) return const SizedBox.shrink();
                          return Icon(
                            valid
                                ? Icons.check_circle_rounded
                                : Icons.cancel_rounded,
                            size: 18,
                            color: valid
                                ? AppColors.success
                                : AppColors.error,
                          );
                        },
                      ),
                    ),
                    // Format hint below ID field
                    Padding(
                      padding: const EdgeInsets.only(
                          top: AppSpacing.xs, left: 4),
                      child: Text(
                        'Format: YourName_UniqueCode',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textHint),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // ── Submit ─────────────────────────────────────
                    PrimaryButton(
                      label: 'Join Company',
                      onPressed: _continue,
                      color: AppColors.secondary,
                      icon: Icons.arrow_forward_rounded,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Divider(color: AppColors.divider, thickness: 1),
                    const SizedBox(height: AppSpacing.md),

                    PrimaryButton(
                      label: 'Login as HR',
                      onPressed: () => context.push(AppRoutes.companyLogin),
                      variant: ButtonVariant.outlined,
                      color: AppColors.primary,
                      icon: Icons.admin_panel_settings_rounded,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

// ── Step indicator ────────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  static const _steps = ['Enter Details', 'Join Company', 'Dashboard'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          // Connector line
          final filled = i < 3; // steps 0→1 connector filled (current step = 1)
          return Expanded(
            child: Container(
              height: 2,
              color: filled
                  ? AppColors.secondary.withValues(alpha: 0.4)
                  : AppColors.surfaceVariant,
            ),
          );
        }
        final stepIndex = i ~/ 2;
        final isDone = stepIndex == 0;
        final isActive = stepIndex == 1;

        Color dotColor;
        Widget dotChild;
        if (isDone) {
          dotColor = AppColors.secondary;
          dotChild = const Icon(Icons.check_rounded,
              color: Colors.white, size: 12);
        } else if (isActive) {
          dotColor = AppColors.primary;
          dotChild = Text('${stepIndex + 1}',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold));
        } else {
          dotColor = AppColors.surfaceVariant;
          dotChild = Text('${stepIndex + 1}',
              style: TextStyle(
                  color: AppColors.textHint,
                  fontSize: 11,
                  fontWeight: FontWeight.bold));
        }

        return Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
                border: isActive
                    ? Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        width: 3)
                    : null,
              ),
              child: Center(child: dotChild),
            ),
            const SizedBox(height: 4),
            Text(
              _steps[stepIndex],
              style: AppTextStyles.caption.copyWith(
                color: isActive
                    ? AppColors.primary
                    : isDone
                        ? AppColors.secondary
                        : AppColors.textHint,
                fontWeight:
                    isActive ? FontWeight.w600 : FontWeight.w400,
                fontSize: 9,
              ),
            ),
          ],
        );
      }),
    );
  }
}
