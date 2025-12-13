import 'package:flutter/material.dart';
import 'package:tryo3_app/services/placeholder_data_service.dart';

/// Repository that wraps PlaceholderDataService
/// This abstraction allows easy switching to a real API later
/// without changing provider logic
class DataRepository {
  // Sensor Clusters
  List<SensorCluster> getSensorClusters() {
    return PlaceholderDataService.getSensorClusters();
  }

  Future<List<SensorCluster>> fetchSensorClusters() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return getSensorClusters();
  }

  // Metrics for a specific room/cluster
  List<MetricData> getMetricsForRoom(String clusterId) {
    return PlaceholderDataService.getMetricsForRoom(clusterId);
  }

  Future<List<MetricData>> fetchMetricsForRoom(String clusterId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return getMetricsForRoom(clusterId);
  }

  // Chart data for dashboard
  List<ChartDataPoint> getChartData(String clusterId) {
    return PlaceholderDataService.getChartData(clusterId);
  }

  Future<List<ChartDataPoint>> fetchChartData(String clusterId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return getChartData(clusterId);
  }

  // Environmental score for history
  EnvironmentalScore getEnvironmentalScore(
    HistoryFilter filter, {
    DateTimeRange? customRange,
  }) {
    return PlaceholderDataService.getEnvironmentalScore(
      filter,
      dateRange: customRange,
    );
  }

  Future<EnvironmentalScore> fetchEnvironmentalScore(
    HistoryFilter filter, {
    DateTimeRange? customRange,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return getEnvironmentalScore(filter, customRange: customRange);
  }

  // History chart data
  List<ChartDataPoint> getHistoryChartData(
    HistoryFilter filter, {
    DateTimeRange? customRange,
  }) {
    return PlaceholderDataService.getHistoryChartData(
      filter,
      dateRange: customRange,
    );
  }

  Future<List<ChartDataPoint>> fetchHistoryChartData(
    HistoryFilter filter, {
    DateTimeRange? customRange,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return getHistoryChartData(filter, customRange: customRange);
  }

  // History chart labels
  List<String> getHistoryChartLabels(
    HistoryFilter filter, {
    DateTimeRange? customRange,
  }) {
    return PlaceholderDataService.getChartLabels(
      filter,
      dateRange: customRange,
    );
  }

  Future<List<String>> fetchHistoryChartLabels(
    HistoryFilter filter, {
    DateTimeRange? customRange,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return getHistoryChartLabels(filter, customRange: customRange);
  }

  // Daily summaries for history
  List<DailySummary> getDailySummaries(
    HistoryFilter filter, {
    DateTimeRange? customRange,
  }) {
    return PlaceholderDataService.getDailySummaries(
      filter: filter,
      dateRange: customRange,
    );
  }

  Future<List<DailySummary>> fetchDailySummaries(
    HistoryFilter filter, {
    DateTimeRange? customRange,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return getDailySummaries(filter, customRange: customRange);
  }
}
