import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GuessRecord {
  final String guess;
  final String message;

  GuessRecord(this.guess, this.message);
}

class GuessHistoryWidget extends StatelessWidget {
  final List<GuessRecord> guesses;
  final _numberFormat = NumberFormat('#,###');

  GuessHistoryWidget({required this.guesses});

  String _formatMessage(String message) {
    if (message.contains('Try looking')) {
      // Updated regex to better match the direction pattern
      final RegExp directionExp = RegExp(r'Try looking ([A-Za-z]+)\.? Distance: ([\d.]+) km');
      final match = directionExp.firstMatch(message);
      
      if (match != null) {
        final direction = match.group(1)!;  // The full direction (e.g., "NorthEast")
        final distance = double.parse(match.group(2)!);
        final emoji = _getDirectionEmoji(direction);
        return '$direction $emoji  Distance: ${_numberFormat.format(distance.round())} km';
      }
    }
    return message;
  }

  String _getDirectionEmoji(String direction) {
    switch (direction) {
      case 'North': return '⬆️';
      case 'South': return '⬇️';
      case 'East': return '➡️';
      case 'West': return '⬅️';
      case 'NorthEast': return '↗️';
      case 'NorthWest': return '↖️';
      case 'SouthEast': return '↘️';
      case 'SouthWest': return '↙️';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (guesses.isEmpty) return SizedBox.shrink();

    return Card(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Previous Guesses:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            ...guesses.map((record) => Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${record.guess}: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Text(_formatMessage(record.message)),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }
}
