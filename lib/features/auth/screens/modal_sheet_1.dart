import 'package:attend_ease/core/constants/app_colors.dart';
import 'package:attend_ease/core/constants/app_spacing.dart';
import 'package:attend_ease/core/constants/app_text_styles.dart';
import 'package:attend_ease/core/utils/validators.dart';
import 'package:attend_ease/features/auth/providers/auth_provider.dart';
import 'package:attend_ease/core/di/service_locator.dart';
import 'package:attend_ease/core/router/app_router.dart';
import 'package:attend_ease/features/auth/services/otp_service.dart';
import 'package:attend_ease/features/auth/widgets/otp_auth_widgets.dart';
import 'package:attend_ease/shared/widgets/app_text_field.dart';
import 'package:attend_ease/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SheetScreen1 extends StatefulWidget {
  const SheetScreen1({super.key});

  @override
  State<SheetScreen1> createState() => _SheetScreen1State();
}

class _SheetScreen1State extends State<SheetScreen1> {
  bool _isLoading = false;
  final OtpService _otpService = getIt<OtpService>();
  final TextEditingController _numberCtrl = TextEditingController();

  @override
  void dispose() {
    _numberCtrl.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final phone = _numberCtrl.text.trim();
    final phoneErr = Validators.phone(phone);
    if (phoneErr != null) {
      toastMessageError(context, 'Invalid Number', phoneErr);
      return;
    }

    final fullPhone = '+91$phone';
    context.read<AuthProvider>().setPhoneNumber(fullPhone);
    _numberCtrl.clear();
    setState(() => _isLoading = true);

    final result = await _otpService.sendOTP(fullPhone);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      if (mounted) context.push(AppRoutes.otpVerify);
    } else {
      toastMessageError(context, 'Error!', result.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
          onPressed: () => context.pop(),
        ),
        title: Text('Login', style: AppTextStyles.title),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    Text('Enter your mobile number',
                        style: AppTextStyles.headline),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'We will send an OTP to verify your number.',
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Phone field with +91 prefix
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          height: 56,
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(color: AppColors.border),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/login_screen/flag.png',
                                width: 24,
                                height: 24,
                              ),
                              const SizedBox(width: 4),
                              Text('+91',
                                  style: AppTextStyles.bodyMedium),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: AppTextField(
                            controller: _numberCtrl,
                            label: 'Phone Number',
                            hint: '98765 43210',
                            prefixIcon: Icons.phone_rounded,
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    PrimaryButton(
                      label: 'Send OTP',
                      icon: Icons.send_rounded,
                      onPressed: _isLoading ? null : _continue,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Center(
                      child: Text(
                        'By continuing, you agree to our Terms & Conditions',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textHint),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
