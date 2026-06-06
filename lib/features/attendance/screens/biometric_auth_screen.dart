import 'package:attend_ease/core/constants/app_colors.dart';
import 'package:attend_ease/core/constants/app_spacing.dart';
import 'package:attend_ease/core/constants/app_text_styles.dart';
import 'package:attend_ease/features/auth/providers/auth_provider.dart';
import 'package:attend_ease/features/auth/widgets/otp_auth_widgets.dart';
import 'package:attend_ease/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class BiomAuth extends StatefulWidget {
  const BiomAuth({super.key});

  @override
  State<BiomAuth> createState() => _BiomAuthState();
}

class _BiomAuthState extends State<BiomAuth> {
  final LocalAuthentication _auth = LocalAuthentication();
  bool _isAuthenticating = false;
  bool _isSupported = false;

  @override
  void initState() {
    super.initState();
    _auth.isDeviceSupported().then((supported) {
      if (mounted) setState(() => _isSupported = supported);
    });
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;
    setState(() => _isAuthenticating = true);

    try {
      final authenticated = await _auth.authenticate(
        localizedReason: 'Verify your fingerprint to mark attendance.',
        options: const AuthenticationOptions(stickyAuth: true),
      );
      if (!mounted) return;

      context.read<AuthProvider>().setAuthenticated(authenticated);

      if (authenticated) {
        Navigator.pop(context);
      } else {
        toastMessageError(
            context, 'Failed', 'Biometric not recognised. Try again.');
      }
    } catch (e) {
      if (mounted) {
        toastMessageError(context, 'Error', 'Authentication error: $e');
      }
    } finally {
      if (mounted) setState(() => _isAuthenticating = false);
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
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Biometric Auth', style: AppTextStyles.title),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              const Spacer(),

              // Lottie animation
              Lottie.asset(
                'assets/animations/finger.json',
                width: 220,
                height: 220,
              ),
              const SizedBox(height: AppSpacing.lg),

              Text('Fingerprint Verification',
                  style: AppTextStyles.headline,
                  textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _isSupported
                    ? 'Place your finger on the sensor to\nauthenticate and mark attendance.'
                    : 'Biometric authentication is not supported\non this device.',
                style: AppTextStyles.body
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Status indicator
              if (_isAuthenticating)
                Column(
                  children: [
                    const CircularProgressIndicator(
                        color: AppColors.secondary),
                    const SizedBox(height: AppSpacing.sm),
                    Text('Verifying...',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textSecondary)),
                  ],
                )
              else
                PrimaryButton(
                  label: 'Authenticate',
                  icon: Icons.fingerprint_rounded,
                  color: AppColors.secondary,
                  onPressed: _isSupported ? _authenticate : null,
                ),

              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style:
                      AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
