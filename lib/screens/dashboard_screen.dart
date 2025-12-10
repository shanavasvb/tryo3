import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// DATA MODELS

/// Represents a room/sensor cluster
class SensorCluster {
  final String id;
  final String name;
  final IconData icon;

  const SensorCluster({
    required this.id,
    required this.name,
    required this.icon,
  });
}

/// Represents a single metric reading
class MetricData {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color? color;

  const MetricData({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    this.color,
  });
}

/// Represents a data point in the chart
class ChartDataPoint {
  final double x; // Time (0-24 hours)
  final double y; // Value

  const ChartDataPoint(this.x, this.y);
}

// ============================================
// PLACEHOLDER DATA GENERATOR
// ============================================

class PlaceholderDataService {
  static final _random = math.Random(42); // Fixed seed for consistent data

  /// Get all available sensor clusters
  static List<SensorCluster> getSensorClusters() {
    return const [
      SensorCluster(
        id: 'living_room',
        name: 'Living Room',
        icon: Icons.weekend,
      ),
      SensorCluster(
        id: 'bedroom',
        name: 'Bedroom',
        icon: Icons.bed,
      ),
      SensorCluster(
        id: 'office',
        name: 'Office',
        icon: Icons.desk,
      ),
    ];
  }

  /// Get metrics for a specific room
  static List<MetricData> getMetricsForRoom(String roomId) {
    // Generate slightly different values based on room
    final baseAQI = roomId == 'living_room' ? 75 : (roomId == 'bedroom' ? 68 : 82);
    final baseTemp = roomId == 'living_room' ? 22 : (roomId == 'bedroom' ? 20 : 24);
    final baseLux = roomId == 'living_room' ? 300 : (roomId == 'bedroom' ? 150 : 450);
    final baseNoise = roomId == 'living_room' ? 45 : (roomId == 'bedroom' ? 35 : 52);

    return [
      MetricData(
        title: 'Air Quality Index',
        value: baseAQI.toString(),
        unit: 'AQI',
        icon: Icons.air,
        color: _getAQIColor(baseAQI),
      ),
      MetricData(
        title: 'Temperature',
        value: baseTemp.toString(),
        unit: '°C',
        icon: Icons.thermostat,
      ),
      MetricData(
        title: 'Light Lux',
        value: baseLux.toString(),
        unit: 'lux',
        icon: Icons.lightbulb_outline,
      ),
      MetricData(
        title: 'Pollution Level',
        value: baseAQI < 50 ? 'Good' : (baseAQI < 100 ? 'Moderate' : 'Poor'),
        unit: '',
        icon: Icons.eco,
        color: baseAQI < 50 ? Colors.green : (baseAQI < 100 ? Colors.orange : Colors.red),
      ),
      MetricData(
        title: 'Noise Level',
        value: baseNoise.toString(),
        unit: 'dB',
        icon: Icons.volume_up,
      ),
    ];
  }

  /// Generate chart data for AQI over 24 hours
  static List<ChartDataPoint> getChartData(String roomId) {
    final data = <ChartDataPoint>[];
    final baseValue = roomId == 'living_room' ? 75.0 : (roomId == 'bedroom' ? 68.0 : 82.0);

    // Generate data points for every hour (0-24)
    for (int hour = 0; hour <= 24; hour++) {
      // Simulate daily pattern: worse during cooking/activity hours
      double variation = 0;
      
      // Morning spike (7-9 AM)
      if (hour >= 7 && hour <= 9) {
        final progress = (hour - 7) / 2.0;
        variation = 15 * math.sin(progress * math.pi);
      }
      // Evening spike (18-20 / 6-8 PM)
      else if (hour >= 18 && hour <= 20) {
        final progress = (hour - 18) / 2.0;
        variation = 20 * math.sin(progress * math.pi);
      }
      // Night time - lower values
      else if (hour >= 22 || hour <= 5) {
        variation = -10;
      }

      // Add smooth random noise
      final noise = (_random.nextDouble() - 0.5) * 8;
      final value = baseValue + variation + noise;

      data.add(ChartDataPoint(hour.toDouble(), value.clamp(40, 130)));
    }

    return data;
  }

  /// Get color based on AQI value
  static Color _getAQIColor(int aqi) {
    if (aqi <= 50) return Colors.green;
    if (aqi <= 100) return Colors.yellow.shade700;
    if (aqi <= 150) return Colors.orange;
    if (aqi <= 200) return Colors.red;
    return Colors.purple;
  }
}

// DASHBOARD SCREEN



class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  // State variables
  late List<SensorCluster> _clusters;
  late String _selectedClusterId;
  late List<MetricData> _currentMetrics;
  late List<ChartDataPoint> _chartData;
  int _selectedNavIndex = 0;

  // Animation controller
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Design constants
  static const double _horizontalPadding = 16.0;
  static const double _sectionSpacing = 24.0;
  static const double _itemSpacing = 12.0;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _initializeAnimations();
    _animationController.forward();
  }

  /// Initialize placeholder data
  void _initializeData() {
    _clusters = PlaceholderDataService.getSensorClusters();
    _selectedClusterId = _clusters.first.id;
    _currentMetrics = PlaceholderDataService.getMetricsForRoom(_selectedClusterId);
    _chartData = PlaceholderDataService.getChartData(_selectedClusterId);
  }

  /// Initialize animations
  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Handle room/cluster selection
  void _onClusterSelected(String clusterId) {
    if (_selectedClusterId == clusterId) return;

    setState(() {
      _selectedClusterId = clusterId;
      _currentMetrics = PlaceholderDataService.getMetricsForRoom(clusterId);
      _chartData = PlaceholderDataService.getChartData(clusterId);
    });

    // Replay animation for smooth transition
    _animationController.reset();
    _animationController.forward();
  }

  /// Handle bottom navigation tap
  void _onNavItemTapped(int index) {
    setState(() {
      _selectedNavIndex = index;
    });

    // TODO: Navigate to different screens
    switch (index) {
      case 0:
        debugPrint('Dashboard selected');
        break;
      case 1:
        debugPrint('History selected');
        // Navigator.pushNamed(context, '/history');
        break;
      case 2:
        debugPrint('Settings selected');
        // Navigator.pushNamed(context, '/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: _buildAppBar(theme),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(_horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSensorClustersSection(theme),
              const SizedBox(height: _sectionSpacing),
              _buildKeyMetricsSection(theme),
              const SizedBox(height: _sectionSpacing),
              _buildDetailedDataSection(theme),
              const SizedBox(height: _horizontalPadding),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(theme),
    );
  }

  /// Builds the app bar
  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () {
          debugPrint('Menu tapped');
          // TODO: Open drawer or menu
        },
        tooltip: 'Menu',
      ),
      title: Text(
        'Dashboard',
        style: GoogleFonts.manrope(
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            debugPrint('Notifications tapped');
            // TODO: Show notifications
          },
          tooltip: 'Notifications',
        ),
      ],
    );
  }

  /// Builds the sensor clusters section
  Widget _buildSensorClustersSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sensor Clusters',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: _itemSpacing),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _clusters.map((cluster) {
              final isSelected = cluster.id == _selectedClusterId;
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: _buildClusterTab(
                  theme: theme,
                  cluster: cluster,
                  isSelected: isSelected,
                  onTap: () => _onClusterSelected(cluster.id),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// Builds a single cluster tab
  Widget _buildClusterTab({
    required ThemeData theme,
    required SensorCluster cluster,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.dividerColor.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              cluster.icon,
              size: 18,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
            ),
            const SizedBox(width: 8),
            Text(
              cluster.name,
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the key metrics section
  Widget _buildKeyMetricsSection(ThemeData theme) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Key Metrics',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: _itemSpacing),
          _buildMetricsGrid(theme),
        ],
      ),
    );
  }

  /// Builds the metrics grid
  Widget _buildMetricsGrid(ThemeData theme) {
    // Separate metrics into grid items and full-width item
    final gridMetrics = _currentMetrics.take(4).toList();
    final fullWidthMetric = _currentMetrics.length > 4 ? _currentMetrics[4] : null;

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: _itemSpacing,
            mainAxisSpacing: _itemSpacing,
          ),
          itemCount: gridMetrics.length,
          itemBuilder: (context, index) {
            return _buildMetricCard(theme, gridMetrics[index]);
          },
        ),
        if (fullWidthMetric != null) ...[
          const SizedBox(height: _itemSpacing),
          _buildMetricCard(theme, fullWidthMetric, fullWidth: true),
        ],
      ],
    );
  }

  /// Builds a single metric card
  Widget _buildMetricCard(
    ThemeData theme,
    MetricData metric, {
    bool fullWidth = false,
  }) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
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
              Text(
                metric.value,
                style: GoogleFonts.manrope(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: metric.color ?? theme.textTheme.bodyLarge?.color,
                  height: 1,
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
    );
  }

  /// Builds the detailed data section with chart
  Widget _buildDetailedDataSection(ThemeData theme) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detailed Data',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'AQI Over Time (24 hours)',
            style: GoogleFonts.manrope(
              fontSize: 14,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.65),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: _itemSpacing),
          _buildChartContainer(theme),
        ],
      ),
    );
  }

  /// Builds the chart container
  Widget _buildChartContainer(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? theme.dividerColor.withOpacity(0.2)
              : Colors.transparent,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        children: [
          Expanded(
            child: CustomPaint(
              painter: AQIChartPainter(
                data: _chartData,
                color: theme.colorScheme.primary,
                backgroundColor: theme.colorScheme.surface,
                gridColor: theme.dividerColor.withOpacity(0.2),
              ),
              child: Container(),
            ),
          ),
          const SizedBox(height: 12),
          _buildChartTimeLabels(theme),
        ],
      ),
    );
  }

  /// Builds time labels for the chart
  Widget _buildChartTimeLabels(ThemeData theme) {
    final labels = ['12AM', '6AM', '12PM', '6PM', '12AM'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: labels.map((label) {
        return Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 11,
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        );
      }).toList(),
    );
  }

  /// Builds the bottom navigation bar
  Widget _buildBottomNavigation(ThemeData theme) {
    return BottomNavigationBar(
      currentIndex: _selectedNavIndex,
      onTap: _onNavItemTapped,
      selectedLabelStyle: GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
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
    // Simulate data refresh
    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      _currentMetrics = PlaceholderDataService.getMetricsForRoom(_selectedClusterId);
      _chartData = PlaceholderDataService.getChartData(_selectedClusterId);
    });

    _animationController.reset();
    _animationController.forward();
  }
}

// CHART PAINTER

/// Custom painter for AQI chart visualization
class AQIChartPainter extends CustomPainter {
  final List<ChartDataPoint> data;
  final Color color;
  final Color backgroundColor;
  final Color gridColor;

  AQIChartPainter({
    required this.data,
    required this.color,
    required this.backgroundColor,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    // Draw grid lines
    _drawGrid(canvas, size);

    // Draw the line chart
    _drawLineChart(canvas, size);

    // Draw area under the curve
    _drawAreaChart(canvas, size);

    // Draw data points
    _drawDataPoints(canvas, size);
  }

  /// Draw grid lines
  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Horizontal grid lines
    for (int i = 0; i <= 4; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }
  }

  /// Draw the line chart
  void _drawLineChart(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = _createChartPath(size);
    canvas.drawPath(path, linePaint);
  }

  /// Draw area under the curve
  void _drawAreaChart(Canvas canvas, Size size) {
    final areaPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withOpacity(0.3),
          color.withOpacity(0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = _createChartPath(size);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, areaPaint);
  }

  /// Draw data points
  void _drawDataPoints(Canvas canvas, Size size) {
    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final outerPointPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    // Draw points at specific hours: 12AM, 6AM, 12PM, 6PM, 12AM
    final pointHours = [0, 6, 12, 18, 24];
    
    for (final hour in pointHours) {
      // Find the data point closest to this hour
      final dataPoint = data.firstWhere(
        (p) => p.x == hour.toDouble(),
        orElse: () => data.first,
      );
      
      final point = _getScreenPosition(dataPoint, size);

      // Outer circle (background color)
      canvas.drawCircle(point, 4.5, outerPointPaint);
      // Inner colored circle
      canvas.drawCircle(point, 3, pointPaint);
    }
  }

  /// Create the chart path
  Path _createChartPath(Size size) {
    final path = Path();
    final minY = data.map((p) => p.y).reduce(math.min);
    final maxY = data.map((p) => p.y).reduce(math.max);
    final yRange = maxY - minY;

    if (data.isEmpty) return path;

    // Start point
    final firstPoint = _getScreenPosition(data.first, size);
    path.moveTo(firstPoint.dx, firstPoint.dy);

    // Create smooth curve using quadratic bezier
    for (int i = 0; i < data.length - 1; i++) {
      final current = _getScreenPosition(data[i], size);
      final next = _getScreenPosition(data[i + 1], size);

      final controlPointX = (current.dx + next.dx) / 2;
      final controlPointY = (current.dy + next.dy) / 2;

      path.quadraticBezierTo(
        current.dx,
        current.dy,
        controlPointX,
        controlPointY,
      );
    }

    // Final point
    final lastPoint = _getScreenPosition(data.last, size);
    path.lineTo(lastPoint.dx, lastPoint.dy);

    return path;
  }

  /// Convert data point to screen coordinates
  Offset _getScreenPosition(ChartDataPoint point, Size size) {
    final minY = data.map((p) => p.y).reduce(math.min);
    final maxY = data.map((p) => p.y).reduce(math.max);
    final yRange = maxY - minY;

    // Add padding to y range
    final paddedMin = minY - yRange * 0.1;
    final paddedMax = maxY + yRange * 0.1;
    final paddedRange = paddedMax - paddedMin;

    final x = (point.x / 24) * size.width;
    final y = size.height - ((point.y - paddedMin) / paddedRange * size.height);

    return Offset(x, y);
  }

  @override
  bool shouldRepaint(covariant AQIChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}