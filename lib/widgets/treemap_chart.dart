import 'dart:math';
import 'package:flutter/material.dart';

class PieChart extends StatelessWidget {
  final Map<String, double> shares; // Values are percentages
  final double totalEnergy; // Displayed value in TWh

  const PieChart({
    Key? key,
    required this.shares,
    required this.totalEnergy,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final total = shares.values.fold(0.0, (sum, v) => sum + v);
    final List<ChartData> data = shares.entries.map((entry) {
      final percentage = total > 0 ? (entry.value / total) * 100 : 0;
      return ChartData(entry.key, percentage.toDouble()); // Explicitly convert to double
    }).toList();

    final validEntries = data.where((entry) => entry.value > 0).toList();

    return Container(
      constraints: BoxConstraints(maxHeight: 350), // Allow some room for the legend
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min, // Important: use min
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 200, // Fixed height for the chart
              child: AspectRatio(
                aspectRatio: 1,
                child: CustomPaint(
                  painter: _PieChartPainter(validEntries),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${totalEnergy.toStringAsFixed(1)} TWh',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: validEntries.map((entry) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    color: _getColorForSource(entry.source),
                  ),
                  const SizedBox(width: 4),
                  Text('${entry.source}: ${entry.value.toStringAsFixed(1)}%')
                ],
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForSource(String source) {
    final colors = {
      'Coal': Colors.black87,
      'Gas': Colors.orange,
      'Oil': Colors.brown,
      'Hydro': Colors.blue,
      'Nuclear': Colors.purple,
      'Solar': Colors.yellow,
      'Wind': const Color.fromARGB(255, 20, 106, 146),
      'Biofuel': Colors.green,
      'Renewables': Colors.teal,
    };
    return colors[source] ?? Colors.grey;
  }
}

class _PieChartPainter extends CustomPainter {
  final List<ChartData> entries;

  _PieChartPainter(this.entries);

  @override
  void paint(Canvas canvas, Size size) {
    final total = entries.fold<double>(0.0, (double sum, entry) => sum + entry.value);
    double startAngle = -pi / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2; // Use full radius
    final paint = Paint()..style = PaintingStyle.fill;

    for (final entry in entries) {
      final sweepAngle = (entry.value / total) * 2 * pi;
      paint.color = _getColorForSource(entry.source);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) {
    return oldDelegate.entries != entries;
  }

  Color _getColorForSource(String source) {
    final colors = {
      'Coal': Colors.black87,
      'Gas': Colors.orange,
      'Oil': Colors.brown,
      'Hydro': Colors.blue,
      'Nuclear': Colors.purple,
      'Solar': Colors.yellow,
      'Wind': const Color.fromARGB(255, 20, 106, 146),
      'Biofuel': Colors.green,
      'Renewables': Colors.teal,
    };
    return colors[source] ?? Colors.grey;
  }
}

class ChartData {
  final String source;
  final double value;

  ChartData(this.source, this.value);
}
