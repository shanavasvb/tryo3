import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tryo3_app/services/placeholder_data_service.dart';
import 'package:tryo3_app/themes/theme.dart';
import 'package:tryo3_app/widgets/app_bottom_nav_bar.dart';
import 'dart:math' as math;

/// Detail screen for a specific sensor metric
class SensorDetailScreen extends StatefulWidget {
  final MetricData metric;
  final String? roomName;

  const SensorDetailScreen({
    super.key,
    required this.metric,
    this.roomName,
  });

  @override
  State<SensorDetailScreen> createState() => _SensorDetailScreenState();
}

class _SensorDetailScreenState extends State<SensorDetailScreen> {
  bool _isWhatExpandedExpanded = false;
  bool _isAboutExpanded = false;
  String _selectedTimeRange = '24h';
  final List<String> _timeRanges = ['24h', '7d'];
  
  // Generate sample chart data based on time range
  List<double> _generateChartData(String timeRange) {
    final baseValue = double.tryParse(widget.metric.value.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 50;
    final dataPoints = <double>[];
    
    // Different number of points for different time ranges
    final pointCount = timeRange == '24h' ? 24 : 7;
    
    // Use time range as part of seed for variety
    final seed = widget.metric.value.hashCode + (timeRange == '24h' ? 1 : 100);
    final random = math.Random(seed);
    
    for (int i = 0; i < pointCount; i++) {
      final variance = (random.nextDouble() - 0.5) * (baseValue * 0.3);
      final value = baseValue + variance;
      dataPoints.add(value.clamp(0, baseValue * 2));
    }
    
    return dataPoints;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? AppTheme.darkTextColor : AppTheme.lightTextColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.metric.title,
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w700,
            color: isDark ? AppTheme.darkTextColor : AppTheme.lightTextColor,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(isDark),
            const SizedBox(height: 24),
            _buildExpandableInfo(isDark),
            const SizedBox(height: 24),
            _buildTimeRangeSelector(isDark),
            const SizedBox(height: 16),
            _buildChart(isDark),
            const SizedBox(height: 24),
            _buildDeviceInfo(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(bool isDark) {
    final statusColor = _getStatusColor();
    final statusText = _getStatusText();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            widget.metric.value,
            style: GoogleFonts.manrope(
              fontSize: 64,
              fontWeight: FontWeight.w700,
              color: isDark ? AppTheme.darkTextColor : AppTheme.lightTextColor,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            statusText.toUpperCase(),
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: statusColor,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableInfo(bool isDark) {
    return Column(
      children: [
        _buildExpandableSection(
          isDark: isDark,
          title: 'What does this mean?',
          isExpanded: _isWhatExpandedExpanded,
          onTap: () => setState(() => _isWhatExpandedExpanded = !_isWhatExpandedExpanded),
          content: _getWhatDoesThisMean(),
        ),
        const SizedBox(height: 12),
        _buildExpandableSection(
          isDark: isDark,
          title: 'About this Sensor',
          isExpanded: _isAboutExpanded,
          onTap: () => setState(() => _isAboutExpanded = !_isAboutExpanded),
          content: _getMetricDescription(),
        ),
      ],
    );
  }

  Widget _buildExpandableSection({
    required bool isDark,
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
    required String content,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppTheme.darkTextColor : AppTheme.lightTextColor,
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: (isDark ? AppTheme.darkTextColor : AppTheme.lightTextColor)
                        .withOpacity(0.5),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                content,
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  height: 1.6,
                  color: (isDark ? AppTheme.darkTextColor : AppTheme.lightTextColor)
                      .withOpacity(0.6),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimeRangeSelector(bool isDark) {
    return Row(
      children: _timeRanges.map((range) {
        final isSelected = _selectedTimeRange == range;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: range == _timeRanges.first ? 8 : 0),
            child: InkWell(
              onTap: () => setState(() => _selectedTimeRange = range),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryColor
                      : (isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.03)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    range == '24h' ? '24 Hours' : '7 Days',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? AppTheme.darkTextColor : AppTheme.lightTextColor),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildChart(bool isDark) {
    final chartData = _generateChartData(_selectedTimeRange);
    
    // Calculate percentage change based on time range
    final seed = widget.metric.value.hashCode + (_selectedTimeRange == '24h' ? 5 : 50);
    final random = math.Random(seed);
    final percentChange = (random.nextDouble() * 20 - 5).round(); // Range: -5% to +15%
    final isPositive = percentChange >= 0;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.metric.title} Levels',
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.darkTextColor : AppTheme.lightTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                widget.metric.value,
                style: GoogleFonts.manrope(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppTheme.darkTextColor : AppTheme.lightTextColor,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (isPositive ? Colors.green : Colors.red).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Last ${_selectedTimeRange == '24h' ? '24 Hours' : '7 Days'} ${isPositive ? '+' : ''}$percentChange%',
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: CustomPaint(
              painter: _SmoothChartPainter(
                isDark: isDark,
                data: chartData,
                color: _getStatusColor(),
              ),
              size: const Size(double.infinity, 180),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimeLabel(isDark, _selectedTimeRange == '24h' ? '12AM' : 'Mon'),
              _buildTimeLabel(isDark, _selectedTimeRange == '24h' ? '6AM' : 'Wed'),
              _buildTimeLabel(isDark, _selectedTimeRange == '24h' ? '12PM' : 'Fri'),
              _buildTimeLabel(isDark, _selectedTimeRange == '24h' ? '6PM' : 'Sun'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeLabel(bool isDark, String label) {
    return Text(
      label,
      style: GoogleFonts.manrope(
        fontSize: 11,
        color: (isDark ? AppTheme.darkTextColor : AppTheme.lightTextColor)
            .withOpacity(0.5),
      ),
    );
  }

  Widget _buildDeviceInfo(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Device Info',
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.darkTextColor : AppTheme.lightTextColor,
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoRow(isDark, 'Location', widget.roomName ?? 'Unknown Room'),
          Divider(
            height: 32,
            color: (isDark ? AppTheme.darkTextColor : AppTheme.lightTextColor)
                .withOpacity(0.1),
          ),
          _buildInfoRow(isDark, 'Status', 'Online'),
          Divider(
            height: 32,
            color: (isDark ? AppTheme.darkTextColor : AppTheme.lightTextColor)
                .withOpacity(0.1),
          ),
          _buildInfoRow(isDark, 'Last Synced', '2 minutes ago'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(bool isDark, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 14,
            color: (isDark ? AppTheme.darkTextColor : AppTheme.lightTextColor)
                .withOpacity(0.5),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppTheme.darkTextColor : AppTheme.lightTextColor,
          ),
        ),
      ],
    );
  }

  String _getWhatDoesThisMean() {
    switch (widget.metric.title.toLowerCase()) {
      case 'temperature':
      case 'co2':
      case 'carbon monoxide':
        return 'This reading indicates a safe level of ${widget.metric.title.toLowerCase()} in your environment. Carbon monoxide is a colorless, odorless gas that can be dangerous at high levels. The current level is well below the threshold for concern.';
      case 'humidity':
        return 'This reading shows the current humidity level is comfortable. Ideal indoor humidity ranges from 30-60%. The current level helps prevent mold growth and maintains comfort.';
      default:
        return 'This reading indicates the current ${widget.metric.title.toLowerCase()} level in your environment is within safe parameters.';
    }
  }

  String _getMetricDescription() {
    switch (widget.metric.title.toLowerCase()) {
      case 'temperature':
        return 'Temperature sensors monitor the ambient temperature in your space. Optimal indoor temperature typically ranges from 20-22°C (68-72°F) for comfort and energy efficiency.';
      case 'humidity':
        return 'Humidity sensors measure the amount of moisture in the air. Proper humidity levels (30-60%) are crucial for comfort, health, and preventing issues like mold growth or dry conditions.';
      case 'co2':
      case 'carbon dioxide':
        return 'CO2 sensors track carbon dioxide levels, which can indicate air quality and ventilation effectiveness. Levels above 1000 ppm may indicate poor ventilation and can affect cognitive function.';
      case 'carbon monoxide':
        return 'Carbon Monoxide (CO) sensors detect this dangerous, odorless gas produced by incomplete combustion. Any reading above 9 ppm requires immediate attention and ventilation.';
      case 'light':
      case 'luminosity':
        return 'Light sensors measure illumination levels in lux. Proper lighting is essential for comfort and productivity. Office spaces typically need 300-500 lux for general work.';
      case 'noise':
      case 'sound':
        return 'Noise sensors measure sound levels in decibels (dB). Prolonged exposure to levels above 85 dB can cause hearing damage. Comfortable office noise levels are typically 40-50 dB.';
      default:
        return 'This sensor monitors ${widget.metric.title.toLowerCase()} levels to help maintain a comfortable and safe environment. Regular monitoring helps identify patterns and potential issues.';
    }
  }

  Color _getStatusColor() {
    switch (widget.metric.title.toLowerCase()) {
      case 'temperature':
        final temp = double.tryParse(widget.metric.value.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
        if (temp < 18) return Colors.blue;
        if (temp > 24) return Colors.orange;
        return Colors.green;
      case 'humidity':
        final humidity = double.tryParse(widget.metric.value.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
        if (humidity < 30 || humidity > 60) return Colors.orange;
        return Colors.green;
      case 'co2':
      case 'carbon dioxide':
        final co2 = double.tryParse(widget.metric.value.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
        if (co2 > 1000) return Colors.orange;
        if (co2 > 2000) return Colors.red;
        return Colors.green;
      case 'carbon monoxide':
        return Colors.green;
      default:
        return AppTheme.primaryColor;
    }
  }

  String _getStatusText() {
    switch (widget.metric.title.toLowerCase()) {
      case 'temperature':
        final temp = double.tryParse(widget.metric.value.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
        if (temp < 18) return 'Cold';
        if (temp > 24) return 'Warm';
        return 'Comfortable';
      case 'humidity':
        final humidity = double.tryParse(widget.metric.value.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
        if (humidity < 30) return 'Dry';
        if (humidity > 60) return 'Humid';
        return 'Optimal';
      case 'co2':
      case 'carbon dioxide':
        final co2 = double.tryParse(widget.metric.value.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
        if (co2 > 1000) return 'Elevated';
        if (co2 > 2000) return 'High';
        return 'Good';
      case 'carbon monoxide':
        return 'Safe';
      default:
        return 'Normal';
    }
  }
}

class _SmoothChartPainter extends CustomPainter {
  final bool isDark;
  final List<double> data;
  final Color color;

  _SmoothChartPainter({
    required this.isDark,
    required this.data,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withOpacity(0.2),
          color.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Calculate points
    final maxValue = data.reduce(math.max);
    final minValue = data.reduce(math.min);
    final range = maxValue - minValue;
    
    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = (size.width / (data.length - 1)) * i;
      final normalizedValue = range > 0 ? (data[i] - minValue) / range : 0.5;
      final y = size.height - (normalizedValue * size.height * 0.8) - (size.height * 0.1);
      points.add(Offset(x, y));
    }

    // Draw filled area
    final fillPath = Path();
    fillPath.moveTo(0, size.height);
    
    // Create smooth curve
    fillPath.lineTo(points[0].dx, points[0].dy);
    for (int i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];
      final controlPointX = (current.dx + next.dx) / 2;
      
      fillPath.quadraticBezierTo(
        current.dx, current.dy,
        controlPointX, (current.dy + next.dy) / 2,
      );
    }
    fillPath.lineTo(points.last.dx, points.last.dy);
    fillPath.lineTo(size.width, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);

    // Draw line
    final linePath = Path();
    linePath.moveTo(points[0].dx, points[0].dy);
    
    for (int i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];
      final controlPointX = (current.dx + next.dx) / 2;
      
      linePath.quadraticBezierTo(
        current.dx, current.dy,
        controlPointX, (current.dy + next.dy) / 2,
      );
    }
    linePath.lineTo(points.last.dx, points.last.dy);
    canvas.drawPath(linePath, paint);

    // Draw dots at data points
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (final point in points) {
      canvas.drawCircle(point, 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
