import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class MedicalSearchBar extends StatefulWidget {
  final Function(String, String) onSearch;

  const MedicalSearchBar({Key? key, required this.onSearch}) : super(key: key);

  @override
  _MedicalSearchBarState createState() => _MedicalSearchBarState();
}

class _MedicalSearchBarState extends State<MedicalSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  String _searchType = 'name'; // Default search type
  String _selectedAISuggestion = '';
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        // Fetch AI suggestion when the search bar is focused
        _getAISuggestion();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _getAISuggestion() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    // This is a placeholder for a real AI suggestion based on user's location or context
    // For now, we'll just use a default suggestion.
    final suggestion = await userProvider.getAILocationSuggestion();
    setState(() {
      _selectedAISuggestion = suggestion;
    });
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      widget.onSearch(query, _searchType);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: 'Search for medical facilities...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onSubmitted: (_) => _performSearch(),
              ),
            ),
            const SizedBox(width: 8),
            DropdownButton<String>(
              value: _searchType,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _searchType = newValue;
                  });
                }
              },
              items: <String>['name', 'pincode', 'location']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value[0].toUpperCase() + value.substring(1)),
                );
              }).toList(),
            ),
          ],
        ),
        if (_focusNode.hasFocus && _selectedAISuggestion.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _searchController.text = _selectedAISuggestion;
                  _searchType = 'location'; // Assume AI suggestion is a location
                  _performSearch();
                  _focusNode.unfocus();
                });
              },
              child: Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_selectedAISuggestion)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
