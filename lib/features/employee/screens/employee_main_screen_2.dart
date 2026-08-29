import 'dart:async';
import 'package:attend_ease/core/constants/app_colors.dart';
import 'package:attend_ease/core/constants/app_spacing.dart';
import 'package:attend_ease/core/constants/app_text_styles.dart';
import 'package:attend_ease/core/storage/local_storage.dart';
import 'package:attend_ease/features/attendance/providers/attendance_provider.dart';
import 'package:attend_ease/core/di/service_locator.dart';
import 'package:attend_ease/core/router/app_router.dart';
import 'package:attend_ease/core/utils/attendance_time.dart';
import 'package:attend_ease/features/attendance/services/attendance_service.dart';
import 'package:attend_ease/features/attendance/services/location_service.dart';
import 'package:attend_ease/features/company/providers/company_provider.dart';
import 'package:attend_ease/features/auth/providers/auth_provider.dart';
import 'package:attend_ease/features/auth/widgets/otp_auth_widgets.dart';
import 'package:attend_ease/shared/widgets/app_card.dart';
import 'package:attend_ease/shared/widgets/primary_button.dart';
import 'package:attend_ease/shared/widgets/status_badge.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class EmployeeMainScreen2 extends StatefulWidget {
  const EmployeeMainScreen2({super.key});

  @override
  State<EmployeeMainScreen2> createState() => _EmployeeMainScreen2State();
}

class _EmployeeMainScreen2State extends State<EmployeeMainScreen2> {
  bool _locationVerified = false;
  bool _verifyingLocation = true;
  bool _locationNotConfigured = false;
  bool _isLate = false;
  String? _currentAddress;

  final AttendanceService _attendanceService = getIt<AttendanceService>();
  final LocationService _locationService = getIt<LocationService>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _verifyLocation());
  }

  Future<void> _verifyLocation() async {
    setState(() => _verifyingLocation = true);
    final companyProvider = context.read<CompanyProvider>();

    final result = await _locationService.getLocation();
    if (!mounted) return;

    if (!result.success) {
      final notConfigured = result.message == 'Location not set';
      setState(() {
        _locationNotConfigured = notConfigured;
        _locationVerified = false;
        _verifyingLocation = false;
      });
      if (!notConfigured) toastMessageError(context, 'Error!', result.message);
      return;
    }

    if (result.success && result.data != null) {
      companyProvider.setOfficeLocation(
        result.data!['latitude'] as double,
        result.data!['longitude'] as double,
        result.data!['radius'] as double,
      );
      companyProvider.setWorkStartTime(
          result.data!['workStartTime'] as String? ?? '');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() {
          _locationVerified = false;
          _verifyingLocation = false;
        });
        toastMessageError(context, 'Permission Required',
            'Location permission is needed to mark attendance.');
        return;
      }

      Position currentPosition;
      try {
        currentPosition = await Geolocator.getCurrentPosition(
            locationSettings:
                const LocationSettings(accuracy: LocationAccuracy.best));
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _locationVerified = false;
          _verifyingLocation = false;
        });
        toastMessageError(context, 'Location Error',
            'Could not get your location. Enable GPS and try again.');
        return;
      }
      if (!mounted) return;
      context.read<AttendanceProvider>().setCurrentPosition(
            currentPosition.latitude,
            currentPosition.longitude,
          );

      // Reverse geocode current position
      try {
        final placemarks = await placemarkFromCoordinates(
            currentPosition.latitude, currentPosition.longitude);
        if (placemarks.isNotEmpty && mounted) {
          final p = placemarks.first;
          final parts = [p.subLocality, p.locality, p.administrativeArea]
              .where((s) => s != null && s.isNotEmpty)
              .toList();
          setState(() => _currentAddress = parts.join(', '));
        }
      } catch (_) {}

      final lat2 = context.read<AttendanceProvider>().lat2;
      final lng2 = context.read<AttendanceProvider>().lng2;
      final lat1 = companyProvider.lat1;
      final radius = companyProvider.radius;

      final lng1 = companyProvider.lng1;
      double distance =
          Geolocator.distanceBetween(lat1, lng1, lat2, lng2);

      if (distance > radius) {
        toastMessageError(context, 'Location Error',
            'You must be within office radius to mark attendance.');
        setState(() {
          _locationVerified = false;
          _verifyingLocation = false;
        });
      } else {
        setState(() {
          _locationVerified = true;
          _verifyingLocation = false;
        });
      }
    }
  }

  void _checkIfLate(bool isLate) {
    if (!isLate) return;
    setState(() => _isLate = true);
    final workStart = context.read<CompanyProvider>().workStartTime;
    toastMessageError(context, 'Late Arrival',
        workStart.isEmpty ? 'Punched in after work start time.' : 'Punched in after $workStart.');
  }

  Future<void> _showPunchConfirmSheet({required bool isPunchIn}) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => _PunchConfirmSheet(
        isPunchIn: isPunchIn,
        locationVerified: _locationVerified,
        address: _currentAddress,
      ),
    );
    if (confirmed != true || !mounted) return;
    if (isPunchIn) {
      await _punchIn();
    } else {
      await _punchOut();
    }
  }

  Future<Position?> _freshPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
          locationSettings:
              const LocationSettings(accuracy: LocationAccuracy.best));
    } catch (_) {
      if (mounted) {
        toastMessageError(context, 'Location Error',
            'Could not get your location. Enable GPS and try again.');
      }
      return null;
    }
  }

  Future<void> _punchIn() async {
    final attendanceProvider = context.read<AttendanceProvider>();
    final position = await _freshPosition();
    if (position == null || !mounted) return;
    attendanceProvider.setCurrentPosition(
        position.latitude, position.longitude);

    final result =
        await _attendanceService.markIn(position.latitude, position.longitude);
    if (!mounted) return;

    if (!result.success || result.data == null) {
      toastMessageError(context, 'Error!', result.message);
      return;
    }

    final inTime = result.data!['inTime'] as String;
    attendanceProvider.setInTime(inTime);
    await HelperFunctions.setInTime(inTime);
    if (!mounted) return;
    toastMessageSuccess(context, 'Punched In', inTime);
    _checkIfLate(result.data!['isLate'] as bool? ?? false);
  }

  Future<void> _punchOut() async {
    final authProvider = context.read<AuthProvider>();
    final attendanceProvider = context.read<AttendanceProvider>();

    if (!authProvider.isAuthenticated) {
      toastMessageError(
          context, 'Auth Required', 'Please complete biometric verification.');
      return;
    }

    final inTime = attendanceProvider.inTime;
    if (inTime.isEmpty || inTime == '00:00') {
      toastMessageError(context, 'No Punch In', 'You must punch in first.');
      return;
    }

    final position = await _freshPosition();
    if (position == null || !mounted) return;
    attendanceProvider.setCurrentPosition(
        position.latitude, position.longitude);

    final result =
        await _attendanceService.markOut(position.latitude, position.longitude);
    if (!mounted) return;

    if (!result.success || result.data == null) {
      toastMessageError(context, 'Error!', result.message);
      return;
    }

    final outTime = result.data!['outTime'] as String;
    final date = DateFormat('dd/MM/yy').format(DateTime.now());

    attendanceProvider.setOutTime(outTime);
    attendanceProvider.setDate(date);
    attendanceProvider.setPresent(true);
    attendanceProvider.setTotalDays(result.data!['totalDays'] as int);

    final inTimeDisplay = await HelperFunctions.getInTime() ?? inTime;
    attendanceProvider.setInTimeDisplay(inTimeDisplay);
    authProvider.setAuthenticated(false);

    if (!mounted) return;
    toastMessageSuccess(context, 'Punched Out', 'Attendance marked');
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = context.watch<AuthProvider>().isAuthenticated;
    final isPresent = context.watch<AttendanceProvider>().isPresent;
    final ap = context.watch<AttendanceProvider>();
    final hasPunchedIn = ap.inTime.isNotEmpty && ap.inTime != '00:00';
    final hoursWorked =
        AttendanceTime.calcHoursWorked(ap.inTimeDisplay, ap.outTime);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            // ── Location status banner ─────────────────────────
            _LocationBanner(
              verifying: _verifyingLocation,
              verified: _locationVerified,
              notConfigured: _locationNotConfigured,
              address: _currentAddress,
              onRetry: _verifyLocation,
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Biometric card ────────────────────────────────
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Biometric Auth', style: AppTextStyles.title),
                      StatusBadge(
                        label: isAuthenticated ? 'Verified' : 'Pending',
                        status: isAuthenticated
                            ? BadgeStatus.success
                            : BadgeStatus.warning,
                        icon: isAuthenticated
                            ? Icons.check_circle_rounded
                            : Icons.warning_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Image.asset(
                    'assets/home_screen/biom.png',
                    height: 100,
                    width: 100,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    isAuthenticated
                        ? 'Identity confirmed. You may now punch out.'
                        : 'Authenticate to enable punch out.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (!isAuthenticated)
                    PrimaryButton(
                      label: 'Verify Biometric',
                      icon: Icons.fingerprint_rounded,
                      color: AppColors.secondary,
                      height: 44,
                      onPressed: () => context.push(AppRoutes.employeeBiometric),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Punch card ────────────────────────────────────
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Today\'s Attendance', style: AppTextStyles.title),
                      StatusBadge(
                        label: isPresent ? 'Present' : 'Not Marked',
                        status: isPresent
                            ? BadgeStatus.success
                            : BadgeStatus.neutral,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      _TimeBox(
                          label: 'IN', value: ap.inTimeDisplay),
                      const SizedBox(width: AppSpacing.sm),
                      const Icon(Icons.arrow_forward_rounded,
                          color: AppColors.textHint, size: 16),
                      const SizedBox(width: AppSpacing.sm),
                      _TimeBox(label: 'OUT', value: ap.outTime),
                    ],
                  ),
                  if (_isLate) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3CD),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.schedule_rounded,
                              color: AppColors.warning, size: 16),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'Late arrival — after work start time.',
                              style: AppTextStyles.caption
                                  .copyWith(color: AppColors.warning),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  if (isPresent)
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.check_circle_rounded,
                                  color: AppColors.success, size: 18),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  'Attendance complete. See you tomorrow!',
                                  style: AppTextStyles.body
                                      .copyWith(color: AppColors.success),
                                ),
                              ),
                            ],
                          ),
                          if (hoursWorked != null) ...[
                            const SizedBox(height: AppSpacing.xs),
                            Padding(
                              padding: const EdgeInsets.only(left: 26),
                              child: Text(
                                'You worked $hoursWorked today',
                                style: AppTextStyles.caption.copyWith(
                                    color: AppColors.success.withValues(
                                        alpha: 0.85)),
                              ),
                            ),
                          ],
                        ],
                      ),
                    )
                  else if (!_locationVerified)
                    const SizedBox.shrink()
                  else
                    Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            label: 'Punch In',
                            icon: Icons.login_rounded,
                            color: hasPunchedIn
                                ? AppColors.textHint
                                : AppColors.secondary,
                            height: 48,
                            onPressed: hasPunchedIn
                                ? null
                                : () => _showPunchConfirmSheet(isPunchIn: true),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: PrimaryButton(
                            label: 'Punch Out',
                            icon: Icons.logout_rounded,
                            color: AppColors.primary,
                            height: 48,
                            onPressed: (isAuthenticated && hasPunchedIn)
                                ? () => _showPunchConfirmSheet(isPunchIn: false)
                                : null,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

// ── Punch confirmation bottom sheet ─────────────────────────────────────────

class _PunchConfirmSheet extends StatefulWidget {
  final bool isPunchIn;
  final bool locationVerified;
  final String? address;

  const _PunchConfirmSheet({
    required this.isPunchIn,
    required this.locationVerified,
    this.address,
  });

  @override
  State<_PunchConfirmSheet> createState() => _PunchConfirmSheetState();
}

class _PunchConfirmSheetState extends State<_PunchConfirmSheet> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPunchIn = widget.isPunchIn;
    final color = isPunchIn ? AppColors.secondary : AppColors.primary;
    final timeStr = DateFormat('HH:mm:ss').format(_now);
    final dateStr = DateFormat('EEEE, dd MMM yyyy').format(_now);

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPunchIn ? Icons.login_rounded : Icons.logout_rounded,
              color: color,
              size: 30,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Title
          Text(
            isPunchIn ? 'Confirm Punch In' : 'Confirm Punch Out',
            style: AppTextStyles.headline,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            dateStr,
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Live clock
          Text(
            timeStr,
            style: AppTextStyles.stat.copyWith(
              color: color,
              fontSize: 40,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Location status row
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: widget.locationVerified
                  ? const Color(0xFFDCFCE7)
                  : const Color(0xFFFFE4E6),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.locationVerified
                          ? Icons.location_on_rounded
                          : Icons.location_off_rounded,
                      size: 14,
                      color: widget.locationVerified
                          ? AppColors.success
                          : AppColors.error,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      widget.locationVerified
                          ? 'Within office radius'
                          : 'Outside office radius',
                      style: AppTextStyles.caption.copyWith(
                        color: widget.locationVerified
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                  ],
                ),
                if (widget.address != null) ...[
                  const SizedBox(height: 2),
                  Padding(
                    padding: const EdgeInsets.only(left: 18),
                    child: Text(
                      widget.address!,
                      style: AppTextStyles.caption.copyWith(
                        color: (widget.locationVerified
                                ? AppColors.success
                                : AppColors.error)
                            .withValues(alpha: 0.75),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text('Cancel', style: AppTextStyles.bodyMedium),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    isPunchIn ? 'Punch In' : 'Punch Out',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _LocationBanner extends StatelessWidget {
  final bool verifying;
  final bool verified;
  final bool notConfigured;
  final String? address;
  final VoidCallback onRetry;

  const _LocationBanner({
    required this.verifying,
    required this.verified,
    required this.notConfigured,
    required this.onRetry,
    this.address,
  });

  @override
  Widget build(BuildContext context) {
    if (verifying) {
      return Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Row(
          children: [
            const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.primary)),
            const SizedBox(width: AppSpacing.sm),
            Text('Verifying your location...',
                style: AppTextStyles.caption),
          ],
        ),
      );
    }

    final Color bgColor = verified
        ? const Color(0xFFDCFCE7)
        : notConfigured
            ? const Color(0xFFFFF3CD)
            : const Color(0xFFFFE4E6);
    final Color fgColor = verified
        ? AppColors.success
        : notConfigured
            ? const Color(0xFFD97706)
            : AppColors.error;
    final IconData icon = verified
        ? Icons.location_on_rounded
        : notConfigured
            ? Icons.info_outline_rounded
            : Icons.location_off_rounded;
    final String label = verified
        ? 'Location verified — within office radius.'
        : notConfigured
            ? 'Office location not configured. Contact your HR.'
            : 'Outside office radius. Move closer to mark attendance.';

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          Icon(icon, color: fgColor, size: 16),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(color: fgColor),
                ),
                if (address != null && !notConfigured) ...[
                  const SizedBox(height: 2),
                  Text(
                    address!,
                    style: AppTextStyles.caption.copyWith(
                      color: fgColor.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!verified && !notConfigured)
            GestureDetector(
              onTap: onRetry,
              child: Text('Retry',
                  style: AppTextStyles.label.copyWith(color: fgColor)),
            ),
        ],
      ),
    );
  }
}

class _TimeBox extends StatelessWidget {
  final String label;
  final String value;

  const _TimeBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.sm, horizontal: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.caption),
            Text(value, style: AppTextStyles.title),
          ],
        ),
      ),
    );
  }
}
