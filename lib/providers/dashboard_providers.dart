import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tryo3_app/repositories/data_repository.dart';
import 'package:tryo3_app/services/placeholder_data_service.dart';

/// Provider for DataRepository instance
final dataRepositoryProvider = Provider<DataRepository>((ref) {
  return DataRepository();
});

/// State for selected cluster ID
class SelectedClusterNotifier extends StateNotifier<String?> {
  SelectedClusterNotifier() : super(null);

  void selectCluster(String clusterId) {
    state = clusterId;
  }
}

/// Provider for selected cluster
final selectedClusterProvider =
    StateNotifierProvider<SelectedClusterNotifier, String?>((ref) {
  return SelectedClusterNotifier();
});

/// AsyncNotifier for sensor clusters
class SensorClustersNotifier
    extends AsyncNotifier<List<SensorCluster>> {
  @override
  Future<List<SensorCluster>> build() async {
    final repository = ref.read(dataRepositoryProvider);
    return repository.fetchSensorClusters();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(dataRepositoryProvider);
      return repository.fetchSensorClusters();
    });
  }
}

/// Provider for sensor clusters
final sensorClustersProvider =
    AsyncNotifierProvider<SensorClustersNotifier, List<SensorCluster>>(() {
  return SensorClustersNotifier();
});

/// AsyncNotifier for metrics
class MetricsNotifier extends AsyncNotifier<List<MetricData>> {
  @override
  Future<List<MetricData>> build() async {
    final selectedClusterId = ref.watch(selectedClusterProvider);
    if (selectedClusterId == null) return [];

    final repository = ref.read(dataRepositoryProvider);
    return repository.fetchMetricsForRoom(selectedClusterId);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final selectedClusterId = ref.read(selectedClusterProvider);
      if (selectedClusterId == null) return [];

      final repository = ref.read(dataRepositoryProvider);
      return repository.fetchMetricsForRoom(selectedClusterId);
    });
  }
}

/// Provider for metrics
final metricsProvider =
    AsyncNotifierProvider<MetricsNotifier, List<MetricData>>(() {
  return MetricsNotifier();
});

/// AsyncNotifier for chart data
class ChartDataNotifier extends AsyncNotifier<List<ChartDataPoint>> {
  @override
  Future<List<ChartDataPoint>> build() async {
    final selectedClusterId = ref.watch(selectedClusterProvider);
    if (selectedClusterId == null) return [];

    final repository = ref.read(dataRepositoryProvider);
    return repository.fetchChartData(selectedClusterId);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final selectedClusterId = ref.read(selectedClusterProvider);
      if (selectedClusterId == null) return [];

      final repository = ref.read(dataRepositoryProvider);
      return repository.fetchChartData(selectedClusterId);
    });
  }
}

/// Provider for chart data
final chartDataProvider =
    AsyncNotifierProvider<ChartDataNotifier, List<ChartDataPoint>>(() {
  return ChartDataNotifier();
});
