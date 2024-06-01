import 'package:flutter/material.dart';
import 'GeneratedStoryScreen.dart';
import 'DatabaseHelper.dart';

class SaveStoryScreen extends StatefulWidget {
  @override
  _SaveStoryScreenState createState() => _SaveStoryScreenState();
}

class _SaveStoryScreenState extends State<SaveStoryScreen> {
  late Future<List<Map<String, dynamic>>> savedStories;

  @override
  void initState() {
    super.initState();
    refreshStories();
  }

  void refreshStories() {
    setState(() {
      savedStories = DatabaseHelper().getStories();
    });
  }

  Future<void> deleteStory(int id) async {
    await DatabaseHelper().deleteStory(id);
    refreshStories(); // Refresh the list after deletion
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Story deleted successfully'),
      backgroundColor: Colors.red,
      duration: Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Stories'),
        backgroundColor: Colors.deepPurple, // Adding a more engaging color
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: savedStories,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              return ListView.separated(
                itemCount: snapshot.data!.length,
                separatorBuilder: (context, index) => Divider(color: Colors.grey[300]),
                itemBuilder: (context, index) {
                  var story = snapshot.data![index];
                  List<String> imagePaths = story['imagePaths'].split(',');
                  return ListTile(
                    leading: Icon(Icons.book, color: Colors.deepPurple), // Visually distinct icon
                    title: Text(story['title'], style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Tap to read the story', style: TextStyle(fontSize: 12)),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteStory(story['id']),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GeneratedStoryScreen(
                            initialStoryText: story['storyText'],
                            initialChoices: [], // assuming choices are not needed for now
                            imagePaths: imagePaths, // Pass local paths instead of URLs
                            storyTitle: story['title'],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            } else if (snapshot.hasData && snapshot.data!.isEmpty) {
              return Center(child: Text('No stories saved yet.', style: TextStyle(fontSize: 16, color: Colors.grey)));
            }
          }
          if (snapshot.hasError) {
            return Center(child: Text('Failed to load stories: ${snapshot.error}', style: TextStyle(color: Colors.red)));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
