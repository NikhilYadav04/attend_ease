import 'package:attend_ease/core/constants/app_colors.dart';
import 'package:attend_ease/core/constants/app_spacing.dart';
import 'package:attend_ease/core/constants/app_text_styles.dart';
import 'package:attend_ease/core/storage/local_storage.dart';
import 'package:attend_ease/core/di/service_locator.dart';
import 'package:attend_ease/core/router/app_router.dart';
import 'package:attend_ease/features/auth/providers/auth_provider.dart';
import 'package:attend_ease/features/auth/services/auth_service.dart';
import 'package:attend_ease/features/auth/services/otp_service.dart';
import 'package:attend_ease/features/auth/widgets/otp_auth_widgets.dart';
import 'package:attend_ease/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class SheetScreen2 extends StatefulWidget {
  const SheetScreen2({super.key});

  @override
  State<SheetScreen2> createState() => _SheetScreen2State();
}

class _SheetScreen2State extends State<SheetScreen2> {
  bool _isLoading = false;
  final OtpService _otpService = getIt<OtpService>();
  final AuthService _authService = getIt<AuthService>();
  final TextEditingController _otpCtrl = TextEditingController();

  @override
  void dispose() {
    _otpCtrl.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final otp = _otpCtrl.text.trim();
    if (otp.length != 6) {
      toastMessageError(context, 'Invalid OTP', 'Please enter the 6-digit OTP.');
      return;
    }

    context.read<AuthProvider>().setOtp(otp);
    _otpCtrl.clear();
    setState(() => _isLoading = true);

    final phone = context.read<AuthProvider>().phoneNumber;
    final otpResult = await _otpService.verifyOTP(phone, otp);
    if (!mounted) return;

    if (!otpResult.success || otpResult.data == null) {
      setState(() => _isLoading = false);
      toastMessageError(context, 'Error!', otpResult.message);
      return;
    }

    final otpToken = otpResult.data!;
    context.read<AuthProvider>().setOtpToken(otpToken);

    // OTP verified — persist phone and identify role
    await HelperFunctions.setPhone(phone);

    final identifyResult = await _authService.identify(phone, otpToken);
    if (!mounted) return;

    if (!identifyResult.success) {
      setState(() => _isLoading = false);
      toastMessageError(context, 'Error', identifyResult.message);
      return;
    }

    final data = identifyResult.data!;

    if (data.role == 'hr') {
      await HelperFunctions.setStatus(true);
      await HelperFunctions.setCompanyName(data.companyName!);
      await HelperFunctions.setCompanyID(data.companyID!);
      await HelperFunctions.setCompanyToken(data.token!);
      if (data.adminName != null) await HelperFunctions.setAdminName(data.adminName!);
      if (!mounted) return;
      context.read<AuthProvider>().setCompanySession(
            data.companyName!, data.companyID!,
            admin: data.adminName,
          );
      context.go(AppRoutes.companyDashboard);
      return;
    }

    if (data.role == 'employee') {
      await HelperFunctions.setStatus(true);
      await HelperFunctions.setEmployeeCompany(data.employeeCompany!);
      await HelperFunctions.setEmployeeName(data.employeeName!);
      await HelperFunctions.setEmployeeID(data.employeeID!);
      await HelperFunctions.setEmployeeToken(data.token!);
      if (!mounted) return;
      // employeeID format is Name_CompanyID; eID is the part after '_'
      final eID = data.employeeID!.contains('_')
          ? data.employeeID!.substring(data.employeeID!.indexOf('_') + 1)
          : data.employeeID!;
      context.read<AuthProvider>().setEmployeeSession(
            data.employeeName!,
            eID,
            data.employeeCompany!,
          );
      context.go(AppRoutes.employeeDashboard);
      return;
    }

    // role == 'none' — new user, go to home to create a company
    if (!mounted) return;
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final phone = context.watch<AuthProvider>().phoneNumber;

    final defaultPinTheme = PinTheme(
      width: 52,
      height: 56,
      textStyle: AppTextStyles.title.copyWith(color: AppColors.textPrimary),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppColors.primary, width: 2),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: AppColors.primaryContainer,
        border: Border.all(color: AppColors.primary),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.textSecondary),
          onPressed: () => context.pop(),
        ),
        title: Text('Verify OTP', style: AppTextStyles.title),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    Text('Enter verification code',
                        style: AppTextStyles.headline),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'We sent an OTP to $phone',
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    Center(
                      child: Pinput(
                        controller: _otpCtrl,
                        length: 6,
                        defaultPinTheme: defaultPinTheme,
                        focusedPinTheme: focusedPinTheme,
                        submittedPinTheme: submittedPinTheme,
                        onCompleted: (_) => _verify(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    PrimaryButton(
                      label: 'Verify & Continue',
                      icon: Icons.verified_rounded,
                      onPressed: _isLoading ? null : _verify,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Center(
                      child: TextButton(
                        onPressed: () => context.pop(),
                        child: Text(
                          'Change phone number',
                          style: AppTextStyles.body
                              .copyWith(color: AppColors.primary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
