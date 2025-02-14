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
  late final TextEditingController _controller;
  String? _selectedCountry;  // Add this variable to track selection

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  Future<List<String>> _getSuggestions(String value) async {
    if (value.isEmpty) {
      setState(() {
        _suggestions = [];
        _selectedCountry = null;
      });
      return [];
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
      return _suggestions;
    } catch (e) {
      print('Error getting suggestions: $e');
      setState(() {
        _suggestions = [];
        _selectedCountry = null;
      });
      return [];
    }
  }

  void _submitGuess(String value) {
    if (_selectedCountry != null && _selectedCountry == value) {
      widget.onSubmit(_selectedCountry!);
      _controller.clear();
      setState(() {
        _suggestions = [];
        _selectedCountry = null;
      });
    }
  }

  bool _isValidGuess() {
    return _selectedCountry != null && _selectedCountry == _controller.text;
  }

  void _showSuggestions(BuildContext context, List<String> suggestions) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext bc) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.4,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                margin: EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: suggestions.length,
                  separatorBuilder: (context, i) => Divider(height: 1),
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        suggestions[index],
                        style: TextStyle(fontSize: 18),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      onTap: () {
                        setState(() {
                          _selectedCountry = suggestions[index];
                          _controller.text = suggestions[index];
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Enter a country name',
              border: OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(Icons.send),
                onPressed: () => _submitGuess(_controller.text),
              ),
            ),
            onChanged: (value) async {
              if (value.length >= 1) {
                final suggestions = await _getSuggestions(value);
                if (suggestions.isNotEmpty) {
                  _showSuggestions(context, suggestions);
                }
              }
            },
            textInputAction: TextInputAction.search,
            onSubmitted: _submitGuess,
            keyboardType: TextInputType.text,
            autocorrect: false,
            enableSuggestions: true,
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
