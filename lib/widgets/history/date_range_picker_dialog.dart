import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tryo3_app/themes/theme.dart';

/// Custom date range picker dialog for selecting date ranges
class CustomDateRangePickerDialog extends StatefulWidget {
  final DateTimeRange initialRange;
  final DateTime firstDate;
  final DateTime lastDate;

  const CustomDateRangePickerDialog({
    super.key,
    required this.initialRange,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<CustomDateRangePickerDialog> createState() =>
      _CustomDateRangePickerDialogState();
}

class _CustomDateRangePickerDialogState
    extends State<CustomDateRangePickerDialog> {
  late DateTime _currentMonth;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _selectingStart = true;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(
      widget.initialRange.start.year,
      widget.initialRange.start.month,
    );
    _startDate = widget.initialRange.start;
    _endDate = widget.initialRange.end;
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  void _selectDate(DateTime date) {
    setState(() {
      if (_selectingStart) {
        _startDate = date;
        _endDate = null;
        _selectingStart = false;
      } else {
        if (date.isBefore(_startDate!)) {
          _endDate = _startDate;
          _startDate = date;
        } else {
          _endDate = date;
        }
        _selectingStart = true;
      }
    });
  }

  bool _isInRange(DateTime date) {
    if (_startDate == null || _endDate == null) return false;
    return date.isAfter(_startDate!.subtract(const Duration(days: 1))) &&
        date.isBefore(_endDate!.add(const Duration(days: 1)));
  }

  bool _isSelected(DateTime date) {
    if (_startDate == null) return false;
    if (_isSameDay(date, _startDate!)) return true;
    if (_endDate != null && _isSameDay(date, _endDate!)) return true;
    return false;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _getMonthYear() {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[_currentMonth.month - 1]}, ${_currentMonth.year}';
  }

  List<DateTime?> _getDaysInMonth() {
    final firstDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    );
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday % 7;

    final days = <DateTime?>[];

    // Add empty cells for days before the first day of month
    for (int i = 0; i < firstWeekday; i++) {
      days.add(null);
    }

    // Add all days of the month
    for (int i = 1; i <= daysInMonth; i++) {
      days.add(DateTime(_currentMonth.year, _currentMonth.month, i));
    }

    return days;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final days = _getDaysInMonth();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: isDark ? AppTheme.darkBackground : Colors.white,
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Month navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getMonthYear(),
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppTheme.darkTextColor
                        : AppTheme.lightTextColor,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, size: 20),
                      onPressed: _previousMonth,
                      color: isDark
                          ? AppTheme.darkTextColor
                          : AppTheme.lightTextColor,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, size: 20),
                      onPressed: _nextMonth,
                      color: isDark
                          ? AppTheme.darkTextColor
                          : AppTheme.lightTextColor,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Weekday headers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'].map((day) {
                return SizedBox(
                  width: 36,
                  child: Center(
                    child: Text(
                      day,
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: (isDark
                                ? AppTheme.darkTextColor
                                : AppTheme.lightTextColor)
                            .withOpacity(0.5),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 12),

            // Calendar grid
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: days.map((date) {
                if (date == null) {
                  return const SizedBox(width: 36, height: 36);
                }

                final isSelected = _isSelected(date);
                final isInRange = _isInRange(date);
                final isToday = _isSameDay(date, DateTime.now());

                return GestureDetector(
                  onTap: () => _selectDate(date),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryColor
                          : isInRange
                              ? AppTheme.primaryColor.withOpacity(0.1)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: isToday && !isSelected
                          ? Border.all(color: AppTheme.primaryColor, width: 1)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        date.day.toString(),
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                  ? AppTheme.darkTextColor
                                  : AppTheme.lightTextColor),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: BorderSide(
                        color: (isDark
                                ? AppTheme.darkTextColor
                                : AppTheme.lightTextColor)
                            .withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppTheme.darkTextColor
                            : AppTheme.lightTextColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _startDate != null && _endDate != null
                        ? () {
                            Navigator.of(context).pop(
                              DateTimeRange(
                                  start: _startDate!, end: _endDate!),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      disabledBackgroundColor:
                          AppTheme.primaryColor.withOpacity(0.3),
                    ),
                    child: Text(
                      'Apply',
                      style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
