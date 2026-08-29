import 'dart:convert';

import 'package:attend_ease/core/constants/app_colors.dart';
import 'package:attend_ease/core/constants/app_spacing.dart';
import 'package:attend_ease/core/constants/app_text_styles.dart';
import 'package:attend_ease/core/di/service_locator.dart';
import 'package:attend_ease/features/auth/widgets/otp_auth_widgets.dart';
import 'package:attend_ease/features/employee/services/employee_service.dart';
import 'package:attend_ease/shared/widgets/app_card.dart';
import 'package:attend_ease/shared/widgets/primary_button.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class _ParsedRow {
  final String employeeName;
  final String employeeNumber;
  final String employeePosition;

  const _ParsedRow({
    required this.employeeName,
    required this.employeeNumber,
    required this.employeePosition,
  });

  bool get isValid =>
      employeeName.isNotEmpty && employeeNumber.isNotEmpty && employeePosition.isNotEmpty;
}

class BulkImportScreen extends StatefulWidget {
  const BulkImportScreen({super.key});

  @override
  State<BulkImportScreen> createState() => _BulkImportScreenState();
}

class _BulkImportScreenState extends State<BulkImportScreen> {
  final EmployeeService _service = getIt<EmployeeService>();
  List<_ParsedRow> _rows = [];
  List<dynamic>? _results;
  String? _fileName;
  bool _importing = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) return;

    final content = utf8.decode(bytes);
    final table = Csv().decode(content);
    if (table.isEmpty) {
      if (mounted) toastMessageError(context, 'Empty file', 'That CSV has no rows.');
      return;
    }

    final header = table.first.map((h) => h.toString().trim().toLowerCase()).toList();
    final nameIdx = header.indexOf('employeename');
    final numberIdx = header.indexOf('employeenumber');
    final positionIdx = header.indexOf('employeeposition');
    if (nameIdx == -1 || numberIdx == -1 || positionIdx == -1) {
      if (mounted) {
        toastMessageError(context, 'Bad header',
            'CSV must have columns: employeeName, employeeNumber, employeePosition.');
      }
      return;
    }

    final parsed = table.skip(1).map((row) {
      String cell(int i) => i < row.length ? row[i].toString().trim() : '';
      return _ParsedRow(
        employeeName: cell(nameIdx),
        employeeNumber: cell(numberIdx),
        employeePosition: cell(positionIdx),
      );
    }).where((r) => r.employeeName.isNotEmpty || r.employeeNumber.isNotEmpty).toList();

    setState(() {
      _rows = parsed;
      _results = null;
      _fileName = file.name;
    });
  }

  Future<void> _import() async {
    final validRows = _rows.where((r) => r.isValid).toList();
    if (validRows.isEmpty) {
      toastMessageError(context, 'Nothing to import', 'No valid rows in this file.');
      return;
    }
    setState(() => _importing = true);
    final res = await _service.bulkAddEmployees(validRows
        .map((r) => {
              'employeeName': r.employeeName,
              'employeeNumber': r.employeeNumber,
              'employeePosition': r.employeePosition,
            })
        .toList());
    if (!mounted) return;
    setState(() => _importing = false);
    if (res.success && res.data != null) {
      setState(() => _results = res.data);
      final succeeded = res.data!.where((r) => r['success'] == true).length;
      toastMessageSuccess(context, 'Import done', '$succeeded of ${res.data!.length} added.');
    } else {
      toastMessageError(context, 'Error', res.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final invalidCount = _rows.where((r) => !r.isValid).length;

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          title: Text('Bulk Import', style: AppTextStyles.title),
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CSV columns required', style: AppTextStyles.bodyMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'employeeName, employeeNumber, employeePosition (header row required)',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              PrimaryButton(
                label: _fileName ?? 'Pick CSV File',
                icon: Icons.upload_file_rounded,
                onPressed: _pickFile,
                height: 46,
              ),
              if (_rows.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Preview', style: AppTextStyles.title),
                    Text(
                      invalidCount == 0
                          ? '${_rows.length} rows'
                          : '${_rows.length} rows · $invalidCount invalid',
                      style: AppTextStyles.caption.copyWith(
                        color: invalidCount == 0 ? AppColors.textSecondary : AppColors.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _rows.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.xs),
                  itemBuilder: (context, index) {
                    final row = _rows[index];
                    return AppCard(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      child: Row(
                        children: [
                          Icon(
                            row.isValid
                                ? Icons.check_circle_outline_rounded
                                : Icons.error_outline_rounded,
                            size: 18,
                            color: row.isValid ? AppColors.success : AppColors.error,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              '${row.employeeName.isEmpty ? '—' : row.employeeName}  ·  '
                              '${row.employeeNumber.isEmpty ? '—' : row.employeeNumber}  ·  '
                              '${row.employeePosition.isEmpty ? '—' : row.employeePosition}',
                              style: AppTextStyles.caption,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  label: 'Import',
                  icon: Icons.group_add_rounded,
                  isLoading: _importing,
                  onPressed: _importing ? null : _import,
                  height: 46,
                ),
              ],
              if (_results != null) ...[
                const SizedBox(height: AppSpacing.lg),
                Text('Results', style: AppTextStyles.title),
                const SizedBox(height: AppSpacing.sm),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _results!.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.xs),
                  itemBuilder: (context, index) {
                    final r = _results![index];
                    final ok = r['success'] == true;
                    return AppCard(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      child: Row(
                        children: [
                          Icon(
                            ok ? Icons.check_circle_rounded : Icons.cancel_rounded,
                            size: 18,
                            color: ok ? AppColors.success : AppColors.error,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              '${r['employeeName'] ?? '—'} — ${r['message'] ?? ''}',
                              style: AppTextStyles.caption.copyWith(
                                color: ok ? AppColors.textPrimary : AppColors.error,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}
