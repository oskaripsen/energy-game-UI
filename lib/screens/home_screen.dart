import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'result_screen.dart';
import '../widgets/energy_data_widget.dart';
import '../widgets/guess_input_widget.dart';
import '../main.dart';  // Import to access MyApp if needed
import '../widgets/guess_history_widget.dart';
import '../config.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Dio _dio;
  Map<String, dynamic>? energyData;
  String? errorMessage;
  int attemptsLeft = 5;
  String? hintMessage;
  String? _correctCountry; // Local storage for the correct answer
  final List<GuessRecord> guessHistory = [];

  @override
  void initState() {
    super.initState();
    print('Using API URL: ${Config.apiUrl}'); // Debug print
    _dio = Dio(BaseOptions(
      baseUrl: Config.apiUrl,
      connectTimeout: const Duration(seconds: 30), // Increased timeout
      receiveTimeout: const Duration(seconds: 30),
      contentType: 'application/json',
    ));
    startGame();
  }

  Future<void> startGame() async {
    if (!mounted) return;

    setState(() {
      energyData = null;
      errorMessage = null;
      guessHistory.clear(); // Clear history when starting new game
    });

    try {
      print('Attempting to connect to ${Config.apiUrl}/start_game'); // Debug print
      final response = await _dio.get('/start_game');
      print('Response received: ${response.data}'); // Debug print

      if (!mounted) return;

      if (response.data != null && response.data['energy_data'] != null) {
        setState(() {
          // Extract and store the correct country separately,
          // then remove it from the displayed energy data.
          energyData =
              Map<String, dynamic>.from(response.data['energy_data']);
          _correctCountry = energyData!['country'];
          energyData!.remove('country');

          attemptsLeft = 5;
          hintMessage = null;
        });
      }
    } catch (e) {
      print("Detailed error: $e"); // More detailed error
      if (e is DioException) {
        print("DioError type: ${e.type}"); // Show DioError type
        print("DioError message: ${e.message}"); // Show error message
      }
      if (!mounted) return;
      setState(() {
        errorMessage = "Server connection failed (${e.toString()}). Is the server running?";
      });
    }
  }

  Future<void> submitGuess(String guess) async {
    try {
      final response = await _dio.post(
        '/guess',
        data: {'guess': guess},
      );

      if (!mounted) return;

      final data = response.data;
      final String target = data['target'] ?? 'Unknown';
      
      setState(() {
        hintMessage = data['message'];
        guessHistory.add(GuessRecord(guess, data['message']));  // Updated to pass string values
        
        if (data['message'].toString().contains('Correct!')) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ResultScreen(
                resultMessage: 'Correct! The answer was $target!',
              ),
            ),
          );
          return;
        }

        attemptsLeft--;
        if (attemptsLeft <= 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ResultScreen(
                resultMessage: 'Out of attempts! The answer was $target',
              ),
            ),
          );
        }
      });
    } catch (e) {
      print("Error during guess: $e");
      setState(() {
        hintMessage = "Failed to submit guess. Please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Guess the country!'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: startGame,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: errorMessage != null
              ? Center(child: Text(errorMessage!))
              : energyData == null
                  ? Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          EnergyDataWidget(energyData: energyData!),
                          if (guessHistory.isNotEmpty)
                            GuessHistoryWidget(guesses: guessHistory),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Text(
                              'Attempts left: $attemptsLeft',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          GuessInputWidget(onSubmit: submitGuess),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }
}
