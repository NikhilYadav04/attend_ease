import 'package:attend_ease/core/constants/app_colors.dart';
import 'package:attend_ease/core/constants/app_spacing.dart';
import 'package:attend_ease/core/constants/app_text_styles.dart';
import 'package:attend_ease/core/router/app_router.dart';
import 'package:attend_ease/core/storage/local_storage.dart';
import 'package:attend_ease/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  static const _pages = [
    _OnboardingPage(
      title: 'Smart Attendance',
      description:
          'Login once with your phone number. Punch in and out daily — hours are tracked automatically for you.',
      asset: 'assets/home_screen/table.png',
      accentColor: AppColors.primary,
      iconBg: AppColors.primaryContainer,
      icon: Icons.access_time_rounded,
    ),
    _OnboardingPage(
      title: 'Location-verified Check-in',
      description:
          'Attendance is only marked when you\'re within your company\'s geofenced office radius. No proxy, no guesswork.',
      asset: 'assets/location_screen/map.png',
      accentColor: AppColors.secondary,
      iconBg: AppColors.secondaryLight,
      icon: Icons.my_location_rounded,
    ),
    _OnboardingPage(
      title: 'Leave at Your Fingertips',
      description:
          'Apply for leave in seconds. Admin approves or rejects with one tap, and you see the status instantly.',
      asset: 'assets/home_screen/biom.png',
      accentColor: Color(0xFFD97706),
      iconBg: Color(0xFFFFF3CD),
      icon: Icons.event_available_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    await HelperFunctions.setOnboardingSeen();
    if (!mounted) return;
    context.go(AppRoutes.otp);
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _animController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar with skip ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // App name
                  Text(
                    'AttendEase',
                    style: AppTextStyles.title.copyWith(
                      color: AppColors.primary,
                      fontFamily: 'Tansek',
                      fontSize: 18,
                    ),
                  ),
                  if (!isLast)
                    TextButton(
                      onPressed: _finish,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm),
                      ),
                      child: Text('Skip', style: AppTextStyles.bodyMedium),
                    ),
                ],
              ),
            ),

            // ── PageView ───────────────────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) =>
                    _PageContent(page: _pages[index]),
              ),
            ),

            // ── Bottom controls ────────────────────────────────────
            FadeTransition(
              opacity: _fadeAnim,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.xl,
                ),
                child: Column(
                  children: [
                    // Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOut,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: i == _currentPage ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: i == _currentPage
                                ? page.accentColor
                                : AppColors.border,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Button
                    PrimaryButton(
                      label: isLast ? 'Get Started' : 'Next',
                      icon: isLast
                          ? Icons.arrow_forward_rounded
                          : Icons.chevron_right_rounded,
                      color: isLast ? AppColors.secondary : page.accentColor,
                      onPressed: _nextPage,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Page content ─────────────────────────────────────────────────────────────

class _PageContent extends StatelessWidget {
  final _OnboardingPage page;
  const _PageContent({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Illustration card
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                boxShadow: [
                  BoxShadow(
                    color: page.accentColor.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.xl),
                child: Stack(
                  children: [
                    // Accent strip at top
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 6,
                        color: page.accentColor,
                      ),
                    ),
                    // Icon badge top-right
                    Positioned(
                      top: AppSpacing.md,
                      right: AppSpacing.md,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: page.iconBg,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Icon(page.icon,
                            color: page.accentColor, size: 20),
                      ),
                    ),
                    // Illustration
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Image.asset(
                          page.asset,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Text content
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Accent line
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: page.accentColor,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(page.title, style: AppTextStyles.headline),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  page.description,
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.textSecondary, height: 1.6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Data model ────────────────────────────────────────────────────────────────

class _OnboardingPage {
  final String title;
  final String description;
  final String asset;
  final Color accentColor;
  final Color iconBg;
  final IconData icon;

  const _OnboardingPage({
    required this.title,
    required this.description,
    required this.asset,
    required this.accentColor,
    required this.iconBg,
    required this.icon,
  });
}
