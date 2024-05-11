import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryScreen extends StatelessWidget {
  Future<List<String>> _getStoryHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('viewedStories') ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your History'),
      ),
      body: FutureBuilder<List<String>>(
        future: _getStoryHistory(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No history found'));
          }

          final List<String> stories = snapshot.data!;

          return ListView.builder(
            itemCount: stories.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(stories[index]),
                onTap: () {
                  // Navigate to the story detail screen if necessary
                  // You will need to pass the appropriate story data
                },
              );
            },
          );
        },
      ),
    );
  }
}
