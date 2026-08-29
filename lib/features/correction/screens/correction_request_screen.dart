import 'package:attend_ease/core/constants/app_colors.dart';
import 'package:attend_ease/core/constants/app_spacing.dart';
import 'package:attend_ease/core/constants/app_text_styles.dart';
import 'package:attend_ease/features/auth/widgets/otp_auth_widgets.dart';
import 'package:attend_ease/features/correction/services/correction_service.dart';
import 'package:attend_ease/shared/widgets/app_card.dart';
import 'package:attend_ease/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CorrectionRequestScreen extends StatefulWidget {
  const CorrectionRequestScreen({super.key});

  @override
  State<CorrectionRequestScreen> createState() => _CorrectionRequestScreenState();
}

class _CorrectionRequestScreenState extends State<CorrectionRequestScreen> {
  final CorrectionService _service = CorrectionService();
  final _reasonCtrl = TextEditingController();
  DateTime? _date;
  TimeOfDay? _inTime;
  TimeOfDay? _outTime;
  bool _loading = false;

  static const _maxReasonLength = 200;
  final _dateFmt = DateFormat('dd/MM/yy');
  final _displayFmt = DateFormat('dd MMM yy');

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 90)),
      lastDate: now,
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
    setState(() => _date = picked);
  }

  Future<void> _pickTime({required bool isIn}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: (isIn ? _inTime : _outTime) ?? TimeOfDay.now(),
    );
    if (picked == null) return;
    setState(() => isIn ? _inTime = picked : _outTime = picked);
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _submit() async {
    if (_date == null) {
      toastMessageError(context, 'Missing date', 'Select the date you want to correct.');
      return;
    }
    if (_inTime == null && _outTime == null) {
      toastMessageError(context, 'Nothing to fix',
          'Set at least one of the in-time or out-time you actually worked.');
      return;
    }
    if (_reasonCtrl.text.trim().isEmpty) {
      toastMessageError(context, 'Missing reason', 'Please enter a reason.');
      return;
    }
    setState(() => _loading = true);
    final res = await _service.requestCorrection(
      _dateFmt.format(_date!),
      _inTime != null ? _formatTime(_inTime!) : null,
      _outTime != null ? _formatTime(_outTime!) : null,
      _reasonCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (res.success) {
      toastMessageSuccess(context, 'Success!', 'Correction request submitted.');
      Navigator.pop(context, true);
    } else {
      toastMessageError(context, 'Error!', res.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reasonLen = _reasonCtrl.text.length;

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          title: Text('Request Correction', style: AppTextStyles.title),
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Date to correct', style: AppTextStyles.bodyMedium),
              const SizedBox(height: AppSpacing.sm),
              GestureDetector(
                onTap: _pickDate,
                child: AppCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_rounded,
                          size: 16,
                          color: _date != null ? AppColors.secondary : AppColors.textHint),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        _date != null ? _displayFmt.format(_date!) : 'Select a date',
                        style: AppTextStyles.body.copyWith(
                          color: _date != null ? AppColors.textPrimary : AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              Text('What actually happened?', style: AppTextStyles.bodyMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Leave a time blank if it was already correct.',
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _TimeTile(
                      label: 'Actual In Time',
                      time: _inTime,
                      onTap: () => _pickTime(isIn: true),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _TimeTile(
                      label: 'Actual Out Time',
                      time: _outTime,
                      onTap: () => _pickTime(isIn: false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

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
                  hintText: 'e.g. Forgot to punch out before leaving',
                  hintStyle: AppTextStyles.body.copyWith(color: AppColors.textHint),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  contentPadding: const EdgeInsets.all(AppSpacing.md),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    borderSide: const BorderSide(color: AppColors.border, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              PrimaryButton(
                label: 'Submit Request',
                onPressed: _loading ? null : _submit,
                icon: Icons.send_rounded,
                isLoading: _loading,
                color: AppColors.secondary,
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeTile extends StatelessWidget {
  final String label;
  final TimeOfDay? time;
  final VoidCallback onTap;

  const _TimeTile({required this.label, this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasTime = time != null;
    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Icon(Icons.schedule_rounded,
                    size: 14, color: hasTime ? AppColors.secondary : AppColors.textHint),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    hasTime ? time!.format(context) : 'Not sure',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: hasTime ? AppColors.textPrimary : AppColors.textHint,
                    ),
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
