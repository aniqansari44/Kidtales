import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ParentalControlScreen extends StatefulWidget {
  @override
  _ParentalControlScreenState createState() => _ParentalControlScreenState();
}

class _ParentalControlScreenState extends State<ParentalControlScreen> {
  double _ageRestriction = 7.0;
  List<String> _selectedGenres = [];
  int _wordLimit = 1000;
  List<String> _allowedLanguages = [];
  String _customKeywords = '';
  double _dailyTimeLimit = 1.0;
  double _difficultyLevel = 1.0;
  List<String> _searchHistory = [];
  List<bool> _selectedHistory = [];
  final List<String> _genres = ['Adventure', 'Folk Tale', 'Fiction', 'Educational', 'Mystery'];
  final List<String> _languages = ['English', 'Urdu', 'French'];

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadSearchHistory();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _ageRestriction = prefs.getDouble('ageRestriction') ?? 7.0;
      _selectedGenres = prefs.getStringList('selectedGenres') ?? [];
      _wordLimit = prefs.getInt('wordLimit') ?? 1000;
      _allowedLanguages = prefs.getStringList('allowedLanguages') ?? [];
      _customKeywords = prefs.getString('customKeywords') ?? '';
      _dailyTimeLimit = prefs.getDouble('dailyTimeLimit') ?? 1.0;
      _difficultyLevel = prefs.getDouble('difficultyLevel') ?? 1.0;
    });
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory = prefs.getStringList('searchHistory') ?? [];
      _selectedHistory = List<bool>.filled(_searchHistory.length, false);
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('ageRestriction', _ageRestriction);
    await prefs.setStringList('selectedGenres', _selectedGenres);
    await prefs.setInt('wordLimit', _wordLimit);
    await prefs.setStringList('allowedLanguages', _allowedLanguages);
    await prefs.setString('customKeywords', _customKeywords);
    await prefs.setDouble('dailyTimeLimit', _dailyTimeLimit);
    await prefs.setDouble('difficultyLevel', _difficultyLevel);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Settings saved successfully!')));
  }

  Future<void> _deleteSelectedHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> updatedHistory = [];
    for (int i = 0; i < _searchHistory.length; i++) {
      if (!_selectedHistory[i]) {
        updatedHistory.add(_searchHistory[i]);
      }
    }
    setState(() {
      _searchHistory = updatedHistory;
      _selectedHistory = List<bool>.filled(_searchHistory.length, false);
    });
    await prefs.setStringList('searchHistory', updatedHistory);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Selected history items deleted successfully!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Parental Controls'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveSettings,
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _deleteSelectedHistory,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Age Restriction', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Slider(
              min: 3,
              max: 11,
              divisions: 15,
              label: _ageRestriction.round().toString(),
              value: _ageRestriction,
              onChanged: (value) {
                setState(() => _ageRestriction = value);
              },
            ),
            Text('Select Genres', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 10,
              children: _genres.map((genre) => FilterChip(
                label: Text(genre),
                selected: _selectedGenres.contains(genre),
                onSelected: (bool selected) {
                  setState(() {
                    if (selected) {
                      _selectedGenres.add(genre);
                    } else {
                      _selectedGenres.removeWhere((String name) => name == genre);
                    }
                  });
                },
              )).toList(),
            ),
            SizedBox(height: 20),
            Text('Word Limit', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Slider(
              min: 100,
              max: 5000,
              divisions: 49,
              label: _wordLimit.toString(),
              value: _wordLimit.toDouble(),
              onChanged: (value) {
                setState(() => _wordLimit = value.toInt());
              },
            ),
            SizedBox(height: 20),
            Text('Allowed Languages', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 10,
              children: _languages.map((language) => FilterChip(
                label: Text(language),
                selected: _allowedLanguages.contains(language),
                onSelected: (bool selected) {
                  setState(() {
                    if (selected) {
                      _allowedLanguages.add(language);
                    } else {
                      _allowedLanguages.removeWhere((String name) => name == language);
                    }
                  });
                },
              )).toList(),
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'Custom Keywords to Filter',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _customKeywords = value,
            ),
            SizedBox(height: 20),
            Text('Daily Time Limit (hours)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Slider(
              min: 0,
              max: 5,
              divisions: 10,
              label: _dailyTimeLimit.toString(),
              value: _dailyTimeLimit,
              onChanged: (value) {
                setState(() => _dailyTimeLimit = value);
              },
            ),
            SizedBox(height: 20),
            Text('Difficulty Level', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Slider(
              min: 1,
              max: 3,
              divisions: 2,
              label: _difficultyLevel.toString(),
              value: _difficultyLevel,
              onChanged: (value) {
                setState(() => _difficultyLevel = value);
              },
            ),
            SizedBox(height: 20),
            Text('Search History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            _searchHistory.isEmpty
                ? Text('No search history available.')
                : Column(
              children: List.generate(_searchHistory.length, (index) {
                return CheckboxListTile(
                  title: Text(_searchHistory[index]),
                  value: _selectedHistory[index],
                  onChanged: (bool? value) {
                    setState(() {
                      _selectedHistory[index] = value!;
                    });
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
