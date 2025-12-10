import 'dart:math' as math;

import 'package:flutter/material.dart';


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
  final Color?  color;

  const MetricData({
    required this.title,
    required this.value,
    required this.unit,
    required this. icon,
    this.color,
  });
}

/// Represents a data point in the chart
class ChartDataPoint {
  final double x;
  final double y;

  const ChartDataPoint(this.x, this.y);
}

/// Represents a filter option for history data
enum HistoryFilter {
  thisWeek('This Week'),
  thisMonth('This Month'),
  custom('Custom');

  final String label;
  const HistoryFilter(this.label);
}

/// Represents the environmental score data
class EnvironmentalScore {
  final double score;
  final double changePercent;
  final bool isPositive;

  const EnvironmentalScore({
    required this.score,
    required this.changePercent,
    required this.isPositive,
  });
}

/// Represents a daily summary entry
class DailySummary {
  final String label;
  final String imagePath;
  final String averageTemp;
  final String averageHumidity;
  final String averageAqi;

  const DailySummary({
    required this.label,
    required this.imagePath,
    required this.averageTemp,
    required this.averageHumidity,
    required this.averageAqi,
  });
}

// PLACEHOLDER DATA SERVICE

class PlaceholderDataService {
  static final _random = math.Random(42);

  // DASHBOARD DATA

  /// Get all available sensor clusters
  static List<SensorCluster> getSensorClusters() {
    return const [
      SensorCluster(
        id: 'living_room',
        name: 'Living Room',
        icon: Icons.weekend,
      ),
      SensorCluster(id: 'bedroom', name: 'Bedroom', icon: Icons.bed),
      SensorCluster(id: 'office', name: 'Office', icon: Icons.desk),
    ];
  }

  /// Get metrics for a specific room
  static List<MetricData> getMetricsForRoom(String roomId) {
    final baseAQI = roomId == 'living_room'
        ? 75
        : (roomId == 'bedroom' ? 68 : 82);
    final baseTemp = roomId == 'living_room'
        ?  22
        : (roomId == 'bedroom' ? 20 : 24);
    final baseLux = roomId == 'living_room'
        ? 300
        : (roomId == 'bedroom' ? 150 : 450);
    final baseNoise = roomId == 'living_room'
        ? 45
        : (roomId == 'bedroom' ? 35 : 52);

    return [
      MetricData(
        title:  'Air Quality Index',
        value:  baseAQI.toString(),
        unit: 'AQI',
        icon:  Icons.air,
        color: _getAQIColor(baseAQI),
      ),
      MetricData(
        title: 'Temperature',
        value: baseTemp.toString(),
        unit: '°C',
        icon:  Icons.thermostat,
      ),
      MetricData(
        title: 'Light Lux',
        value: baseLux.toString(),
        unit: 'lux',
        icon: Icons.lightbulb_outline,
      ),
      MetricData(
        title:  'Pollution Level',
        value:  baseAQI < 50 ? 'Good' : (baseAQI < 100 ? 'Moderate' :  'Poor'),
        unit: '',
        icon: Icons.eco,
        color: baseAQI < 50
            ? Colors.green
            : (baseAQI < 100 ? Colors.orange :  Colors.red),
      ),
      MetricData(
        title: 'Noise Level',
        value: baseNoise.toString(),
        unit: 'dB',
        icon: Icons. volume_up,
      ),
    ];
  }

  /// Generate chart data for AQI over 24 hours
  static List<ChartDataPoint> getChartData(String roomId) {
    final data = <ChartDataPoint>[];
    final baseValue = roomId == 'living_room'
        ? 75.0
        : (roomId == 'bedroom' ? 68.0 : 82.0);

    for (int hour = 0; hour <= 24; hour++) {
      double variation = 0;

      if (hour >= 7 && hour <= 9) {
        final progress = (hour - 7) / 2.0;
        variation = 15 * math.sin(progress * math. pi);
      } else if (hour >= 18 && hour <= 20) {
        final progress = (hour - 18) / 2.0;
        variation = 20 * math.sin(progress * math. pi);
      } else if (hour >= 22 || hour <= 5) {
        variation = -10;
      }

      final noise = (_random.nextDouble() - 0.5) * 8;
      final value = baseValue + variation + noise;

      data.add(ChartDataPoint(hour. toDouble(), value.clamp(40, 130)));
    }

    return data;
  }

  /// Get color based on AQI value
  static Color _getAQIColor(int aqi) {
    if (aqi <= 50) return Colors.green;
    if (aqi <= 100) return Colors.yellow. shade700;
    if (aqi <= 150) return Colors.orange;
    if (aqi <= 200) return Colors.red;
    return Colors.purple;
  }

  // HISTORY DATA

  /// Day labels for the chart
  static const List<String> weekDayLabels = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  /// Get environmental score based on filter
  static EnvironmentalScore getEnvironmentalScore(HistoryFilter filter) {
    switch (filter) {
      case HistoryFilter.thisWeek:
        return const EnvironmentalScore(
          score:  7.2,
          changePercent: 1.2,
          isPositive: true,
        );
      case HistoryFilter. thisMonth:
        return const EnvironmentalScore(
          score: 6.8,
          changePercent: 0.5,
          isPositive: true,
        );
      case HistoryFilter.custom:
        return const EnvironmentalScore(
          score: 7.0,
          changePercent: 0.3,
          isPositive: false,
        );
    }
  }

  /// Get history chart data based on filter
  static List<ChartDataPoint> getHistoryChartData(HistoryFilter filter) {
    final baseValues = <double>[45, 70, 55, 80, 60, 75, 50];

    return List.generate(7, (index) {
      double value = baseValues[index];

      if (filter == HistoryFilter.thisMonth) {
        value += (_random.nextDouble() - 0.5) * 10;
      } else if (filter == HistoryFilter. custom) {
        value += (_random. nextDouble() - 0.5) * 15;
      }

      return ChartDataPoint(index.toDouble(), value.clamp(0, 100));
    });
  }

  /// Get daily summaries
  static List<DailySummary> getDailySummaries() {
    return const [
      DailySummary(
        label: 'Today',
        imagePath: 'assets/plant. jpg',
        averageTemp: '29°C',
        averageHumidity:  '65%',
        averageAqi: '5 ppm',
      ),
      DailySummary(
        label: 'Yesterday',
        imagePath: 'assets/plant.jpg',
        averageTemp:  '28°C',
        averageHumidity: '68%',
        averageAqi: '6 ppm',
      ),
      DailySummary(
        label: 'Friday',
        imagePath: 'assets/plant.jpg',
        averageTemp:  '27°C',
        averageHumidity: '70%',
        averageAqi: '8 ppm',
      ),
    ];
  }
}