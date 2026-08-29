import 'package:attend_ease/core/constants/app_colors.dart';
import 'package:attend_ease/core/constants/app_spacing.dart';
import 'package:attend_ease/core/constants/app_text_styles.dart';
import 'package:attend_ease/core/utils/attendance_time.dart';
import 'package:attend_ease/features/auth/widgets/otp_auth_widgets.dart';
import 'package:attend_ease/features/company/services/company_service.dart';
import 'package:attend_ease/shared/widgets/app_card.dart';
import 'package:attend_ease/shared/widgets/app_text_field.dart';
import 'package:attend_ease/shared/widgets/primary_button.dart';
import 'package:attend_ease/shared/widgets/skeleton_box.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ManageHolidaysScreen extends StatefulWidget {
  const ManageHolidaysScreen({super.key});

  @override
  State<ManageHolidaysScreen> createState() => _ManageHolidaysScreenState();
}

class _ManageHolidaysScreenState extends State<ManageHolidaysScreen> {
  final CompanyService _service = CompanyService();
  final _nameCtrl = TextEditingController();
  final _dateFmt = DateFormat('dd/MM/yy');
  final _displayFmt = DateFormat('dd MMM yyyy');
  DateTime? _pickedDate;
  List<dynamic> _holidays = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchHolidays());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchHolidays() async {
    setState(() => _loading = true);
    final res = await _service.getHolidays();
    if (!mounted) return;
    if (res.success && res.data != null) {
      final list = [...res.data!];
      list.sort((a, b) {
        final da = AttendanceTime.parseEntryDate(a['date'] as String? ?? '') ?? DateTime(0);
        final db = AttendanceTime.parseEntryDate(b['date'] as String? ?? '') ?? DateTime(0);
        return da.compareTo(db);
      });
      setState(() => _holidays = list);
    }
    setState(() => _loading = false);
  }

  Future<void> _showAddDialog() async {
    _nameCtrl.clear();
    _pickedDate = null;
    final added = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text('Add Holiday', style: AppTextStyles.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () async {
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: dialogContext,
                    initialDate: _pickedDate ?? now,
                    firstDate: DateTime(now.year - 1),
                    lastDate: DateTime(now.year + 2),
                  );
                  if (picked != null) setDialogState(() => _pickedDate = picked);
                },
                child: AppCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_rounded,
                          size: 16,
                          color: _pickedDate != null
                              ? AppColors.secondary
                              : AppColors.textHint),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        _pickedDate != null
                            ? _displayFmt.format(_pickedDate!)
                            : 'Select date',
                        style: AppTextStyles.body.copyWith(
                          color: _pickedDate != null
                              ? AppColors.textPrimary
                              : AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _nameCtrl,
                label: 'Holiday Name',
                hint: 'e.g. Republic Day',
                prefixIcon: Icons.event_rounded,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            PrimaryButton(
              label: 'Add',
              width: 112,
              height: 40,
              icon: Icons.add_rounded,
              onPressed: () {
                if (_pickedDate == null || _nameCtrl.text.trim().isEmpty) return;
                Navigator.pop(dialogContext, true);
              },
            ),
          ],
        ),
      ),
    );
    if (added != true || !mounted) return;

    final res = await _service.addHoliday(_dateFmt.format(_pickedDate!), _nameCtrl.text.trim());
    if (!mounted) return;
    if (res.success) {
      toastMessageSuccess(context, 'Added', 'Holiday added.');
      _fetchHolidays();
    } else {
      toastMessageError(context, 'Error', res.message);
    }
  }

  Future<void> _confirmRemove(String id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Remove $name?', style: AppTextStyles.title),
        content: const Text(
          'This date will no longer be marked as a company holiday.',
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
            icon: Icons.delete_rounded,
            color: AppColors.error,
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final res = await _service.removeHoliday(id);
    if (!mounted) return;
    if (res.success) {
      toastMessageSuccess(context, 'Removed', '$name has been removed.');
      _fetchHolidays();
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
          title: Text('Company Holidays', style: AppTextStyles.title),
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
        ),
        body: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _fetchHolidays,
          child: _loading
              ? const _HolidayListSkeleton()
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PrimaryButton(
                        label: 'Add Holiday',
                        icon: Icons.add_rounded,
                        onPressed: _showAddDialog,
                        height: 46,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Holidays', style: AppTextStyles.title),
                          Text('${_holidays.length} total', style: AppTextStyles.caption),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      if (_holidays.isEmpty)
                        AppCard(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                          child: Center(
                            child: Column(
                              children: [
                                const Icon(Icons.event_busy_rounded,
                                    size: 36, color: AppColors.textHint),
                                const SizedBox(height: AppSpacing.sm),
                                Text('No holidays added yet.',
                                    style: AppTextStyles.body
                                        .copyWith(color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _holidays.length,
                          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                          itemBuilder: (context, index) {
                            final holiday = _holidays[index];
                            final id = holiday['id'] as String? ?? '';
                            final date = holiday['date'] as String? ?? '';
                            final name = holiday['name'] as String? ?? '?';
                            return AppCard(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(AppRadius.sm),
                                    ),
                                    child: const Icon(Icons.event_rounded,
                                        color: AppColors.secondary, size: 20),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(name, style: AppTextStyles.bodyMedium),
                                        Text(date,
                                            style: AppTextStyles.caption
                                                .copyWith(color: AppColors.textSecondary)),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_rounded,
                                        color: AppColors.error, size: 20),
                                    onPressed: () => _confirmRemove(id, name),
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

class _HolidayListSkeleton extends StatelessWidget {
  const _HolidayListSkeleton();

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
