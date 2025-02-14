import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../config.dart';

class GuessInputWidget extends StatefulWidget {
  final Function(String) onSubmit;

  GuessInputWidget({required this.onSubmit});

  @override
  _GuessInputWidgetState createState() => _GuessInputWidgetState();
}

class _GuessInputWidgetState extends State<GuessInputWidget> {
  final _dio = Dio(BaseOptions(
    baseUrl: Config.apiUrl,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
  ));

  List<String> _suggestions = [];
  late TextEditingController _controller;
  String? _selectedCountry;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

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
      _removeOverlay();
      setState(() {
        _suggestions = [];
        _selectedCountry = null;
      });
    }
  }

  void _showOverlay(BuildContext context) {
    _removeOverlay();
    final overlay = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          width: MediaQuery.of(context).size.width - 32,
          child: CompositedTransformFollower(
            link: _layerLink,
            offset: Offset(0, 50),
            child: Material(
              elevation: 4.0,
              borderRadius: BorderRadius.circular(8),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.3,
                ),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      title: Text(_suggestions[index], style: TextStyle(fontSize: 14)),
                      onTap: () {
                        _controller.text = _suggestions[index];
                        _selectedCountry = _suggestions[index];
                        _removeOverlay();
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        reverse: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: bottomInset > 0 ? bottomInset + 8 : 8),
              child: CompositedTransformTarget(
                link: _layerLink,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Enter a country here',
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
                        onChanged: (value) {
                          _getSuggestions(value).then((_) {
                            if (_suggestions.isNotEmpty) {
                              _showOverlay(context);
                            } else {
                              _removeOverlay();
                            }
                          });
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
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _removeOverlay();
    _controller.dispose();
    super.dispose();
  }
}
