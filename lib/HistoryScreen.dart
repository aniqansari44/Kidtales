import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late List<String> _storyHistory;

  @override
  void initState() {
    super.initState();
    _loadStoryHistory();
  }

  Future<void> _loadStoryHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _storyHistory = prefs.getStringList('viewedStories') ?? [];
    });
  }

  Future<void> _deleteStory(int index) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _storyHistory.removeAt(index);
      prefs.setStringList('viewedStories', _storyHistory);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your History'),
      ),
      body: _storyHistory.isEmpty
          ? Center(child: Text('No history found'))
          : ListView.builder(
        itemCount: _storyHistory.length,
        itemBuilder: (context, index) {
          final String story = _storyHistory[index];
          return ListTile(
            title: Text(story),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _deleteStory(index),
            ),
            onTap: () {
              // Navigate to the story detail screen if necessary
              // You will need to pass the appropriate story data
            },
          );
        },
      ),
    );
  }
}
