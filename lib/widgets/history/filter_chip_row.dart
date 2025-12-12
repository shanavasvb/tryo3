import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tryo3_app/services/placeholder_data_service.dart';
import 'package:tryo3_app/themes/theme.dart';

/// Filter chip row widget for quick time period selection
class FilterChipRow extends StatelessWidget {
  final HistoryFilter selectedFilter;
  final Function(HistoryFilter) onSelect;
  final bool isDarkMode;

  const FilterChipRow({
    super.key,
    required this.selectedFilter,
    required this.onSelect,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 12),
      child: Row(
        children: [
          _buildQuickFilterChip('1W', HistoryFilter.thisWeek),
          const SizedBox(width: 8),
          _buildQuickFilterChip('1M', HistoryFilter.thisMonth),
        ],
      ),
    );
  }

  Widget _buildQuickFilterChip(String label, HistoryFilter filter) {
    final isSelected = selectedFilter == filter;
    final isCustomSelected = selectedFilter == HistoryFilter.custom;

    return GestureDetector(
      onTap: () => onSelect(filter),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected && !isCustomSelected
              ? AppTheme.primaryColor
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected && !isCustomSelected
                ? AppTheme.primaryColor
                : (isDarkMode
                    ? AppTheme.darkTextColor.withOpacity(0.4)
                    : AppTheme.lightTextColor.withOpacity(0.4)),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected && !isCustomSelected
                ? AppTheme.darkTextColor
                : (isDarkMode
                    ? AppTheme.darkTextColor.withOpacity(0.7)
                    : AppTheme.lightTextColor.withOpacity(0.7)),
          ),
        ),
      ),
    );
  }
}
