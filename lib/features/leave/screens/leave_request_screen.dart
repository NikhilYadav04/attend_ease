import 'package:attend_ease/core/constants/app_colors.dart';
import 'package:attend_ease/core/constants/app_spacing.dart';
import 'package:attend_ease/core/constants/app_text_styles.dart';
import 'package:attend_ease/features/auth/widgets/otp_auth_widgets.dart';
import 'package:attend_ease/features/leave/services/leave_service.dart';
import 'package:attend_ease/shared/widgets/app_card.dart';
import 'package:attend_ease/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LeaveRequestScreen extends StatefulWidget {
  const LeaveRequestScreen({super.key});

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  final LeaveService _service = LeaveService();
  final _reasonCtrl = TextEditingController();
  String _leaveType = 'Sick';
  DateTime? _fromDate;
  DateTime? _toDate;
  bool _loading = false;

  static const _types = ['Sick', 'Casual', 'Annual', 'Emergency'];
  static const _maxReasonLength = 200;
  final _dateFmt = DateFormat('dd/MM/yy');
  final _displayFmt = DateFormat('dd MMM yy');

  static const _typeIcons = {
    'Sick': Icons.medical_services_rounded,
    'Casual': Icons.beach_access_rounded,
    'Annual': Icons.event_available_rounded,
    'Emergency': Icons.warning_amber_rounded,
  };

  static const _typeColors = {
    'Sick': Color(0xFF0284C7),
    'Casual': AppColors.secondary,
    'Annual': AppColors.primary,
    'Emergency': Color(0xFFD97706),
  };

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  int _workingDays(DateTime from, DateTime to) {
    int count = 0;
    DateTime current = from;
    while (!current.isAfter(to)) {
      if (current.weekday != DateTime.saturday &&
          current.weekday != DateTime.sunday) {
        count++;
      }
      current = current.add(const Duration(days: 1));
    }
    return count;
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? now : (_fromDate ?? now),
      firstDate: now,
      lastDate: DateTime(now.year + 1),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.secondary,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() => isFrom ? _fromDate = picked : _toDate = picked);
  }

  Future<void> _submit() async {
    if (_fromDate == null || _toDate == null) {
      toastMessageError(context, 'Missing dates', 'Select from and to dates.');
      return;
    }
    if (_toDate!.isBefore(_fromDate!)) {
      toastMessageError(
          context, 'Invalid range', 'To date must be on or after from date.');
      return;
    }
    if (_reasonCtrl.text.trim().isEmpty) {
      toastMessageError(context, 'Missing reason', 'Please enter a reason.');
      return;
    }
    setState(() => _loading = true);
    final res = await _service.requestLeave(
      _leaveType,
      _dateFmt.format(_fromDate!),
      _dateFmt.format(_toDate!),
      _reasonCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (res.success) {
      toastMessageSuccess(context, 'Success!', 'Leave request submitted.');
      Navigator.pop(context, true);
    } else {
      toastMessageError(context, 'Error!', res.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reasonLen = _reasonCtrl.text.length;
    final hasBothDates = _fromDate != null && _toDate != null;
    final daysCount = hasBothDates && !_toDate!.isBefore(_fromDate!)
        ? _workingDays(_fromDate!, _toDate!)
        : 0;
    final activeColor = _typeColors[_leaveType] ?? AppColors.secondary;

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          title: Text('Request Leave', style: AppTextStyles.title),
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Leave type chips ───────────────────────────────────
              Text('Leave Type', style: AppTextStyles.bodyMedium),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: _types.map((type) {
                  final selected = _leaveType == type;
                  final color = _typeColors[type]!;
                  final icon = _typeIcons[type]!;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: type != _types.last ? AppSpacing.xs : 0,
                      ),
                      child: GestureDetector(
                        onTap: () => setState(() => _leaveType = type),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: selected
                                ? color.withValues(alpha: 0.12)
                                : AppColors.surface,
                            border: Border.all(
                              color: selected ? color : AppColors.border,
                              width: selected ? 1.5 : 1,
                            ),
                            borderRadius:
                                BorderRadius.circular(AppRadius.md),
                          ),
                          child: Column(
                            children: [
                              Icon(icon,
                                  color: selected
                                      ? color
                                      : AppColors.textSecondary,
                                  size: 20),
                              const SizedBox(height: 4),
                              Text(
                                type,
                                style: AppTextStyles.caption.copyWith(
                                  color: selected
                                      ? color
                                      : AppColors.textSecondary,
                                  fontWeight: selected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.md),

              // ── Date pickers ───────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _DateTile(
                      label: 'From Date',
                      date: _fromDate,
                      displayFmt: _displayFmt,
                      onTap: () => _pickDate(isFrom: true),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _DateTile(
                      label: 'To Date',
                      date: _toDate,
                      displayFmt: _displayFmt,
                      onTap: () => _pickDate(isFrom: false),
                    ),
                  ),
                ],
              ),

              // ── Duration counter ───────────────────────────────────
              if (hasBothDates) ...[
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: daysCount > 0
                        ? activeColor.withValues(alpha: 0.08)
                        : const Color(0xFFFFE4E6),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(
                      color: daysCount > 0
                          ? activeColor.withValues(alpha: 0.3)
                          : AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: daysCount > 0 ? activeColor : AppColors.error,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        daysCount > 0
                            ? 'Duration: $daysCount working day${daysCount == 1 ? '' : 's'}'
                            : 'Invalid date range',
                        style: AppTextStyles.caption.copyWith(
                          color: daysCount > 0 ? activeColor : AppColors.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),

              // ── Reason field with char count ───────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Reason', style: AppTextStyles.bodyMedium),
                  Text(
                    '$reasonLen / $_maxReasonLength',
                    style: AppTextStyles.caption.copyWith(
                      color: reasonLen > _maxReasonLength
                          ? AppColors.error
                          : AppColors.textHint,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              TextFormField(
                controller: _reasonCtrl,
                maxLines: 4,
                maxLength: _maxReasonLength,
                buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
                    const SizedBox.shrink(),
                onChanged: (_) => setState(() {}),
                style: AppTextStyles.body,
                decoration: InputDecoration(
                  hintText: 'Briefly describe the reason...',
                  hintStyle:
                      AppTextStyles.body.copyWith(color: AppColors.textHint),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  contentPadding: const EdgeInsets.all(AppSpacing.md),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    borderSide:
                        const BorderSide(color: AppColors.border, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    borderSide:
                        const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              PrimaryButton(
                label: 'Submit Request',
                onPressed: _loading ? null : _submit,
                icon: Icons.send_rounded,
                isLoading: _loading,
                color: activeColor,
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  final String label;
  final DateTime? date;
  final DateFormat displayFmt;
  final VoidCallback onTap;

  const _DateTile({
    required this.label,
    this.date,
    required this.displayFmt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasDate = date != null;
    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Icon(Icons.calendar_today_rounded,
                    size: 14,
                    color: hasDate ? AppColors.secondary : AppColors.textHint),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    hasDate ? displayFmt.format(date!) : 'Select',
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: hasDate
                            ? AppColors.textPrimary
                            : AppColors.textHint),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
