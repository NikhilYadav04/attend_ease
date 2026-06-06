import 'package:attend_ease/core/constants/app_colors.dart';
import 'package:attend_ease/core/constants/app_spacing.dart';
import 'package:attend_ease/core/constants/app_text_styles.dart';
import 'package:attend_ease/core/di/service_locator.dart';
import 'package:attend_ease/features/employee/services/employee_service.dart';
import 'package:attend_ease/features/auth/widgets/otp_auth_widgets.dart';
import 'package:attend_ease/shared/widgets/app_text_field.dart';
import 'package:attend_ease/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class AddStaffScreen extends StatefulWidget {
  const AddStaffScreen({super.key});

  @override
  State<AddStaffScreen> createState() => _AddStaffScreenState();
}

class _AddStaffScreenState extends State<AddStaffScreen> {
  final EmployeeService _service = getIt<EmployeeService>();
  bool _loading = false;

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _positionCtrl = TextEditingController();
  final TextEditingController _numberCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _positionCtrl.dispose();
    _numberCtrl.dispose();
    super.dispose();
  }

  Future<void> _addEmployee() async {
    final name = _nameCtrl.text.trim();
    final position = _positionCtrl.text.trim();
    final number = _numberCtrl.text.trim();

    if (name.isEmpty || position.isEmpty || number.isEmpty) {
      toastMessageError(context, 'Missing fields', 'Please fill all fields.');
      return;
    }

    setState(() => _loading = true);
    final res = await _service.addEmployee(name, number, position);
    if (!mounted) return;
    setState(() => _loading = false);

    if (res.success) {
      toastMessageSuccess(context, 'Added!',
          'Employee added. ID shared via notification.');
      _nameCtrl.clear();
      _positionCtrl.clear();
      _numberCtrl.clear();
    } else {
      toastMessageError(context, 'Error!', res.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text('Add Staff', style: AppTextStyles.title),
      ),
      body: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info banner
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryLight,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            color: AppColors.secondary, size: 20),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'The employee will receive a unique ID to join your company.',
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.secondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  AppTextField(
                    controller: _nameCtrl,
                    label: 'Full Name',
                    hint: 'Nikhil Yadav',
                    prefixIcon: Icons.person_rounded,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  AppTextField(
                    controller: _positionCtrl,
                    label: 'Position / Role',
                    hint: 'Software Engineer',
                    prefixIcon: Icons.work_rounded,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  AppTextField(
                    controller: _numberCtrl,
                    label: 'Phone Number',
                    hint: '+91 98765 43210',
                    prefixIcon: Icons.phone_rounded,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  PrimaryButton(
                    label: 'Add Employee',
                    onPressed: _loading ? null : _addEmployee,
                    isLoading: _loading,
                    color: AppColors.secondary,
                    icon: Icons.person_add_rounded,
                  ),
                ],
              ),
            ),
    );
  }
}
