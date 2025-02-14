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
      child: Column(  // Wrap in Column to contain suggestions below input
        children: [
          Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              return _getSuggestions(textEditingValue.text);
            },
            onSelected: (String value) {
              setState(() {
                _controller.text = value;
                _selectedCountry = value;
              });
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
                    onPressed: () => _submitGuess(controller.text),
                  ),
                  border: OutlineInputBorder(),  // Add border for better visibility
                ),
                textInputAction: TextInputAction.search,  // Changed to search
                onSubmitted: _submitGuess,
                keyboardType: TextInputType.text,
                autocorrect: false,
                enableSuggestions: true,
              );
            },
            optionsViewBuilder: (context, onSelected, options) {
              return Container(
                margin: EdgeInsets.only(top: 8.0),
                child: Card(
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.3,
                    ),
                    width: MediaQuery.of(context).size.width - 32,  // Full width minus padding
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      separatorBuilder: (context, i) => Divider(height: 1),
                      itemBuilder: (BuildContext context, int index) {
                        final option = options.elementAt(index);
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => onSelected(option),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 16.0,  // Increased tap target
                              ),
                              child: Text(
                                option,
                                style: TextStyle(fontSize: 18),  // Increased text size
                              ),
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
