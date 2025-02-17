import 'package:flutter/material.dart';
import 'home_screen.dart';

// Utility to get flag emoji for selected countries (expand as needed)
String getFlagEmoji(String country) {
  switch (country.toLowerCase()) {
    case 'albania': return '🇦🇱';
    case 'germany': return '🇩🇪';
    case 'france': return '🇫🇷';
    case 'italy': return '🇮🇹';
    // Add more mappings as needed
    default: return '';
  }
}

class ResultScreen extends StatelessWidget {
  final String resultMessage;

  ResultScreen({required this.resultMessage});

  @override
  Widget build(BuildContext context) {
    // Determine if answer was correct
    bool isCorrect = resultMessage.contains('Correct!');
    // Extract target country from resultMessage (assumes format "The answer was X")
    String target = '';
    if (resultMessage.contains('The answer was')) {
      int index = resultMessage.indexOf('The answer was');
      target = resultMessage.substring(index + 'The answer was'.length).trim();
    }
    // Build formatted texts
    String statusText = isCorrect ? 'Correct! 🎉🎉' : 'Incorrect';
    String answerText = 'The answer was';
    String countryText = target;
    String flagEmoji = getFlagEmoji(target);
    
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(32.0),  // Increased margin
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Status line: correct or incorrect with celebration emojis if correct
              Text(
                statusText,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              // "The answer was" line
              Text(
                answerText,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              // Country line with flag on each side
              Text(
                '$flagEmoji $countryText $flagEmoji',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                    (route) => false,
                  );
                },
                child: Text('Start New Game'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
