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

  Future<void> _showInteractiveMessage(String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,  // user must tap button to dismiss the message
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Notification'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteStory(int id) async {
    await DatabaseHelper().deleteStory(id);
    refreshStories(); // Refresh the list after deletion
    _showInteractiveMessage('Story deleted successfully');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Stories'),
        backgroundColor: Colors.purple[400], // Adding a more engaging color
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
                    leading: Icon(Icons.book, color: Colors.purple[400], size: 36), // Visually distinct icon
                    title: Text(
                      story['title'],
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.deepPurple),
                    ),
                    subtitle: Text('Tap to read the story', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red, size: 30),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple[400],
        child: Icon(Icons.add, color: Colors.white, size: 36),
        onPressed: () {
          // Action for adding a new story
        },
      ),
    );
  }
}
