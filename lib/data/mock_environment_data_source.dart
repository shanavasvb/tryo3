import 'package:flutter/material.dart';
import 'package:tryo3_app/data/environment_data_source.dart';
import 'package:tryo3_app/services/placeholder_data_service.dart';

/// Mock implementation of EnvironmentDataSource using PlaceholderDataService
/// 
/// This implementation wraps the PlaceholderDataService to provide mock data
/// for development and testing. When ready to integrate with a real API,
/// create a new implementation (e.g., ApiEnvironmentDataSource) that implements
/// the same EnvironmentDataSource interface.
/// 
/// The DataRepository and all Riverpod providers will work with any implementation
/// of EnvironmentDataSource without requiring any changes.
class MockEnvironmentDataSource implements EnvironmentDataSource {
  const MockEnvironmentDataSource();

  @override
  Future<List<SensorCluster>> getSensorClusters() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return PlaceholderDataService.getSensorClusters();
  }

  @override
  Future<List<MetricData>> getMetricsForRoom(String clusterId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    return PlaceholderDataService.getMetricsForRoom(clusterId);
  }

  @override
  Future<List<ChartDataPoint>> getChartData(String clusterId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 400));
    return PlaceholderDataService.getChartData(clusterId);
  }

  @override
  Future<EnvironmentalScore> getEnvironmentalScore(
    HistoryFilter filter, {
    DateTimeRange? dateRange,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return PlaceholderDataService.getEnvironmentalScore(
      filter,
      dateRange: dateRange,
    );
  }

  @override
  Future<List<ChartDataPoint>> getHistoryChartData(
    HistoryFilter filter, {
    DateTimeRange? dateRange,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 400));
    return PlaceholderDataService.getHistoryChartData(
      filter,
      dateRange: dateRange,
    );
  }

  @override
  Future<List<String>> getHistoryChartLabels(
    HistoryFilter filter, {
    DateTimeRange? dateRange,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    return PlaceholderDataService.getChartLabels(
      filter,
      dateRange: dateRange,
    );
  }

  @override
  Future<List<DailySummary>> getDailySummaries(
    HistoryFilter filter, {
    DateTimeRange? dateRange,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 400));
    return PlaceholderDataService.getDailySummaries(
      filter: filter,
      dateRange: dateRange,
    );
  }
}
