import 'package:flutter/material.dart';
import 'package:tryo3_app/data/environment_data_source.dart';
import 'package:tryo3_app/services/placeholder_data_service.dart';

/// Repository that manages environmental data access
/// 
/// This repository uses dependency injection to work with any EnvironmentDataSource
/// implementation. This allows seamless switching between:
/// - MockEnvironmentDataSource (current: uses PlaceholderDataService)
/// - ApiEnvironmentDataSource (future: real API integration)
/// - CachedEnvironmentDataSource (future: adds offline support)
/// 
/// All Riverpod providers depend on this repository, so changing the data source
/// requires only updating the provider injection, not the UI or provider logic.
class DataRepository {
  final EnvironmentDataSource _dataSource;

  const DataRepository(this._dataSource);

  // Sensor Clusters
  Future<List<SensorCluster>> fetchSensorClusters() async {
    return _dataSource.getSensorClusters();
  }

  // Metrics for a specific room/cluster
  Future<List<MetricData>> fetchMetricsForRoom(String clusterId) async {
    return _dataSource.getMetricsForRoom(clusterId);
  }

  // Chart data for dashboard
  Future<List<ChartDataPoint>> fetchChartData(String clusterId) async {
    return _dataSource.getChartData(clusterId);
  }

  // Environmental score for history
  Future<EnvironmentalScore> fetchEnvironmentalScore(
    HistoryFilter filter, {
    DateTimeRange? customRange,
  }) async {
    return _dataSource.getEnvironmentalScore(
      filter,
      dateRange: customRange,
    );
  }

  // History chart data
  Future<List<ChartDataPoint>> fetchHistoryChartData(
    HistoryFilter filter, {
    DateTimeRange? customRange,
  }) async {
    return _dataSource.getHistoryChartData(
      filter,
      dateRange: customRange,
    );
  }

  // History chart labels
  Future<List<String>> fetchHistoryChartLabels(
    HistoryFilter filter, {
    DateTimeRange? customRange,
  }) async {
    return _dataSource.getHistoryChartLabels(
      filter,
      dateRange: customRange,
    );
  }

  // Daily summaries for history
  Future<List<DailySummary>> fetchDailySummaries(
    HistoryFilter filter, {
    DateTimeRange? customRange,
  }) async {
    return _dataSource.getDailySummaries(
      filter,
      dateRange: customRange,
    );
  }
}
