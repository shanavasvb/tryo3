import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tryo3_app/widgets/app_bottom_nav_bar.dart';
import 'package:tryo3_app/widgets/app_menu_button.dart';
import 'package:tryo3_app/widgets/history/environmental_score_card.dart';
import 'package:tryo3_app/widgets/history/filter_chip_row.dart';
import 'package:tryo3_app/widgets/history/history_chart.dart';
import 'package:tryo3_app/widgets/history/daily_summary_tile.dart';
import 'package:tryo3_app/widgets/history/date_range_picker_dialog.dart';
import 'package:tryo3_app/services/placeholder_data_service.dart';
import 'package:tryo3_app/themes/theme.dart';

/// History screen showing environmental data trends over time
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // State
  HistoryFilter _selectedFilter = HistoryFilter.thisWeek;
  DateTimeRange? _customDateRange;
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _dateRangeController = TextEditingController();

  // Data
  EnvironmentalScore _environmentalScore = const EnvironmentalScore(
    score: 0,
    changePercent: 0,
    isPositive: true,
  );
  List<ChartDataPoint> _chartData = [];
  List<String> _chartLabels = [];
  List<DailySummary> _dailySummaries = [];

  // Design constants
  static const double _horizontalPadding = 20.0;
  static const double _sectionSpacing = 28.0;
  static const double _itemSpacing = 16.0;
  static const double _chartHeight = 220.0;
  static const double _filterHeight = 50.0;

  @override
  void initState() {
    super.initState();
    _loadData();
    _updateDateRangeText();
  }

  @override
  void dispose() {
    _dateRangeController.dispose();
    super.dispose();
  }

  /// Load data based on current filter
  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      await Future.delayed(const Duration(milliseconds: 500));

      final score = PlaceholderDataService.getEnvironmentalScore(
        _selectedFilter,
        dateRange: _customDateRange,
      );
      final chartData = PlaceholderDataService.getHistoryChartData(
        _selectedFilter,
        dateRange: _customDateRange,
      );
      final labels = PlaceholderDataService.getChartLabels(
        _selectedFilter,
        dateRange: _customDateRange,
      );
      final summaries = PlaceholderDataService.getDailySummaries(
        filter: _selectedFilter,
        dateRange: _customDateRange,
      );

      if (mounted) {
        setState(() {
          _environmentalScore = score;
          _chartData = chartData;
          _chartLabels = labels;
          _dailySummaries = summaries;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load history data';
        });
      }
      debugPrint('Error loading history data: $e');
    }
  }

  /// Update date range text in controller
  void _updateDateRangeText() {
    if (_selectedFilter == HistoryFilter.custom && _customDateRange != null) {
      _dateRangeController.text = _formatDateRange(_customDateRange!);
    } else {
      _dateRangeController.text = _selectedFilter.label;
    }
  }

  /// Handle filter selection
  Future<void> _onFilterSelected(HistoryFilter filter) async {
    if (_selectedFilter == filter) return;

    if (filter == HistoryFilter.custom) {
      await _showDateRangePicker();
      return;
    }

    setState(() {
      _selectedFilter = filter;
      _customDateRange = null;
      _updateDateRangeText();
    });

    await _loadData();
  }

  /// Show date range picker
  Future<void> _showDateRangePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final lastDate = now;

    final initialRange =
        _customDateRange ??
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
      setState(() {
        _selectedFilter = HistoryFilter.custom;
        _customDateRange = result;
        _updateDateRangeText();
      });

      await _loadData();
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
    if (_isLoading && _chartData.isEmpty) {
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

    if (_errorMessage != null && _chartData.isEmpty) {
      return _buildErrorState(isDark);
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
            if (_isLoading)
              _buildLoadingIndicator(isDark)
            else if (_errorMessage != null)
              _buildInlineError(isDark)
            else ...[
              EnvironmentalScoreCard(
                score: _environmentalScore,
                isDarkMode: isDark,
              ),
              const SizedBox(height: _sectionSpacing),
              HistoryChart(
                chartData: _chartData,
                chartLabels: _chartLabels,
                isDarkMode: isDark,
                height: _chartHeight,
              ),
              const SizedBox(height: _sectionSpacing),
              _buildDailySummarySection(isDark),
            ],
            const SizedBox(height: _horizontalPadding),
          ],
        ),
      ),
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

  /// Build error state widget
  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to Load Data',
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppTheme.darkTextColor
                    : AppTheme.lightTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'An unknown error occurred',
              style: GoogleFonts.manrope(
                fontSize: 14,
                color: isDark
                    ? AppTheme.darkTextColor.withOpacity(0.6)
                    : AppTheme.lightTextColor.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: Text(
                'Retry',
                style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? AppTheme.darkbtnColor
                    : AppTheme.lightbtnColor,
                foregroundColor: AppTheme.darkTextColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build inline error widget
  Widget _buildInlineError(bool isDark) {
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
              _errorMessage!,
              style: GoogleFonts.manrope(fontSize: 13, color: Colors.red),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () => setState(() => _errorMessage = null),
            color: Colors.red,
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
            selectedFilter: _selectedFilter,
            onSelect: _onFilterSelected,
            isDarkMode: isDark,
          ),
        ],
      ),
    );
  }

  /// Build daily summary section
  Widget _buildDailySummarySection(bool isDark) {
    return Column(
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
              '${_dailySummaries.length} days',
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: _itemSpacing),
        if (_dailySummaries.isEmpty)
          _buildEmptySummaryState(isDark)
        else
          _buildSummaryList(),
      ],
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

  Widget _buildSummaryList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _dailySummaries.length,
      separatorBuilder: (_, __) => const SizedBox(height: _itemSpacing),
      itemBuilder: (context, index) => DailySummaryTile(
        summary: _dailySummaries[index],
        isFirst: index == 0,
        isLast: index == _dailySummaries.length - 1,
      ),
    );
  }

  Future<void> _handleRefresh() async {
    await _loadData();
  }
}
