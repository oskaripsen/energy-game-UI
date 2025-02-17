import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class EnergyPieChart extends StatefulWidget {
  final Map<String, double> shares; // Energy source values (TWh)
  final double totalEnergy; // Total energy in TWh

  const EnergyPieChart({
    Key? key,
    required this.shares,
    required this.totalEnergy,
  }) : super(key: key);

  @override
  State<EnergyPieChart> createState() => _EnergyPieChartState();
}

class _EnergyPieChartState extends State<EnergyPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    // Filter out sources with zero values
    final validShares = widget.shares.entries.where((entry) => entry.value > 0).toList();
    
    // Calculate total for correct percentage calculation
    final total = validShares.fold(0.0, (sum, entry) => sum + entry.value);

    return Column(
      children: [
        SizedBox(
          height: 250, // Adjust pie chart height
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: showingSections(validShares, total),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '${widget.totalEnergy.toStringAsFixed(1)} TWh',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: validShares.map((entry) {
            final percentage = (entry.value / total) * 100;
            return Indicator(
              color: _getColorForSource(entry.key),
              // Updated legend: remove absolute TWh value, only show category and percentage
              text: '${entry.key}: ${percentage.toStringAsFixed(1)}%',
            );
          }).toList(),
        ),
      ],
    );
  }

  List<PieChartSectionData> showingSections(List<MapEntry<String, double>> validShares, double total) {
    return List.generate(validShares.length, (index) {
      final entry = validShares[index];
      final percentage = (entry.value / total) * 100;
      final isTouched = index == touchedIndex;
      final fontSize = isTouched ? 18.0 : 14.0;
      final radius = isTouched ? 60.0 : 50.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

      return PieChartSectionData(
        color: _getColorForSource(entry.key),
        value: percentage, // Now displays correct share percentage
        title: '${percentage.toStringAsFixed(1)}%', // Correct percentage with %
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: shadows,
        ),
      );
    });
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

class Indicator extends StatelessWidget {
  final Color color;
  final String text;

  const Indicator({Key? key, required this.color, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
