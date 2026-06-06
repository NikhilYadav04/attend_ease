import 'package:attend_ease/core/constants/app_colors.dart';
import 'package:attend_ease/core/constants/app_spacing.dart';
import 'package:attend_ease/core/constants/app_text_styles.dart';
import 'package:attend_ease/core/storage/local_storage.dart';
import 'package:attend_ease/core/di/service_locator.dart';
import 'package:attend_ease/core/router/app_router.dart';
import 'package:attend_ease/features/attendance/services/location_service.dart';
import 'package:attend_ease/features/auth/widgets/otp_auth_widgets.dart';
import 'package:attend_ease/features/company/providers/company_provider.dart';
import 'package:attend_ease/shared/widgets/app_card.dart';
import 'package:attend_ease/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CompanyLocationScreen extends StatefulWidget {
  final String? companyName;
  final bool isEditing;
  const CompanyLocationScreen({
    super.key,
    required this.companyName,
    this.isEditing = false,
  });

  @override
  State<CompanyLocationScreen> createState() => _CompanyLocationScreenState();
}

class _CompanyLocationScreenState extends State<CompanyLocationScreen> {
  final LocationService _locationService = getIt<LocationService>();
  bool _settingLocation = false;
  bool _loadingCurrent = false;
  String _workStartTime = '09:00';
  String? _resolvedAddress;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadSavedLocation());
    }
  }

  Future<void> _loadSavedLocation() async {
    setState(() => _loadingCurrent = true);
    final res = await _locationService.getCompanyLocation();
    if (!mounted) return;
    setState(() => _loadingCurrent = false);
    if (res.success && res.data != null) {
      final d = res.data!;
      final lat = d['latitude'] as double;
      final lng = d['longitude'] as double;
      final radius = d['radius'] as double;
      final wst = d['workStartTime'] as String? ?? '';

      final provider = context.read<CompanyProvider>();
      provider.setCurrentLocation(lat.toString(), lng.toString());
      provider.setSlider(radius);
      if (wst.isNotEmpty) {
        provider.setWorkStartTime(wst);
        setState(() => _workStartTime = wst);
      }

      // Reverse geocode saved coords
      try {
        final placemarks = await placemarkFromCoordinates(lat, lng);
        if (placemarks.isNotEmpty && mounted) {
          final p = placemarks.first;
          final parts = [p.street, p.subLocality, p.locality, p.administrativeArea]
              .where((s) => s != null && s.isNotEmpty)
              .toList();
          setState(() => _resolvedAddress = parts.join(', '));
        }
      } catch (_) {}
    }
  }

  Future<void> _pickWorkStartTime() async {
    final parts = _workStartTime.split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 9,
      minute: int.tryParse(parts[1]) ?? 0,
    );
    final time = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (time == null) return;
    setState(() => _workStartTime =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}');
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      toastMessageError(context, 'Permission Denied',
          'Location permission is required.');
      await Geolocator.requestPermission();
      return;
    }

    setState(() => _settingLocation = true);

    Position pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.best));
    if (!mounted) return;

    final companyProvider = context.read<CompanyProvider>();
    companyProvider.setCurrentLocation(
      pos.latitude.toString(),
      pos.longitude.toString(),
    );

    // Reverse geocode
    try {
      final placemarks =
          await placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (placemarks.isNotEmpty && mounted) {
        final p = placemarks.first;
        final parts = [
          p.street,
          p.subLocality,
          p.locality,
          p.administrativeArea,
        ].where((s) => s != null && s.isNotEmpty).toList();
        setState(() => _resolvedAddress = parts.join(', '));
      }
    } catch (_) {}

    final res = await _locationService.setLocation(
        pos.latitude.toString(),
        pos.longitude.toString(),
        companyProvider.sliderValue,
        workStartTime: _workStartTime);

    if (!mounted) return;
    setState(() => _settingLocation = false);

    if (res.success) {
      companyProvider.setWorkStartTime(_workStartTime);
      toastMessageSuccess(context, 'Location Set', 'Office location saved.');
    } else {
      toastMessageError(context, 'Error!', res.message);
    }
  }

  void _continue() async {
    final companyProvider = context.read<CompanyProvider>();
    if (companyProvider.longitude == null || companyProvider.longitude == '') {
      toastMessageError(
          context, 'Not Set', 'Please set your office location first.');
      return;
    }
    if (widget.isEditing) {
      // Save radius + work start time with current stored coords
      final res = await _locationService.setLocation(
        companyProvider.latitude,
        companyProvider.longitude,
        companyProvider.sliderValue,
        workStartTime: _workStartTime,
      );
      if (!mounted) return;
      if (res.success) {
        companyProvider.setWorkStartTime(_workStartTime);
        toastMessageSuccess(context, 'Updated', 'Office settings saved.');
        context.pop();
      } else {
        toastMessageError(context, 'Error!', res.message);
      }
      return;
    }
    await HelperFunctions.setStatus(true);
    if (!mounted) return;
    context.go(AppRoutes.companyDashboard);
  }

  @override
  Widget build(BuildContext context) {
    final companyProvider = context.watch<CompanyProvider>();
    final hasLocation = companyProvider.longitude != null &&
        companyProvider.longitude != '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          widget.isEditing ? 'Edit Office Location' : 'Office Location',
          style: AppTextStyles.title,
        ),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.textSecondary),
          onPressed: () => context.pop(),
        ),
      ),
      body: _loadingCurrent
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map illustration
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: Image.asset(
                'assets/location_screen/map.png',
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            Text('Set your company office address',
                style: AppTextStyles.headline),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Employees must be within the radius you set to mark attendance.',
              style: AppTextStyles.body
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Location card
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Current Location', style: AppTextStyles.title),
                  const SizedBox(height: AppSpacing.md),
                  if (hasLocation) ...[
                    if (_resolvedAddress != null)
                      _AddressRow(address: _resolvedAddress!)
                    else ...[
                      _CoordRow(
                          label: 'Latitude',
                          value: companyProvider.latitude ?? '—'),
                      const SizedBox(height: AppSpacing.sm),
                      _CoordRow(
                          label: 'Longitude',
                          value: companyProvider.longitude ?? '—'),
                    ],
                    const SizedBox(height: AppSpacing.md),
                  ],
                  PrimaryButton(
                    label: _settingLocation
                        ? 'Detecting...'
                        : hasLocation
                            ? 'Update Location'
                            : 'Detect My Location',
                    onPressed: _settingLocation ? null : _getCurrentLocation,
                    color: AppColors.secondary,
                    icon: Icons.my_location_rounded,
                    isLoading: _settingLocation,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Radius card
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Attendance Radius', style: AppTextStyles.title),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius:
                              BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          '${companyProvider.sliderValue.toStringAsFixed(0)} m',
                          style: AppTextStyles.label
                              .copyWith(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Slider(
                    value: companyProvider.sliderValue,
                    label:
                        '${companyProvider.sliderValue.toStringAsFixed(0)} m',
                    min: 100,
                    max: 500,
                    divisions: 400,
                    activeColor: AppColors.secondary,
                    inactiveColor: AppColors.surfaceVariant,
                    onChanged: (val) =>
                        context.read<CompanyProvider>().setSlider(val),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('100 m', style: AppTextStyles.caption),
                      Text('500 m', style: AppTextStyles.caption),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Work start time card
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Work Start Time', style: AppTextStyles.title),
                        const SizedBox(height: 4),
                        Text(
                          'Late if punch-in is after this time',
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _pickWorkStartTime,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time_rounded,
                              size: 16, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(_workStartTime,
                              style: AppTextStyles.bodyMedium
                                  .copyWith(color: AppColors.primary)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            PrimaryButton(
              label: widget.isEditing ? 'Save Changes' : 'Continue to Dashboard',
              onPressed: _continue,
              icon: widget.isEditing ? Icons.save_rounded : Icons.arrow_forward_rounded,
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

class _CoordRow extends StatelessWidget {
  final String label;
  final String value;
  const _CoordRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('$label:  ',
            style:
                AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
        Text(value, style: AppTextStyles.bodyMedium),
      ],
    );
  }
}

class _AddressRow extends StatelessWidget {
  final String address;
  const _AddressRow({required this.address});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.place_rounded, size: 16, color: AppColors.secondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(address, style: AppTextStyles.bodyMedium),
        ),
      ],
    );
  }
}
