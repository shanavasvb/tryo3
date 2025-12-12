import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tryo3_app/services/placeholder_data_service.dart';
import 'package:tryo3_app/themes/theme.dart';

/// History chart widget displaying environmental data trends over time
class HistoryChart extends StatelessWidget {
  final List<ChartDataPoint> chartData;
  final List<String> chartLabels;
  final bool isDarkMode;
  final double height;

  const HistoryChart({
    super.key,
    required this.chartData,
    required this.chartLabels,
    required this.isDarkMode,
    this.height = 220.0,
  });

  @override
  Widget build(BuildContext context) {
    final lineColor = AppTheme.primaryColor;

    if (chartData.isEmpty) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDarkMode
                ? AppTheme.darkTextColor.withOpacity(0.3)
                : AppTheme.lightTextColor.withOpacity(0.3),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bar_chart,
                size: 48,
                color: isDarkMode
                    ? AppTheme.darkTextColor.withOpacity(0.6)
                    : AppTheme.lightTextColor.withOpacity(0.6),
              ),
              const SizedBox(height: 12),
              Text(
                'No chart data available',
                style: GoogleFonts.manrope(
                  color: isDarkMode
                      ? AppTheme.darkTextColor.withOpacity(0.6)
                      : AppTheme.lightTextColor.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: height,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (chartData.length - 1).toDouble().clamp(0, double.infinity),
          minY: 0,
          maxY: 100,
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            horizontalInterval: 20,
            getDrawingHorizontalLine: (value) => FlLine(
              color: isDarkMode
                  ? AppTheme.darkTextColor.withOpacity(0.1)
                  : AppTheme.lightTextColor.withOpacity(0.1),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(
              color: isDarkMode
                  ? AppTheme.darkTextColor.withOpacity(0.2)
                  : AppTheme.lightTextColor.withOpacity(0.2),
            ),
          ),
          titlesData: _buildChartTitles(),
          lineBarsData: [_buildLineChartBarData(lineColor)],
          lineTouchData: _buildLineTouchData(lineColor),
        ),
      ),
    );
  }

  FlTitlesData _buildChartTitles() {
    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          interval: 20,
          getTitlesWidget: (value, meta) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                value.toInt().toString(),
                style: GoogleFonts.manrope(
                  color: isDarkMode
                      ? AppTheme.darkTextColor.withOpacity(0.6)
                      : AppTheme.lightTextColor.withOpacity(0.6),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          },
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 28,
          interval: 1,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();

            if (chartLabels.isEmpty) return const SizedBox.shrink();

            final totalLabels = chartLabels.length;
            final showEvery = totalLabels <= 7 ? 1 : (totalLabels / 6).ceil();

            if (index < 0 ||
                index >= chartLabels.length ||
                (index % showEvery != 0 && index != totalLabels - 1)) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                chartLabels[index],
                style: GoogleFonts.manrope(
                  color: isDarkMode
                      ? AppTheme.darkTextColor.withOpacity(0.6)
                      : AppTheme.lightTextColor.withOpacity(0.6),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  LineChartBarData _buildLineChartBarData(Color lineColor) {
    return LineChartBarData(
      isCurved: true,
      curveSmoothness: 0.2,
      color: lineColor,
      barWidth: 3,
      isStrokeCapRound: true,
      shadow: Shadow(
        color: lineColor.withOpacity(0.3),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: index % 2 == 0 ? 5 : 3,
            color: lineColor,
            strokeWidth: 2,
            strokeColor: isDarkMode ? AppTheme.darkBackground : Colors.white,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [lineColor.withOpacity(0.3), lineColor.withOpacity(0.1)],
        ),
      ),
      spots: chartData.map((point) => FlSpot(point.x, point.y)).toList(),
    );
  }

  LineTouchData _buildLineTouchData(Color lineColor) {
    return LineTouchData(
      enabled: true,
      touchTooltipData: LineTouchTooltipData(
        getTooltipColor: (spot) =>
            isDarkMode ? Colors.white.withOpacity(0.1) : Colors.white,
        getTooltipItems: (touchedSpots) {
          return touchedSpots.map((spot) {
            final index = spot.x.toInt();
            final label = (index >= 0 && index < chartLabels.length)
                ? chartLabels[index]
                : '';
            return LineTooltipItem(
              '$label\n${spot.y.toStringAsFixed(1)}',
              GoogleFonts.manrope(
                color: isDarkMode
                    ? AppTheme.darkTextColor
                    : AppTheme.lightTextColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              children: [
                TextSpan(
                  text: ' Score',
                  style: GoogleFonts.manrope(
                    color: isDarkMode
                        ? AppTheme.darkTextColor.withOpacity(0.6)
                        : AppTheme.lightTextColor.withOpacity(0.6),
                    fontWeight: FontWeight.w400,
                    fontSize: 11,
                  ),
                ),
              ],
            );
          }).toList();
        },
      ),
    );
  }
}
