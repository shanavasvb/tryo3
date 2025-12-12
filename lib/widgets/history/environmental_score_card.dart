import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tryo3_app/services/placeholder_data_service.dart';
import 'package:tryo3_app/themes/theme.dart';

/// Environmental score card widget displaying overall environmental quality
class EnvironmentalScoreCard extends StatelessWidget {
  final EnvironmentalScore score;
  final bool isDarkMode;

  const EnvironmentalScoreCard({
    super.key,
    required this.score,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final changeColor = score.isPositive
        ? AppTheme.primaryColor.withOpacity(0.8)
        : Colors.red;
    final changePrefix = score.isPositive ? '+' : '-';
    final trendIcon =
        score.isPositive ? Icons.trending_up : Icons.trending_down;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withOpacity(0.1),
            AppTheme.primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Environmental Score',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode
                      ? AppTheme.darkTextColor.withOpacity(0.8)
                      : AppTheme.lightTextColor.withOpacity(0.8),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: changeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(trendIcon, size: 16, color: changeColor),
                    const SizedBox(width: 4),
                    Text(
                      '$changePrefix${score.changePercent.abs()}%',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: changeColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                score.score.toStringAsFixed(1),
                style: GoogleFonts.manrope(
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  color: isDarkMode
                      ? AppTheme.darkTextColor
                      : AppTheme.lightTextColor,
                  height: 0.9,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '/100',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode
                      ? AppTheme.darkTextColor.withOpacity(0.6)
                      : AppTheme.lightTextColor.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: score.score / 100,
            backgroundColor: isDarkMode
                ? AppTheme.darkTextColor.withOpacity(0.2)
                : AppTheme.lightTextColor.withOpacity(0.2),
            color: _getScoreColor(score.score),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 8),
          Text(
            _getScoreDescription(score.score),
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDarkMode
                  ? AppTheme.darkTextColor.withOpacity(0.7)
                  : AppTheme.lightTextColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double scoreValue) {
    if (scoreValue >= 80) return AppTheme.primaryColor.withOpacity(0.8);
    if (scoreValue >= 60) return AppTheme.accentColor;
    if (scoreValue >= 40) return Colors.amberAccent;
    return Colors.red;
  }

  String _getScoreDescription(double scoreValue) {
    if (scoreValue >= 80) return 'Excellent environmental quality';
    if (scoreValue >= 60) return 'Good environmental conditions';
    if (scoreValue >= 40) return 'Moderate environmental quality';
    return 'Poor environmental conditions';
  }
}
