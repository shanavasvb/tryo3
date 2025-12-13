import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tryo3_app/providers/app_providers.dart';
import 'package:tryo3_app/services/placeholder_data_service.dart';

/// State for selected history filter
class SelectedFilterNotifier extends StateNotifier<HistoryFilter> {
  SelectedFilterNotifier() : super(HistoryFilter.thisWeek);

  void selectFilter(HistoryFilter filter) {
    state = filter;
  }
}

/// Provider for selected history filter
final selectedFilterProvider =
    StateNotifierProvider<SelectedFilterNotifier, HistoryFilter>((ref) {
  return SelectedFilterNotifier();
});

/// State for custom date range
class CustomDateRangeNotifier extends StateNotifier<DateTimeRange?> {
  CustomDateRangeNotifier() : super(null);

  void setDateRange(DateTimeRange? range) {
    state = range;
  }
}

/// Provider for custom date range
final customDateRangeProvider =
    StateNotifierProvider<CustomDateRangeNotifier, DateTimeRange?>((ref) {
  return CustomDateRangeNotifier();
});

/// AsyncNotifier for environmental score
class EnvironmentalScoreNotifier extends AsyncNotifier<EnvironmentalScore> {
  @override
  Future<EnvironmentalScore> build() async {
    final filter = ref.watch(selectedFilterProvider);
    final customRange = ref.watch(customDateRangeProvider);

    final repository = ref.read(dataRepositoryProvider);
    return repository.fetchEnvironmentalScore(
      filter,
      customRange: customRange,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final filter = ref.read(selectedFilterProvider);
      final customRange = ref.read(customDateRangeProvider);

      final repository = ref.read(dataRepositoryProvider);
      return repository.fetchEnvironmentalScore(
        filter,
        customRange: customRange,
      );
    });
  }
}

/// Provider for environmental score
final environmentalScoreProvider =
    AsyncNotifierProvider<EnvironmentalScoreNotifier, EnvironmentalScore>(() {
  return EnvironmentalScoreNotifier();
});

/// AsyncNotifier for history chart data
class HistoryChartDataNotifier extends AsyncNotifier<List<ChartDataPoint>> {
  @override
  Future<List<ChartDataPoint>> build() async {
    final filter = ref.watch(selectedFilterProvider);
    final customRange = ref.watch(customDateRangeProvider);

    final repository = ref.read(dataRepositoryProvider);
    return repository.fetchHistoryChartData(
      filter,
      customRange: customRange,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final filter = ref.read(selectedFilterProvider);
      final customRange = ref.read(customDateRangeProvider);

      final repository = ref.read(dataRepositoryProvider);
      return repository.fetchHistoryChartData(
        filter,
        customRange: customRange,
      );
    });
  }
}

/// Provider for history chart data
final historyChartDataProvider =
    AsyncNotifierProvider<HistoryChartDataNotifier, List<ChartDataPoint>>(() {
  return HistoryChartDataNotifier();
});

/// AsyncNotifier for history chart labels
class HistoryChartLabelsNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async {
    final filter = ref.watch(selectedFilterProvider);
    final customRange = ref.watch(customDateRangeProvider);

    final repository = ref.read(dataRepositoryProvider);
    return repository.fetchHistoryChartLabels(
      filter,
      customRange: customRange,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final filter = ref.read(selectedFilterProvider);
      final customRange = ref.read(customDateRangeProvider);

      final repository = ref.read(dataRepositoryProvider);
      return repository.fetchHistoryChartLabels(
        filter,
        customRange: customRange,
      );
    });
  }
}

/// Provider for history chart labels
final historyChartLabelsProvider =
    AsyncNotifierProvider<HistoryChartLabelsNotifier, List<String>>(() {
  return HistoryChartLabelsNotifier();
});

/// AsyncNotifier for daily summaries
class DailySummariesNotifier extends AsyncNotifier<List<DailySummary>> {
  @override
  Future<List<DailySummary>> build() async {
    final filter = ref.watch(selectedFilterProvider);
    final customRange = ref.watch(customDateRangeProvider);

    final repository = ref.read(dataRepositoryProvider);
    return repository.fetchDailySummaries(
      filter,
      customRange: customRange,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final filter = ref.read(selectedFilterProvider);
      final customRange = ref.read(customDateRangeProvider);

      final repository = ref.read(dataRepositoryProvider);
      return repository.fetchDailySummaries(
        filter,
        customRange: customRange,
      );
    });
  }
}

/// Provider for daily summaries
final dailySummariesProvider =
    AsyncNotifierProvider<DailySummariesNotifier, List<DailySummary>>(() {
  return DailySummariesNotifier();
});
