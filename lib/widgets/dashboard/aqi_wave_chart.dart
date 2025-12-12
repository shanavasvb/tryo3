import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../services/placeholder_data_service.dart';

/// Displays an AQI wave chart with gradient area fill and data points
class AQIWaveChart extends StatelessWidget {
  final List<ChartDataPoint> data;
  final Color lineColor;
  final Color backgroundColor;
  final Color gridColor;

  const AQIWaveChart({
    super.key,
    required this.data,
    required this.lineColor,
    required this.backgroundColor,
    required this.gridColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: AQIChartPainter(
        data: data,
        color: lineColor,
        backgroundColor: backgroundColor,
        gridColor: gridColor,
      ),
      child: Container(),
    );
  }
}

/// Custom painter for AQI chart visualization
class AQIChartPainter extends CustomPainter {
  final List<ChartDataPoint> data;
  final Color color;
  final Color backgroundColor;
  final Color gridColor;

  AQIChartPainter({
    required this.data,
    required this.color,
    required this.backgroundColor,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty || size.width <= 0 || size.height <= 0) return;

    _drawGrid(canvas, size);
    _drawAreaChart(canvas, size);
    _drawLineChart(canvas, size);
    _drawDataPoints(canvas, size);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (int i = 0; i <= 4; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  void _drawLineChart(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = _createChartPath(size);
    canvas.drawPath(path, linePaint);
  }

  void _drawAreaChart(Canvas canvas, Size size) {
    final areaPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withOpacity(0.3), color.withOpacity(0.05)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = _createChartPath(size);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, areaPaint);
  }

  void _drawDataPoints(Canvas canvas, Size size) {
    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final outerPointPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    final pointHours = [0, 6, 12, 18, 24];

    for (final hour in pointHours) {
      try {
        final dataPoint = data.firstWhere(
          (p) => p.x == hour.toDouble(),
          orElse: () => data.first,
        );

        final point = _getScreenPosition(dataPoint, size);

        if (point.dx.isFinite && point.dy.isFinite) {
          canvas.drawCircle(point, 4.5, outerPointPaint);
          canvas.drawCircle(point, 3, pointPaint);
        }
      } catch (e) {
        debugPrint('Error drawing point for hour $hour: $e');
      }
    }
  }

  Path _createChartPath(Size size) {
    final path = Path();

    if (data.isEmpty) return path;

    try {
      final firstPoint = _getScreenPosition(data.first, size);
      path.moveTo(firstPoint.dx, firstPoint.dy);

      for (int i = 0; i < data.length - 1; i++) {
        final current = _getScreenPosition(data[i], size);
        final next = _getScreenPosition(data[i + 1], size);

        if (!current.dx.isFinite ||
            !current.dy.isFinite ||
            !next.dx.isFinite ||
            !next.dy.isFinite) {
          continue;
        }

        final controlPointX = (current.dx + next.dx) / 2;
        final controlPointY = (current.dy + next.dy) / 2;

        path.quadraticBezierTo(
          current.dx,
          current.dy,
          controlPointX,
          controlPointY,
        );
      }

      final lastPoint = _getScreenPosition(data.last, size);
      if (lastPoint.dx.isFinite && lastPoint.dy.isFinite) {
        path.lineTo(lastPoint.dx, lastPoint.dy);
      }
    } catch (e) {
      debugPrint('Error creating chart path: $e');
    }

    return path;
  }

  Offset _getScreenPosition(ChartDataPoint point, Size size) {
    try {
      final minY = data.map((p) => p.y).reduce(math.min);
      final maxY = data.map((p) => p.y).reduce(math.max);
      final yRange = maxY - minY;

      final paddedMin = minY - yRange * 0.1;
      final paddedMax = maxY + yRange * 0.1;
      final paddedRange = paddedMax - paddedMin;

      if (paddedRange == 0) {
        return Offset((point.x / 24) * size.width, size.height / 2);
      }

      final x = (point.x / 24) * size.width;
      final y =
          size.height - ((point.y - paddedMin) / paddedRange * size.height);

      return Offset(x.clamp(0, size.width), y.clamp(0, size.height));
    } catch (e) {
      debugPrint('Error calculating screen position: $e');
      return Offset.zero;
    }
  }

  @override
  bool shouldRepaint(covariant AQIChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
