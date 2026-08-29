import 'package:attend_ease/core/constants/app_colors.dart';
import 'package:attend_ease/core/constants/app_spacing.dart';
import 'package:attend_ease/core/constants/app_text_styles.dart';
import 'package:attend_ease/features/company/services/company_service.dart';
import 'package:attend_ease/shared/widgets/app_card.dart';
import 'package:attend_ease/shared/widgets/skeleton_box.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CompanyAnalyticsScreen extends StatefulWidget {
  const CompanyAnalyticsScreen({super.key});

  @override
  State<CompanyAnalyticsScreen> createState() => _CompanyAnalyticsScreenState();
}

class _CompanyAnalyticsScreenState extends State<CompanyAnalyticsScreen> {
  final CompanyService _service = CompanyService();
  Map<String, dynamic>? _data;
  bool _loading = true;
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  bool get _isCurrentMonth {
    final now = DateTime.now();
    return _selectedMonth.year == now.year && _selectedMonth.month == now.month;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetch());
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    final res = await _service.getAnalytics(
        month: _selectedMonth.month, year: _selectedMonth.year);
    if (!mounted) return;
    if (res.success && res.data != null) {
      setState(() => _data = res.data);
    }
    setState(() => _loading = false);
  }

  void _prevMonth() {
    setState(() =>
        _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1));
    _fetch();
  }

  void _nextMonth() {
    final now = DateTime.now();
    final next = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    if (next.isAfter(DateTime(now.year, now.month))) return;
    setState(() => _selectedMonth = next);
    _fetch();
  }

  Future<void> _pickMonth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime(now.year, now.month, now.day),
      initialDatePickerMode: DatePickerMode.year,
      helpText: 'Select month',
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
    if (picked == null) return;
    setState(() => _selectedMonth = DateTime(picked.year, picked.month));
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          title: Text('Analytics', style: AppTextStyles.title),
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
        ),
        body: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _fetch,
          child: _loading
              ? const _AnalyticsSkeleton()
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: _buildContent(),
                ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final data = _data;
    if (data == null) {
      return AppCard(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Center(
          child: Text('Could not load analytics.',
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
        ),
      );
    }

    final trend = (data['trend'] as List<dynamic>? ?? []);
    final pendingLeaves = (data['pendingLeaves'] as num?)?.toInt() ?? 0;
    final approvedThisMonth = (data['approvedThisMonth'] as num?)?.toInt() ?? 0;
    final lateThisWeek = (data['lateThisWeek'] as num?)?.toInt() ?? 0;
    final hoursThisWeek = (data['hoursThisWeek'] as num?)?.toDouble() ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _StatTile(
                label: 'Pending Leaves',
                value: '$pendingLeaves',
                icon: Icons.event_note_rounded,
                color: const Color(0xFFD97706),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _StatTile(
                label: 'Late This Week',
                value: '$lateThisWeek',
                icon: Icons.schedule_rounded,
                color: AppColors.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                label: 'Approved This Month',
                value: '$approvedThisMonth',
                icon: Icons.check_circle_rounded,
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _StatTile(
                label: 'Hours This Week',
                value: hoursThisWeek.toStringAsFixed(0),
                icon: Icons.timer_rounded,
                color: const Color(0xFF7C3AED),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Attendance Rate Trend', style: AppTextStyles.title),
            Row(
              children: [
                IconButton(
                  onPressed: _prevMonth,
                  icon: const Icon(Icons.chevron_left_rounded, color: AppColors.primary),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                GestureDetector(
                  onTap: _pickMonth,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_month_rounded,
                          size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMMM yyyy').format(_selectedMonth),
                        style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.w600, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _isCurrentMonth ? null : _nextMonth,
                  icon: Icon(Icons.chevron_right_rounded,
                      color: _isCurrentMonth ? AppColors.textHint : AppColors.primary),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (trend.every((e) => ((e as Map)['total'] as num? ?? 0) == 0))
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.show_chart_rounded, size: 40, color: AppColors.textHint),
                  const SizedBox(height: AppSpacing.sm),
                  Text('No attendance data for this month.',
                      style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
          )
        else
          AppCard(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.sm, AppSpacing.lg, AppSpacing.md, AppSpacing.sm),
            child: SizedBox(
              height: 220,
              child: _TrendChart(trend: trend),
            ),
          ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: AppSpacing.xs),
          Text(value, style: AppTextStyles.title.copyWith(color: color)),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

class _TrendChart extends StatelessWidget {
  final List<dynamic> trend;

  const _TrendChart({required this.trend});

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[];
    for (var i = 0; i < trend.length; i++) {
      final entry = trend[i] as Map<String, dynamic>;
      final total = (entry['total'] as num?)?.toInt() ?? 0;
      final present = (entry['present'] as num?)?.toInt() ?? 0;
      final rate = total == 0 ? 0.0 : (present / total * 100);
      spots.add(FlSpot(i.toDouble(), rate));
    }

    // Cap the number of x-axis labels regardless of how many days are
    // plotted, so a full month doesn't crowd the axis with 30 labels.
    final labelInterval =
        (trend.length / 6).ceil().clamp(1, trend.length).toDouble();

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 100,
        gridData: FlGridData(
          show: true,
          horizontalInterval: 25,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: AppColors.border, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 25,
              reservedSize: 32,
              getTitlesWidget: (value, meta) => Text(
                '${value.toInt()}%',
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: labelInterval,
              reservedSize: 24,
              getTitlesWidget: (value, meta) {
                final i = value.round();
                if (i < 0 || i >= trend.length) return const SizedBox.shrink();
                final entry = trend[i] as Map<String, dynamic>;
                final date = entry['date'] as String? ?? '';
                final day = date.split('/').first;
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(day,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textSecondary, fontSize: 9)),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) => touchedSpots.map((s) {
              return LineTooltipItem(
                '${s.y.toStringAsFixed(0)}%',
                AppTextStyles.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
              );
            }).toList(),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primary,
            barWidth: 2.5,
            dotData: FlDotData(show: trend.length <= 15),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsSkeleton extends StatelessWidget {
  const _AnalyticsSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(
              2,
              (i) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i < 1 ? AppSpacing.sm : 0),
                  child: const SkeletonBox.wide(height: 80, borderRadius: 12),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: List.generate(
              2,
              (i) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i < 1 ? AppSpacing.sm : 0),
                  child: const SkeletonBox.wide(height: 80, borderRadius: 12),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const SkeletonBox.wide(height: 220, borderRadius: 12),
        ],
      ),
    );
  }
}
