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
  late TextEditingController _controller;
  String? _selectedCountry;  // Add this variable to track selection

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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Autocomplete<String>(
        optionsBuilder: (TextEditingValue textEditingValue) {
          return _getSuggestions(textEditingValue.text);
        },
        onSelected: (String value) {
          setState(() {
            _controller.text = value;  // Only update text
            _selectedCountry = value;  // Store selection
          });
          // Removed automatic submission here
        },
        fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
          _controller = controller;
          return TextField(
            controller: controller,
            focusNode: focusNode,
            decoration: InputDecoration(
              hintText: 'Enter a country name',
              suffixIcon: IconButton(
                icon: Icon(Icons.send),
                onPressed: () => _submitGuess(controller.text),  // Submit on button press
              ),
            ),
            textInputAction: TextInputAction.send,
            onSubmitted: _submitGuess,  // Submit on keyboard action
            keyboardType: TextInputType.text,
            autocorrect: false,
            enableSuggestions: true,
          );
        },
        optionsViewBuilder: (context, onSelected, options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 8.0,
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(4.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.9, // 90% of screen width
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (BuildContext context, int index) {
                    final option = options.elementAt(index);
                    return InkWell(
                      onTap: () => onSelected(option),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                        child: Text(
                          option,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
