import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/placeholder_data_service.dart';

// HISTORY SCREEN
// ============================================

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // State
  HistoryFilter _selectedFilter = HistoryFilter.thisWeek;
  late EnvironmentalScore _environmentalScore;
  late List<ChartDataPoint> _chartData;
  late List<DailySummary> _dailySummaries;

  // Navigation
  int _selectedNavIndex = 1;

  // Design constants
  static const double _horizontalPadding = 16.0;
  static const double _sectionSpacing = 24.0;
  static const double _itemSpacing = 12.0;
  static const double _chartHeight = 200.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Load data based on current filter
  void _loadData() {
    _environmentalScore = PlaceholderDataService. getEnvironmentalScore(_selectedFilter);
    _chartData = PlaceholderDataService.getHistoryChartData(_selectedFilter);
    _dailySummaries = PlaceholderDataService.getDailySummaries();
  }

  /// Handle filter selection
  void _onFilterSelected(HistoryFilter filter) {
    if (_selectedFilter == filter) return;

    setState(() {
      _selectedFilter = filter;
      _loadData();
    });
  }

  /// Handle navigation tap
  void _onNavItemTapped(int index) {
    if (index == _selectedNavIndex) return;

    setState(() {
      _selectedNavIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pop(context);
        break;
      case 1:
        // Current screen
        break;
      case 2:
        // TODO: Navigate to Settings
        debugPrint('Settings selected');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh:  _handleRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(_horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFilterSection(),
              const SizedBox(height: _sectionSpacing),
              _buildEnvironmentalScoreSection(),
              const SizedBox(height:  _sectionSpacing),
              _buildChartSection(),
              const SizedBox(height: _sectionSpacing),
              _buildDailySummarySection(),
              const SizedBox(height: _horizontalPadding),
            ],
          ),
        ),
      ),
      bottomNavigationBar:  _buildBottomNavigation(),
    );
  }

  /// Build app bar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () {
          debugPrint('Menu tapped');
        },
        tooltip: 'Menu',
      ),
      title: Text(
        'History',
        style:  GoogleFonts. manrope(fontWeight: FontWeight.w600),
      ),
      centerTitle: true,
      elevation: 0,
    );
  }

  /// Build filter buttons section
  Widget _buildFilterSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: HistoryFilter.values. map((filter) {
        return _FilterButton(
          label: filter.label,
          isSelected: _selectedFilter == filter,
          onTap: () => _onFilterSelected(filter),
        );
      }).toList(),
    );
  }

  /// Build environmental score section
  Widget _buildEnvironmentalScoreSection() {
    final theme = Theme.of(context);
    final changeColor = _environmentalScore.isPositive
        ?  Colors.greenAccent
        : Colors.redAccent;
    final changePrefix = _environmentalScore.isPositive ?  '+' : '-';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Environmental Score',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color:  theme.textTheme.bodyLarge?. color,
          ),
        ),
        const SizedBox(height:  _itemSpacing),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children:  [
            Text(
              _environmentalScore.score.toStringAsFixed(1),
              style: GoogleFonts.manrope(
                fontSize:  32,
                fontWeight: FontWeight.w700,
                color:  theme.textTheme.bodyLarge?. color,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$changePrefix${_environmentalScore. changePercent}%',
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color:  changeColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build chart section
  Widget _buildChartSection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final lineColor = isDark ?  Colors.greenAccent : Colors. blueAccent;

    return Container(
      height: _chartHeight,
      padding: const EdgeInsets.all(_itemSpacing),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme. dividerColor.withOpacity(0.3),
        ),
      ),
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: 6,
          minY: 0,
          maxY: 100,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: _buildChartTitles(isDark),
          lineBarsData: [
            _buildLineChartBarData(lineColor),
          ],
          lineTouchData: _buildLineTouchData(lineColor),
        ),
      ),
    );
  }

  /// Build chart titles configuration
  FlTitlesData _buildChartTitles(bool isDark) {
    return FlTitlesData(
      leftTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      topTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      rightTitles: const AxisTitles(
        sideTitles:  SideTitles(showTitles: false),
      ),
      bottomTitles:  AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 28,
          getTitlesWidget: (value, meta) {
            final index = value. toInt();
            if (index >= 0 && index < PlaceholderDataService.weekDayLabels. length) {
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child:  Text(
                  PlaceholderDataService.weekDayLabels[index],
                  style:  GoogleFonts. manrope(
                    color: isDark ? Colors.white54 : Colors.black54,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }
            return const SizedBox. shrink();
          },
        ),
      ),
    );
  }

  /// Build line chart bar data
  LineChartBarData _buildLineChartBarData(Color lineColor) {
    return LineChartBarData(
      isCurved: true,
      curveSmoothness: 0.3,
      color: lineColor,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 4,
            color:  lineColor,
            strokeWidth: 2,
            strokeColor: Colors.white,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        color: lineColor. withOpacity(0.15),
      ),
      spots: _chartData.map((point) => FlSpot(point.x, point. y)).toList(),
    );
  }

  /// Build line touch data for interactivity
  LineTouchData _buildLineTouchData(Color lineColor) {
    return LineTouchData(
      enabled: true,
      touchTooltipData: LineTouchTooltipData(
        getTooltipItems: (touchedSpots) {
          return touchedSpots.map((spot) {
            return LineTooltipItem(
              spot. y. toStringAsFixed(1),
              GoogleFonts.manrope(
                color: Colors.white,
                fontWeight: FontWeight. w600,
              ),
            );
          }).toList();
        },
      ),
    );
  }

  /// Build daily summary section
  Widget _buildDailySummarySection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily Summary',
          style: GoogleFonts.manrope(
            fontSize:  18,
            fontWeight: FontWeight.w700,
            color: theme. textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height:  _itemSpacing),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _dailySummaries.length,
          separatorBuilder: (_, __) => const SizedBox(height: _itemSpacing),
          itemBuilder: (context, index) {
            return _DailySummaryTile(summary: _dailySummaries[index]);
          },
        ),
      ],
    );
  }

  /// Build bottom navigation bar
  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: _selectedNavIndex,
      onTap: _onNavItemTapped,
      selectedLabelStyle: GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle:  GoogleFonts. manrope(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      type: BottomNavigationBarType.fixed,
      items:  const [
        BottomNavigationBarItem(
          icon:  Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history_outlined),
          activeIcon: Icon(Icons.history),
          label: 'History',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          activeIcon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }

  /// Handle pull-to-refresh
  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _loadData();
    });
  }
}

// ============================================
// EXTRACTED WIDGETS
// ============================================

/// Filter button widget
class _FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterButton({
    required this.label,
    required this. isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.teal.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.tealAccent
                : theme.dividerColor.withOpacity(0.4),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style:  GoogleFonts. manrope(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color:  isSelected
                ? Colors.tealAccent
                : theme.textTheme.bodyMedium?.color,
          ),
        ),
      ),
    );
  }
}

/// Daily summary tile widget
class _DailySummaryTile extends StatelessWidget {
  final DailySummary summary;

  const _DailySummaryTile({required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius. circular(16),
        border: Border.all(
          color: theme.dividerColor. withOpacity(0.3),
        ),
      ),
      child: Row(
        children:  [
          _buildImage(),
          const SizedBox(width: 12),
          Expanded(child: _buildDetails(theme)),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        summary.imagePath,
        width: 60,
        height:  60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey. withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.eco,
              color:  Colors.green,
              size:  28,
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetails(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          summary.label,
          style: GoogleFonts.manrope(
            fontSize:  14,
            fontWeight: FontWeight.w700,
            color:  theme.textTheme.bodyLarge?. color,
          ),
        ),
        const SizedBox(height: 4),
        _buildDetailRow('Average Temp', summary.averageTemp, theme),
        _buildDetailRow('Average Humidity', summary. averageHumidity, theme),
        _buildDetailRow('Average AQI Level', summary.averageAqi, theme),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(
        '$label:  $value',
        style: GoogleFonts.manrope(
          fontSize:  12,
          fontWeight: FontWeight.w500,
          color: theme.textTheme.bodyMedium?.color?. withOpacity(0.7),
        ),
      ),
    );
  }
}