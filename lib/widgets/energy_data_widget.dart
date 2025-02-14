import 'package:flutter/material.dart';
import 'treemap_chart.dart';

class EnergyDataWidget extends StatelessWidget {
  final Map<String, dynamic> energyData;

  EnergyDataWidget({required this.energyData});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> shares = Map<String, dynamic>.from(energyData['energy_shares']);
    final totalEnergy = energyData['total_energy_consumption'];

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Energy Usage: ${totalEnergy.toStringAsFixed(1)} TWh',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Center(
              child: PieChart(
                shares: Map<String, double>.from(shares),
                totalEnergy: totalEnergy,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
