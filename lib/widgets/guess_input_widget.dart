import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class GuessInputWidget extends StatefulWidget {
  final Function(String) onSubmit;

  GuessInputWidget({required this.onSubmit});

  @override
  _GuessInputWidgetState createState() => _GuessInputWidgetState();
}

class _GuessInputWidgetState extends State<GuessInputWidget> {
  final _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:5000',  // Changed from 127.0.0.1 to localhost
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),  // Added receive timeout
  ));
  
  List<String> _suggestions = [];
  final TextEditingController _controller = TextEditingController();
  String? _selectedCountry;  // Add this variable to track selection

  Future<void> _getSuggestions(String value) async {
    if (value.isEmpty) {
      setState(() {
        _suggestions = [];
        _selectedCountry = null;
      });
      return;
    }

    try {
      final response = await _dio.get('/suggestions', queryParameters: {'prefix': value});
      setState(() {
        _suggestions = List<String>.from(response.data);
        // Clear selected country if it's no longer in suggestions
        if (!_suggestions.contains(_selectedCountry)) {
          _selectedCountry = null;
        }
      });
    } catch (e) {
      print('Error getting suggestions: $e');
      setState(() {
        _suggestions = [];
        _selectedCountry = null;
      });
    }
  }

  bool _isValidGuess() {
    return _selectedCountry != null && _selectedCountry == _controller.text;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: 'Enter country name',
                    contentPadding: EdgeInsets.all(8),
                    border: InputBorder.none,
                  ),
                  onChanged: _getSuggestions,
                ),
                if (_suggestions.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey),
                      ),
                    ),
                    child: Column(
                      children: _suggestions.map((suggestion) => ListTile(
                        title: Text(suggestion),
                        onTap: () {
                          setState(() {
                            _controller.text = suggestion;
                            _selectedCountry = suggestion;
                            _suggestions = [];
                          });
                        },
                      )).toList(),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isValidGuess() 
              ? () {
                  if (_selectedCountry != null) {
                    widget.onSubmit(_selectedCountry!);
                    _controller.clear();
                    setState(() {
                      _suggestions = [];
                      _selectedCountry = null;
                    });
                  }
                }
              : null,
            child: Text('Submit Guess'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
