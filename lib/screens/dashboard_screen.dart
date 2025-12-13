import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tryo3_app/providers/dashboard_providers.dart';
import 'package:tryo3_app/services/placeholder_data_service.dart';
import 'package:tryo3_app/widgets/app_bottom_nav_bar.dart';
import 'package:tryo3_app/widgets/app_menu_button.dart';
import 'package:tryo3_app/widgets/app_drawer.dart';
import 'package:tryo3_app/widgets/dashboard/metric_card.dart';
import 'package:tryo3_app/widgets/dashboard/sensor_cluster_card.dart';
import 'package:tryo3_app/widgets/dashboard/aqi_wave_chart.dart';
import 'package:tryo3_app/widgets/common/error_state_widget.dart';
import 'package:tryo3_app/widgets/common/loading_indicator.dart';

/// Dashboard screen showing sensor clusters and real-time metrics
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {

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
    
    // Start animation when metrics are loaded
    _animationController.forward();
  }



  /// Handle room/cluster selection
  void _onClusterSelected(String clusterId) {
    final currentCluster = ref.read(selectedClusterProvider);
    if (currentCluster == clusterId) return;

    ref.read(selectedClusterProvider.notifier).selectCluster(clusterId);

    // Replay animation for smooth transition
    _animationController.reset();
    _animationController.forward();
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
      drawer: const AppDrawer(),
      body: _buildBody(theme),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
    );
  }

  /// Build the main body with loading/error states
  Widget _buildBody(ThemeData theme) {
    final clustersAsync = ref.watch(sensorClustersProvider);

    return clustersAsync.when(
      data: (clusters) {
        if (clusters.isEmpty) {
          return ErrorStateWidget(
            message: 'No sensor clusters available',
            onRetry: () => ref.invalidate(sensorClustersProvider),
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
                _buildSensorClustersSection(theme, clusters),
                const SizedBox(height: _sectionSpacing),
                _buildKeyMetricsSection(theme),
                const SizedBox(height: _sectionSpacing),
                _buildDetailedDataSection(theme),
                const SizedBox(height: _horizontalPadding),
              ],
            ),
          ),
        );
      },
      loading: () => const LoadingIndicator(),
      error: (error, stack) => ErrorStateWidget(
        message: 'Failed to load dashboard data: $error',
        onRetry: () => ref.invalidate(sensorClustersProvider),
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
  Widget _buildSensorClustersSection(ThemeData theme, List<SensorCluster> clusters) {
    final selectedCluster = ref.watch(selectedClusterProvider);

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
            children: clusters.map((cluster) {
              final isSelected = cluster.id == selectedCluster;
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
    final metricsAsync = ref.watch(metricsProvider);

    return metricsAsync.when(
      data: (metrics) {
        if (metrics.isEmpty) {
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
              _buildMetricsGrid(theme, metrics),
            ],
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(32.0),
        child: LoadingIndicator(),
      ),
      error: (error, stack) => Container(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Failed to load metrics: $error',
          style: GoogleFonts.manrope(color: Colors.red),
        ),
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
  Widget _buildMetricsGrid(ThemeData theme, List<MetricData> metrics) {
    final gridMetrics = metrics.take(4).toList();
    final fullWidthMetric = metrics.length > 4
        ? metrics[4]
        : null;
    
    // Get room name from selected cluster
    final selectedClusterId = ref.watch(selectedClusterProvider);
    final clustersAsync = ref.watch(sensorClustersProvider);
    String? roomName;
    
    clustersAsync.whenData((clusters) {
      final selectedCluster = clusters.firstWhere(
        (c) => c.id == selectedClusterId,
        orElse: () => clusters.first,
      );
      roomName = selectedCluster.name;
    });

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
            return MetricCard(metric: gridMetrics[index], roomName: roomName);
          },
        ),
        if (fullWidthMetric != null) ...[
          const SizedBox(height: _itemSpacing),
          MetricCard(metric: fullWidthMetric, fullWidth: true, roomName: roomName),
        ],
      ],
    );
  }

  /// Build the detailed data section with chart
  Widget _buildDetailedDataSection(ThemeData theme) {
    final chartDataAsync = ref.watch(chartDataProvider);

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
          chartDataAsync.when(
            data: (chartData) => _buildChartContainer(theme, chartData),
            loading: () => const SizedBox(
              height: 240,
              child: Center(child: LoadingIndicator()),
            ),
            error: (error, stack) => Container(
              height: 240,
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'Failed to load chart data',
                  style: GoogleFonts.manrope(color: Colors.red),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build the chart container
  Widget _buildChartContainer(ThemeData theme, List<ChartDataPoint> chartData) {
    final isDark = theme.brightness == Brightness.dark;

    if (chartData.isEmpty) {
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
              data: chartData,
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
    ref.invalidate(sensorClustersProvider);
    ref.invalidate(metricsProvider);
    ref.invalidate(chartDataProvider);
  }
}
