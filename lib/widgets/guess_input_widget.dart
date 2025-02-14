import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../config.dart';  // Add this import

class GuessInputWidget extends StatefulWidget {
  final Function(String) onSubmit;

  GuessInputWidget({required this.onSubmit});

  @override
  _GuessInputWidgetState createState() => _GuessInputWidgetState();
}

class _GuessInputWidgetState extends State<GuessInputWidget> {
  final _dio = Dio(BaseOptions(
    baseUrl: Config.apiUrl,  // Use Config instead of hardcoded URL
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),  // Added receive timeout
  ));
  
  List<String> _suggestions = [];
  late TextEditingController _controller;
  String? _selectedCountry;  // Add this variable to track selection

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  // Modified _getSuggestions to limit suggestions to 2
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
        if (!_suggestions.contains(_selectedCountry)) {
          _selectedCountry = null;
        }
      });
      return _suggestions.take(2).toList();
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
    // Get keyboard height to adjust positioning
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: bottomInset > 0 ? bottomInset + 8 : 8),
            child: Row(
              children: [
                Expanded(
                  child: Autocomplete<String>(
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
                          hintText: 'Enter a country name!',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).cardColor,
                        ),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.text,
                        autocorrect: false,
                        enableSuggestions: true,
                      );
                    },
                    optionsViewBuilder: (context, onSelected, options) {
                      final bottomInset = MediaQuery.of(context).viewInsets.bottom;
                      // Wrap suggestions list in Padding with extra bottom padding to keep it above the keyboard.
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: EdgeInsets.only(bottom: bottomInset + 16),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: MediaQuery.of(context).size.height * 0.3,
                                maxWidth: MediaQuery.of(context).size.width - 32,
                              ),
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: options.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final option = options.elementAt(index);
                                  return ListTile(
                                    dense: true,  // Make items more compact
                                    visualDensity: VisualDensity.compact,
                                    title: Text(
                                      option,
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    onTap: () => onSelected(option),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _submitGuess(_controller.text),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Guess!',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
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
