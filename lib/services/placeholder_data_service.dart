import 'dart:math' as math;
import 'package:flutter/material.dart';

// DATA MODELS

/// Represents a room/sensor cluster
@immutable
class SensorCluster {
  final String id;
  final String name;
  final IconData icon;

  const SensorCluster({
    required this.id,
    required this.name,
    required this.icon,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SensorCluster &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Represents a single metric reading
@immutable
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
@immutable
class ChartDataPoint {
  final double x;
  final double y;
  final String? label;

  const ChartDataPoint(this.x, this.y, {this.label});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChartDataPoint &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y;

  @override
  int get hashCode => Object.hash(x, y);
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
@immutable
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
@immutable
class DailySummary {
  final String label;
  final String imagePath;
  final String averageTemp;
  final String averageHumidity;
  final String averageAqi;
  final DateTime? date;

  const DailySummary({
    required this.label,
    required this.imagePath,
    required this.averageTemp,
    required this.averageHumidity,
    required this.averageAqi,
    this.date,
  });
}

// PLACEHOLDER DATA SERVICE

/// Service for generating placeholder sensor data
/// This will be replaced with real API calls in production
class PlaceholderDataService {
  static final _random = math.Random(42);

  // Constants
  static const int _minAQI = 40;
  static const int _maxAQI = 130;

  // DASHBOARD DATA

  /// Get all available sensor clusters
  /// Returns a list of sensor clusters for different rooms
  static List<SensorCluster> getSensorClusters() {
    try {
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
    } catch (e) {
      debugPrint('Error getting sensor clusters: $e');
      return [];
    }
  }

  /// Get metrics for a specific room
  /// [roomId] The unique identifier of the room
  /// Returns a list of metric data for the specified room
  static List<MetricData> getMetricsForRoom(String roomId) {
    try {
      // Validate room ID
      if (roomId.isEmpty) {
        debugPrint('Invalid room ID provided');
        return [];
      }

      // Room-specific base values
      final baseAQI = _getBaseAQI(roomId);
      final baseTemp = _getBaseTemp(roomId);
      final baseLux = _getBaseLux(roomId);
      final baseNoise = _getBaseNoise(roomId);

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
          value: _getPollutionLevel(baseAQI),
          unit: '',
          icon: Icons.eco,
          color: _getPollutionColor(baseAQI),
        ),
        MetricData(
          title: 'Noise Level',
          value: baseNoise.toString(),
          unit: 'dB',
          icon: Icons.volume_up,
        ),
      ];
    } catch (e) {
      debugPrint('Error getting metrics for room $roomId: $e');
      return [];
    }
  }

  /// Generate chart data for AQI over 24 hours
  /// [roomId] The unique identifier of the room
  /// Returns a list of chart data points
  static List<ChartDataPoint> getChartData(String roomId) {
    try {
      if (roomId.isEmpty) return [];

      final data = <ChartDataPoint>[];
      final baseValue = _getBaseAQI(roomId).toDouble();

      for (int hour = 0; hour <= 24; hour++) {
        final variation = _calculateHourlyVariation(hour);
        final noise = (_random.nextDouble() - 0.5) * 8;
        final value = (baseValue + variation + noise).clamp(
          _minAQI.toDouble(),
          _maxAQI.toDouble(),
        );

        data.add(ChartDataPoint(hour.toDouble(), value));
      }

      return data;
    } catch (e) {
      debugPrint('Error generating chart data for room $roomId: $e');
      return [];
    }
  }

  // HISTORY DATA

  /// Day labels for the week
  static const List<String> weekDayLabels = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  /// Month short names
  static const List<String> monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  /// Get environmental score based on filter
  /// [filter] The history filter type
  /// [dateRange] Optional custom date range
  /// Returns the environmental score for the specified period
  static EnvironmentalScore getEnvironmentalScore(
    HistoryFilter filter, {
    DateTimeRange? dateRange,
  }) {
    try {
      switch (filter) {
        case HistoryFilter.thisWeek:
          return const EnvironmentalScore(
            score: 7.2,
            changePercent: 1.2,
            isPositive: true,
          );
        case HistoryFilter.thisMonth:
          return const EnvironmentalScore(
            score: 6.8,
            changePercent: 0.5,
            isPositive: true,
          );
        case HistoryFilter.custom:
          return _generateCustomScore(dateRange);
      }
    } catch (e) {
      debugPrint('Error getting environmental score: $e');
      return const EnvironmentalScore(
        score: 0.0,
        changePercent: 0.0,
        isPositive: true,
      );
    }
  }

  /// Get chart labels based on filter and date range
  /// [filter] The history filter type
  /// [dateRange] Optional custom date range
  /// Returns a list of labels for the chart
  static List<String> getChartLabels(
    HistoryFilter filter, {
    DateTimeRange? dateRange,
  }) {
    try {
      switch (filter) {
        case HistoryFilter.thisWeek:
          return weekDayLabels;
        case HistoryFilter.thisMonth:
          return ['Week 1', 'Week 2', 'Week 3', 'Week 4'];
        case HistoryFilter.custom:
          if (dateRange != null) {
            return _generateDateLabels(dateRange);
          }
          return weekDayLabels;
      }
    } catch (e) {
      debugPrint('Error getting chart labels: $e');
      return [];
    }
  }

  /// Get history chart data based on filter
  /// [filter] The history filter type
  /// [dateRange] Optional custom date range
  /// Returns a list of chart data points
  static List<ChartDataPoint> getHistoryChartData(
    HistoryFilter filter, {
    DateTimeRange? dateRange,
  }) {
    try {
      final labels = getChartLabels(filter, dateRange: dateRange);
      if (labels.isEmpty) return [];

      final dataPoints = <ChartDataPoint>[];

      for (int i = 0; i < labels.length; i++) {
        final value = _generateHistoryValue(filter, i);
        dataPoints.add(ChartDataPoint(
          i.toDouble(),
          value.clamp(0, 100),
          label: labels[i],
        ));
      }

      return dataPoints;
    } catch (e) {
      debugPrint('Error getting history chart data: $e');
      return [];
    }
  }

  /// Get daily summaries
  /// [filter] The history filter type
  /// [dateRange] Optional custom date range
  /// Returns a list of daily summaries
  static List<DailySummary> getDailySummaries({
    HistoryFilter filter = HistoryFilter.thisWeek,
    DateTimeRange? dateRange,
  }) {
    try {
      if (filter == HistoryFilter.custom && dateRange != null) {
        return _generateCustomSummaries(dateRange);
      }

      return const [
        DailySummary(
          label: 'Today',
          imagePath: 'assets/plant.jpg',
          averageTemp: '29°C',
          averageHumidity: '65%',
          averageAqi: '5 ppm',
        ),
        DailySummary(
          label: 'Yesterday',
          imagePath: 'assets/plant.jpg',
          averageTemp: '28°C',
          averageHumidity: '68%',
          averageAqi: '6 ppm',
        ),
        DailySummary(
          label: 'Friday',
          imagePath: 'assets/plant.jpg',
          averageTemp: '27°C',
          averageHumidity: '70%',
          averageAqi: '8 ppm',
        ),
      ];
    } catch (e) {
      debugPrint('Error getting daily summaries: $e');
      return [];
    }
  }

  // PRIVATE HELPER METHODS

  /// Get base AQI value for a room
  static int _getBaseAQI(String roomId) {
    switch (roomId) {
      case 'living_room':
        return 75;
      case 'bedroom':
        return 68;
      case 'office':
        return 82;
      default:
        return 70;
    }
  }

  /// Get base temperature for a room
  static int _getBaseTemp(String roomId) {
    switch (roomId) {
      case 'living_room':
        return 22;
      case 'bedroom':
        return 20;
      case 'office':
        return 24;
      default:
        return 22;
    }
  }

  /// Get base lux value for a room
  static int _getBaseLux(String roomId) {
    switch (roomId) {
      case 'living_room':
        return 300;
      case 'bedroom':
        return 150;
      case 'office':
        return 450;
      default:
        return 300;
    }
  }

  /// Get base noise level for a room
  static int _getBaseNoise(String roomId) {
    switch (roomId) {
      case 'living_room':
        return 45;
      case 'bedroom':
        return 35;
      case 'office':
        return 52;
      default:
        return 45;
    }
  }

  /// Calculate hourly variation in AQI
  static double _calculateHourlyVariation(int hour) {
    // Morning spike (7-9 AM)
    if (hour >= 7 && hour <= 9) {
      final progress = (hour - 7) / 2.0;
      return 15 * math.sin(progress * math.pi);
    }
    // Evening spike (6-8 PM)
    else if (hour >= 18 && hour <= 20) {
      final progress = (hour - 18) / 2.0;
      return 20 * math.sin(progress * math.pi);
    }
    // Night drop (10 PM - 5 AM)
    else if (hour >= 22 || hour <= 5) {
      return -10;
    }
    return 0;
  }

  /// Get color based on AQI value
  static Color _getAQIColor(int aqi) {
    if (aqi <= 50) return Colors.green;
    if (aqi <= 100) return Colors.yellow.shade700;
    if (aqi <= 150) return Colors.orange;
    if (aqi <= 200) return Colors.red;
    return Colors.purple;
  }

  /// Get pollution level description
  static String _getPollutionLevel(int aqi) {
    if (aqi < 50) return 'Good';
    if (aqi < 100) return 'Moderate';
    if (aqi < 150) return 'Unhealthy';
    return 'Poor';
  }

  /// Get pollution color
  static Color _getPollutionColor(int aqi) {
    if (aqi < 50) return Colors.green;
    if (aqi < 100) return Colors.orange;
    return Colors.red;
  }

  /// Generate custom environmental score
  static EnvironmentalScore _generateCustomScore(DateTimeRange? dateRange) {
    if (dateRange == null) {
      return const EnvironmentalScore(
        score: 7.0,
        changePercent: 0.3,
        isPositive: false,
      );
    }

    final score = 5.0 + (_random.nextDouble() * 4);
    final change = (_random.nextDouble() * 3) - 1.5;

    return EnvironmentalScore(
      score: double.parse(score.toStringAsFixed(1)),
      changePercent: double.parse(change.abs().toStringAsFixed(1)),
      isPositive: change >= 0,
    );
  }

  /// Generate history value based on filter
  static double _generateHistoryValue(HistoryFilter filter, int index) {
    switch (filter) {
      case HistoryFilter.thisWeek:
        final baseValues = <double>[45, 70, 55, 80, 60, 75, 50];
        return index < baseValues.length ? baseValues[index] : 60;
      case HistoryFilter.thisMonth:
        return 50 + (_random.nextDouble() * 40);
      case HistoryFilter.custom:
        return 40 + (_random.nextDouble() * 50);
    }
  }

  /// Generate date labels for custom range
  static List<String> _generateDateLabels(DateTimeRange range) {
    try {
      final days = range.duration.inDays + 1;
      final labels = <String>[];

      if (days <= 7) {
        // Show each day
        for (int i = 0; i < days; i++) {
          final date = range.start.add(Duration(days: i));
          labels.add('${date.day}/${date.month}');
        }
      } else if (days <= 31) {
        // Show every few days
        final step = (days / 6).ceil();
        for (int i = 0; i < days; i += step) {
          final date = range.start.add(Duration(days: i));
          labels.add('${date.day} ${monthNames[date.month - 1]}');
        }
      } else {
        // Show weekly or monthly
        final weeks = (days / 7).ceil();
        for (int i = 0; i < math.min(weeks, 8); i++) {
          final date = range.start.add(Duration(days: i * 7));
          labels.add('${date.day} ${monthNames[date.month - 1]}');
        }
      }

      return labels;
    } catch (e) {
      debugPrint('Error generating date labels: $e');
      return [];
    }
  }

  /// Generate summaries for custom date range
  static List<DailySummary> _generateCustomSummaries(DateTimeRange range) {
    try {
      final days = range.duration.inDays + 1;
      final summaries = <DailySummary>[];
      final displayDays = math.min(days, 5); // Show max 5 entries

      for (int i = 0; i < displayDays; i++) {
        final date = range.start.add(Duration(days: i));
        final dayName = _getDayLabel(date);

        summaries.add(DailySummary(
          label: dayName,
          imagePath: 'assets/plant.jpg',
          averageTemp: '${25 + _random.nextInt(6)}°C',
          averageHumidity: '${60 + _random.nextInt(15)}%',
          averageAqi: '${4 + _random.nextInt(6)} ppm',
          date: date,
        ));
      }

      return summaries;
    } catch (e) {
      debugPrint('Error generating custom summaries: $e');
      return [];
    }
  }

  /// Get day label from date
  static String _getDayLabel(DateTime date) {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final dateOnly = DateTime(date.year, date.month, date.day);

      if (dateOnly == today) {
        return 'Today';
      } else if (dateOnly == yesterday) {
        return 'Yesterday';
      } else {
        return '${date.day} ${monthNames[date.month - 1]}';
      }
    } catch (e) {
      debugPrint('Error getting day label: $e');
      return '';
    }
  }
}