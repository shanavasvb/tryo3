import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tryo3_app/services/placeholder_data_service.dart';
import 'package:tryo3_app/themes/theme.dart';

/// Daily summary tile widget displaying environmental metrics for a specific day
class DailySummaryTile extends StatelessWidget {
  final DailySummary summary;
  final bool isFirst;
  final bool isLast;

  const DailySummaryTile({
    super.key,
    required this.summary,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isFirst ? 16 : 8),
          topRight: Radius.circular(isFirst ? 16 : 8),
          bottomLeft: Radius.circular(isLast ? 16 : 8),
          bottomRight: Radius.circular(isLast ? 16 : 8),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.white.withOpacity(0.5),
            isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          ],
        ),
        border: Border.all(
          color: isDark
              ? AppTheme.darkTextColor.withOpacity(0.2)
              : AppTheme.lightTextColor.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              summary.imagePath,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.primaryColor.withOpacity(0.3),
                        AppTheme.primaryColor.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.eco,
                    color: AppTheme.primaryColor,
                    size: 32,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  summary.label,
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppTheme.darkTextColor
                        : AppTheme.lightTextColor,
                  ),
                ),
                  const SizedBox(height: 6),
                _buildMetricRow(
                  Icons.air,
                  'AQI Level',
                  summary.averageAqi,
                  const Color.fromARGB(255, 41, 243, 0),
                  isDark,
                ),
                const SizedBox(height: 8),
                _buildMetricRow(
                  Icons.thermostat,
                  'Temperature',
                  summary.averageTemp,
                  Colors.orangeAccent,
                  isDark,
                ),
                const SizedBox(height: 6),
                _buildMetricRow(
                  Icons.water_drop,
                  'Humidity',
                  summary.averageHumidity,
                  AppTheme.accentColor,
                  isDark,
                ),
              
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(
    IconData icon,
    String label,
    String value,
    Color color,
    bool isDark,
  ) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color.withOpacity(0.8)),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppTheme.darkTextColor.withOpacity(0.6)
                : AppTheme.lightTextColor.withOpacity(0.6),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
