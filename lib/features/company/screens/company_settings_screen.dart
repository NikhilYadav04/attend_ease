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

class CompanySettingsScreen extends StatefulWidget {
  const CompanySettingsScreen({super.key});

  @override
  State<CompanySettingsScreen> createState() => _CompanySettingsScreenState();
}

class _CompanySettingsScreenState extends State<CompanySettingsScreen> {
  final CompanyService _service = CompanyService();
  final _cityCtrl = TextEditingController();
  final _shiftHoursCtrl = TextEditingController();
  String _companyName = '';
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetch());
  }

  @override
  void dispose() {
    _cityCtrl.dispose();
    _shiftHoursCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    final res = await _service.getCompanySettings();
    if (!mounted) return;
    if (res.success && res.data != null) {
      final hours = (res.data!['overtimeThresholdHours'] as num?)?.toDouble() ?? 9.0;
      setState(() {
        _companyName = res.data!['companyName'] as String? ?? '';
        _cityCtrl.text = res.data!['companyCity'] as String? ?? '';
        _shiftHoursCtrl.text = hours % 1 == 0 ? hours.toStringAsFixed(0) : hours.toString();
      });
    }
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    final city = _cityCtrl.text.trim();
    final shiftHours = double.tryParse(_shiftHoursCtrl.text.trim());
    if (city.isEmpty) {
      toastMessageError(context, 'Missing city', 'Enter a city.');
      return;
    }
    if (shiftHours == null || shiftHours <= 0 || shiftHours > 24) {
      toastMessageError(context, 'Invalid shift hours', 'Enter a number between 0 and 24.');
      return;
    }
    setState(() => _saving = true);
    final res = await _service.updateCompanySettings(city, shiftHours);
    if (!mounted) return;
    setState(() => _saving = false);
    if (res.success) {
      toastMessageSuccess(context, 'Saved', 'Company settings updated.');
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
          title: Text('Company Settings', style: AppTextStyles.title),
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
        ),
        body: _loading
            ? const _SettingsSkeleton()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppCard(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Company Name', style: AppTextStyles.bodyMedium),
                          const SizedBox(height: AppSpacing.xs),
                          Text(_companyName,
                              style: AppTextStyles.body
                                  .copyWith(color: AppColors.textSecondary)),
                          const SizedBox(height: AppSpacing.xs),
                          Row(
                            children: [
                              const Icon(Icons.info_outline_rounded,
                                  size: 14, color: AppColors.textHint),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  "Can't be changed — it's tied to every employee's login.",
                                  style: AppTextStyles.caption
                                      .copyWith(color: AppColors.textHint),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _cityCtrl,
                      label: 'City',
                      hint: 'Company city',
                      prefixIcon: Icons.location_city_rounded,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _shiftHoursCtrl,
                      label: 'Standard Shift Hours',
                      hint: 'e.g. 9',
                      prefixIcon: Icons.timer_rounded,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            size: 14, color: AppColors.textHint),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Days worked past this many hours are flagged as overtime.',
                            style: AppTextStyles.caption.copyWith(color: AppColors.textHint),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    PrimaryButton(
                      label: 'Save',
                      icon: Icons.save_rounded,
                      isLoading: _saving,
                      onPressed: _saving ? null : _save,
                      height: 46,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _SettingsSkeleton extends StatelessWidget {
  const _SettingsSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox.wide(height: 80, borderRadius: 12),
          SizedBox(height: AppSpacing.md),
          SkeletonBox.wide(height: 56, borderRadius: 12),
        ],
      ),
    );
  }
}
