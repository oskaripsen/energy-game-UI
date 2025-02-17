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
          height: 350, // Adjust to fit labels
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
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
                        // Debug print to verify touch event
                        print('Touched index updated to: $touchedIndex');
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 2,
                  centerSpaceRadius: 50, // Creates donut hole for TWh text
                  sections: showingSections(validShares, total),
                ),
              ),
              Positioned(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.totalEnergy.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'TWh',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // New external labels widget showing both name and percentage
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: validShares.map((entry) {
            final percentage = (entry.value / total) * 100;
            return Text(
              '${entry.key}: ${percentage.toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
      final fontSize = isTouched ? 16.0 : 12.0;
      final radius = isTouched ? 70.0 : 60.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

      return PieChartSectionData(
        color: _getColorForSource(entry.key),
        value: percentage,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: shadows,
        ),
        // Only show the badge on touch
        badgeWidget: isTouched ? _buildCallout(entry.key, entry.value, percentage) : null,
        badgePositionPercentageOffset: getLabelPosition(index, validShares.length),
      );
    });
  }

  /// Updated callout displays category name, absolute value (TWh) and percentage.
  Widget _buildCallout(String source, double absoluteValue, double percentage) {
    return Transform.translate(
      // Increase vertical offset to ensure badge is visible
      offset: const Offset(0, -20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              source, 
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            Text(
              '${absoluteValue.toStringAsFixed(1)} TWh',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  /// Dynamically positions the labels to avoid overlapping
  double getLabelPosition(int index, int totalLabels) {
    return 1.2 + (index % 2 == 0 ? 0.1 : -0.1); // Alternates positions
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
