import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tryo3_app/screens/sensor_detail_screen.dart';
import '../../services/placeholder_data_service.dart';

/// Displays an individual metric card with title, value, and unit
class MetricCard extends StatelessWidget {
  final MetricData metric;
  final bool fullWidth;
  final String? roomName;

  const MetricCard({super.key, required this.metric, this.fullWidth = false, this.roomName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SensorDetailScreen(
              metric: metric,
              roomName: roomName,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? theme.dividerColor.withOpacity(0.3)
              : theme.dividerColor.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            metric.title,
            style: GoogleFonts.manrope(
              fontSize: 12,
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  metric.value,
                  style: GoogleFonts.manrope(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: metric.color ?? theme.textTheme.bodyLarge?.color,
                    height: 1,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (metric.unit.isNotEmpty) ...[
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    metric.unit,
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
      ),
    );
  }
}
