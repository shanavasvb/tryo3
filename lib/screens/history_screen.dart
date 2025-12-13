import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tryo3_app/providers/history_providers.dart';
import 'package:tryo3_app/services/placeholder_data_service.dart';
import 'package:tryo3_app/widgets/app_bottom_nav_bar.dart';
import 'package:tryo3_app/widgets/app_menu_button.dart';
import 'package:tryo3_app/widgets/history/environmental_score_card.dart';
import 'package:tryo3_app/widgets/history/filter_chip_row.dart';
import 'package:tryo3_app/widgets/history/history_chart.dart';
import 'package:tryo3_app/widgets/history/daily_summary_tile.dart';
import 'package:tryo3_app/widgets/history/date_range_picker_dialog.dart';
import 'package:tryo3_app/themes/theme.dart';

/// History screen showing environmental data trends over time
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  // UI state only
  final TextEditingController _dateRangeController = TextEditingController();

  // Design constants
  static const double _horizontalPadding = 20.0;
  static const double _sectionSpacing = 28.0;
  static const double _itemSpacing = 16.0;
  static const double _chartHeight = 220.0;
  static const double _filterHeight = 50.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateDateRangeText();
    });
  }

  @override
  void dispose() {
    _dateRangeController.dispose();
    super.dispose();
  }



  /// Update date range text in controller
  void _updateDateRangeText() {
    final selectedFilter = ref.read(selectedFilterProvider);
    final customDateRange = ref.read(customDateRangeProvider);
    
    if (selectedFilter == HistoryFilter.custom && customDateRange != null) {
      _dateRangeController.text = _formatDateRange(customDateRange);
    } else {
      _dateRangeController.text = selectedFilter.label;
    }
  }

  /// Handle filter selection
  void _onFilterSelected(HistoryFilter filter) {
    final currentFilter = ref.read(selectedFilterProvider);
    if (currentFilter == filter) return;

    if (filter == HistoryFilter.custom) {
      _showDateRangePicker();
      return;
    }

    ref.read(selectedFilterProvider.notifier).selectFilter(filter);
    ref.read(customDateRangeProvider.notifier).setDateRange(null);
    _updateDateRangeText();
  }

  /// Show date range picker
  Future<void> _showDateRangePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final lastDate = now;
    
    final customDateRange = ref.read(customDateRangeProvider);
    final initialRange =
        customDateRange ??
        DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now);

    final result = await showDialog<DateTimeRange?>(
      context: context,
      builder: (context) => CustomDateRangePickerDialog(
        initialRange: initialRange,
        firstDate: firstDate,
        lastDate: lastDate,
      ),
    );

    if (result != null && mounted) {
      ref.read(selectedFilterProvider.notifier).selectFilter(HistoryFilter.custom);
      ref.read(customDateRangeProvider.notifier).setDateRange(result);
      _updateDateRangeText();
    }
  }

  /// Format date range for display
  String _formatDateRange(DateTimeRange range) {
    try {
      final startDay = range.start.day;
      final startMonth = _getMonthAbbreviation(range.start.month);
      final endDay = range.end.day;
      final endMonth = _getMonthAbbreviation(range.end.month);

      if (range.start.year != range.end.year) {
        final startYear = range.start.year % 100;
        final endYear = range.end.year % 100;
        return '$startDay $startMonth \'$startYear - $endDay $endMonth \'$endYear';
      }

      if (range.start.month == range.end.month) {
        return '$startDay - $endDay $endMonth';
      }

      return '$startDay $startMonth - $endDay $endMonth';
    } catch (e) {
      debugPrint('Error formatting date range: $e');
      return 'Custom Range';
    }
  }

  /// Get month abbreviation
  String _getMonthAbbreviation(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: _buildAppBar(isDark),
      body: _buildBody(isDark),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 1),
    );
  }

  /// Build the main body
  Widget _buildBody(bool isDark) {
    final scoreAsync = ref.watch(environmentalScoreProvider);
    final chartDataAsync = ref.watch(historyChartDataProvider);
    final chartLabelsAsync = ref.watch(historyChartLabelsProvider);
    final summariesAsync = ref.watch(dailySummariesProvider);

    // Check if initial load
    final isInitialLoading = scoreAsync.isLoading && 
                             chartDataAsync.isLoading && 
                             summariesAsync.isLoading;

    if (isInitialLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 2,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading historical data...',
              style: GoogleFonts.manrope(
                color: isDark
                    ? AppTheme.darkTextColor.withOpacity(0.6)
                    : AppTheme.lightTextColor.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppTheme.primaryColor,
      backgroundColor: isDark
          ? AppTheme.darkBackground
          : AppTheme.lightBackground,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(_horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilterSection(isDark),
            const SizedBox(height: _sectionSpacing),
            _buildScoreSection(isDark, scoreAsync),
            const SizedBox(height: _sectionSpacing),
            _buildChartSection(isDark, chartDataAsync, chartLabelsAsync),
            const SizedBox(height: _sectionSpacing),
            _buildDailySummarySection(isDark, summariesAsync),
            const SizedBox(height: _horizontalPadding),
          ],
        ),
      ),
    );
  }

  /// Build environmental score section
  Widget _buildScoreSection(bool isDark, AsyncValue<EnvironmentalScore> scoreAsync) {
    return scoreAsync.when(
      data: (score) => EnvironmentalScoreCard(
        score: score,
        isDarkMode: isDark,
      ),
      loading: () => _buildLoadingIndicator(isDark),
      error: (error, stack) => _buildInlineError(isDark, error.toString()),
    );
  }

  /// Build chart section
  Widget _buildChartSection(
    bool isDark,
    AsyncValue<List<ChartDataPoint>> chartDataAsync,
    AsyncValue<List<String>> chartLabelsAsync,
  ) {
    return chartDataAsync.when(
      data: (chartData) => chartLabelsAsync.when(
        data: (chartLabels) => HistoryChart(
          chartData: chartData,
          chartLabels: chartLabels,
          isDarkMode: isDark,
          height: _chartHeight,
        ),
        loading: () => _buildLoadingIndicator(isDark),
        error: (error, stack) => _buildInlineError(isDark, error.toString()),
      ),
      loading: () => _buildLoadingIndicator(isDark),
      error: (error, stack) => _buildInlineError(isDark, error.toString()),
    );
  }

  /// Build loading indicator
  Widget _buildLoadingIndicator(bool isDark) {
    return Container(
      height: 200,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 2,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Updating data...',
            style: GoogleFonts.manrope(
              color: isDark
                  ? AppTheme.darkTextColor.withOpacity(0.6)
                  : AppTheme.lightTextColor.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// Build inline error widget
  Widget _buildInlineError(bool isDark, String errorMessage) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              errorMessage,
              style: GoogleFonts.manrope(fontSize: 13, color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  /// Build app bar
  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      leading: const AppMenuButton(),
      title: Text(
        'History',
        style: GoogleFonts.manrope(
          fontWeight: FontWeight.w700,
          color: isDark ? AppTheme.darkTextColor : AppTheme.lightTextColor,
        ),
      ),
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 2,
      backgroundColor: isDark
          ? AppTheme.darkBackground
          : AppTheme.lightBackground,
    );
  }

  /// Build filter section
  Widget _buildFilterSection(bool isDark) {
    return Container(
      height: _filterHeight,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _showDateRangePicker,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _dateRangeController.text.isEmpty
                            ? 'Select date range'
                            : _dateRangeController.text,
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppTheme.darkTextColor
                              : AppTheme.lightTextColor,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_drop_down, color: AppTheme.primaryColor),
                  ],
                ),
              ),
            ),
          ),
          FilterChipRow(
            selectedFilter: ref.watch(selectedFilterProvider),
            onSelect: _onFilterSelected,
            isDarkMode: isDark,
          ),
        ],
      ),
    );
  }

  /// Build daily summary section
  Widget _buildDailySummarySection(bool isDark, AsyncValue<List<DailySummary>> summariesAsync) {
    return summariesAsync.when(
      data: (summaries) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily Summary',
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppTheme.darkTextColor
                      : AppTheme.lightTextColor,
                ),
              ),
              Text(
                '${summaries.length} days',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: _itemSpacing),
          if (summaries.isEmpty)
            _buildEmptySummaryState(isDark)
          else
            _buildSummaryList(summaries),
        ],
      ),
      loading: () => _buildLoadingIndicator(isDark),
      error: (error, stack) => _buildInlineError(isDark, error.toString()),
    );
  }

  Widget _buildEmptySummaryState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppTheme.darkTextColor.withOpacity(0.2)
              : AppTheme.lightTextColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.insert_chart_outlined,
            size: 48,
            color: isDark
                ? AppTheme.darkTextColor.withOpacity(0.4)
                : AppTheme.lightTextColor.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No summaries available',
            style: GoogleFonts.manrope(
              color: isDark
                  ? AppTheme.darkTextColor.withOpacity(0.6)
                  : AppTheme.lightTextColor.withOpacity(0.6),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select a different date range',
            style: GoogleFonts.manrope(
              color: isDark
                  ? AppTheme.darkTextColor.withOpacity(0.5)
                  : AppTheme.lightTextColor.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryList(List<DailySummary> summaries) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: summaries.length,
      separatorBuilder: (_, __) => const SizedBox(height: _itemSpacing),
      itemBuilder: (context, index) => DailySummaryTile(
        summary: summaries[index],
        isFirst: index == 0,
        isLast: index == summaries.length - 1,
      ),
    );
  }

  Future<void> _handleRefresh() async {
    ref.invalidate(environmentalScoreProvider);
    ref.invalidate(historyChartDataProvider);
    ref.invalidate(historyChartLabelsProvider);
    ref.invalidate(dailySummariesProvider);
  }
}
