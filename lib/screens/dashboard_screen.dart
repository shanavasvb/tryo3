import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tryo3_app/widgets/app_bottom_nav_bar.dart';
import 'package:tryo3_app/widgets/app_menu_button.dart';
import 'package:tryo3_app/widgets/dashboard/metric_card.dart';
import 'package:tryo3_app/widgets/dashboard/sensor_cluster_card.dart';
import 'package:tryo3_app/widgets/dashboard/aqi_wave_chart.dart';
import 'package:tryo3_app/widgets/common/error_state_widget.dart';
import 'package:tryo3_app/widgets/common/loading_indicator.dart';
import '../services/placeholder_data_service.dart';

/// Dashboard screen showing sensor clusters and real-time metrics
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  // State variables
  List<SensorCluster> _clusters = [];
  String? _selectedClusterId;
  List<MetricData> _currentMetrics = [];
  List<ChartDataPoint> _chartData = [];
  bool _isLoading = true;
  String? _errorMessage;

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
    _initializeAnimations();
    _initializeData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Initialize animations
  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  /// Initialize placeholder data with error handling
  Future<void> _initializeData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Simulate network delay for realistic behavior
      await Future.delayed(const Duration(milliseconds: 500));

      final clusters = PlaceholderDataService.getSensorClusters();

      if (clusters.isEmpty) {
        throw Exception('No sensor clusters available');
      }

      final selectedId = clusters.first.id;
      final metrics = PlaceholderDataService.getMetricsForRoom(selectedId);
      final chartData = PlaceholderDataService.getChartData(selectedId);

      setState(() {
        _clusters = clusters;
        _selectedClusterId = selectedId;
        _currentMetrics = metrics;
        _chartData = chartData;
        _isLoading = false;
      });

      _animationController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load dashboard data: ${e.toString()}';
      });
      debugPrint('Error initializing data: $e');
    }
  }

  /// Handle room/cluster selection
  Future<void> _onClusterSelected(String clusterId) async {
    if (_selectedClusterId == clusterId) return;

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Simulate data fetch
      await Future.delayed(const Duration(milliseconds: 300));

      final metrics = PlaceholderDataService.getMetricsForRoom(clusterId);
      final chartData = PlaceholderDataService.getChartData(clusterId);

      if (metrics.isEmpty) {
        throw Exception('No metrics available for this cluster');
      }

      setState(() {
        _selectedClusterId = clusterId;
        _currentMetrics = metrics;
        _chartData = chartData;
        _isLoading = false;
      });

      // Replay animation for smooth transition
      _animationController.reset();
      _animationController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load cluster data';
      });
      debugPrint('Error selecting cluster: $e');
    }
  }

  /// Show coming soon dialog for unimplemented features
  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Coming Soon',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
        ),
        content: Text(
          '$feature feature is under development and will be available soon.',
          style: GoogleFonts.manrope(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: _buildAppBar(theme),
      body: _buildBody(theme),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
    );
  }

  /// Build the main body with loading/error states
  Widget _buildBody(ThemeData theme) {
    if (_isLoading && _clusters.isEmpty) {
      return const LoadingIndicator();
    }

    if (_errorMessage != null && _clusters.isEmpty) {
      return ErrorStateWidget(
        message: _errorMessage ?? 'An unknown error occurred',
        onRetry: _initializeData,
      );
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(_horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSensorClustersSection(theme),
            const SizedBox(height: _sectionSpacing),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: LoadingIndicator(),
              )
            else if (_errorMessage != null)
              _buildInlineError()
            else ...[
              _buildKeyMetricsSection(theme),
              const SizedBox(height: _sectionSpacing),
              _buildDetailedDataSection(theme),
            ],
            const SizedBox(height: _horizontalPadding),
          ],
        ),
      ),
    );
  }

  /// Build inline error widget
  Widget _buildInlineError() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: GoogleFonts.manrope(
                fontSize: 13,
                color: Colors.red.shade900,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () => setState(() => _errorMessage = null),
            color: Colors.red.shade700,
          ),
        ],
      ),
    );
  }

  /// Build the app bar
  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      leading: const AppMenuButton(),
      title: Text(
        'Dashboard',
        style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
      ),
      centerTitle: true,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () => _showComingSoonDialog('Notifications'),
          tooltip: 'Notifications',
        ),
      ],
    );
  }

  /// Build the sensor clusters section
  Widget _buildSensorClustersSection(ThemeData theme) {
    if (_clusters.isEmpty) {
      return const SizedBox.shrink();
    }

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
                child: SensorClusterCard(
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

  /// Build the key metrics section
  Widget _buildKeyMetricsSection(ThemeData theme) {
    if (_currentMetrics.isEmpty) {
      return _buildEmptyMetrics();
    }

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

  /// Build empty metrics placeholder
  Widget _buildEmptyMetrics() {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.sensors_off, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'No metrics available',
            style: GoogleFonts.manrope(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  /// Build the metrics grid
  Widget _buildMetricsGrid(ThemeData theme) {
    final gridMetrics = _currentMetrics.take(4).toList();
    final fullWidthMetric = _currentMetrics.length > 4
        ? _currentMetrics[4]
        : null;

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
            return MetricCard(metric: gridMetrics[index]);
          },
        ),
        if (fullWidthMetric != null) ...[
          const SizedBox(height: _itemSpacing),
          MetricCard(metric: fullWidthMetric, fullWidth: true),
        ],
      ],
    );
  }

  /// Build the detailed data section with chart
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

  /// Build the chart container
  Widget _buildChartContainer(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    if (_chartData.isEmpty) {
      return Container(
        height: 240,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
        ),
        child: Center(
          child: Text(
            'No chart data available',
            style: GoogleFonts.manrope(color: Colors.grey.shade600),
          ),
        ),
      );
    }

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
            child: AQIWaveChart(
              data: _chartData,
              lineColor: theme.colorScheme.primary,
              backgroundColor: theme.colorScheme.surface,
              gridColor: theme.dividerColor.withOpacity(0.2),
            ),
          ),
          const SizedBox(height: 12),
          _buildChartTimeLabels(theme),
        ],
      ),
    );
  }

  /// Build time labels for the chart
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

  /// Handle pull-to-refresh
  Future<void> _handleRefresh() async {
    await _initializeData();
  }
}
