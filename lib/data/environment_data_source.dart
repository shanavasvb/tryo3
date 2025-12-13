import 'package:flutter/material.dart';
import 'package:tryo3_app/services/placeholder_data_service.dart';

/// Abstract data source interface for environmental data
/// 
/// This interface defines the contract for fetching environmental data.
/// Implementations can use mock data, REST APIs, GraphQL, or any other data source.
/// 
/// Future implementations:
/// - ApiEnvironmentDataSource: Real API integration
/// - CachedEnvironmentDataSource: Adds caching layer
/// - MockEnvironmentDataSource: Current implementation using placeholder data
abstract class EnvironmentDataSource {
  /// Get all sensor clusters
  Future<List<SensorCluster>> getSensorClusters();

  /// Get metrics for a specific cluster/room
  Future<List<MetricData>> getMetricsForRoom(String clusterId);

  /// Get chart data for a specific cluster
  Future<List<ChartDataPoint>> getChartData(String clusterId);

  /// Get environmental score for history view
  Future<EnvironmentalScore> getEnvironmentalScore(
    HistoryFilter filter, {
    DateTimeRange? dateRange,
  });

  /// Get historical chart data
  Future<List<ChartDataPoint>> getHistoryChartData(
    HistoryFilter filter, {
    DateTimeRange? dateRange,
  });

  /// Get chart labels for history view
  Future<List<String>> getHistoryChartLabels(
    HistoryFilter filter, {
    DateTimeRange? dateRange,
  });

  /// Get daily summaries for history view
  Future<List<DailySummary>> getDailySummaries(
    HistoryFilter filter, {
    DateTimeRange? dateRange,
  });
}
