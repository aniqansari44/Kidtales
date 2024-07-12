import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_tts/flutter_tts.dart';
import 'StoryDetailScreen.dart'; // Ensure this import is correct

class StoriesDisplayScreen extends StatefulWidget {
  final String genre;

  StoriesDisplayScreen({Key? key, required this.genre}) : super(key: key);

  @override
  _StoriesDisplayScreenState createState() => _StoriesDisplayScreenState();
}

class _StoriesDisplayScreenState extends State<StoriesDisplayScreen> {
  List<dynamic> _stories = [];
  final FlutterTts flutterTts = FlutterTts();
  String currentPlayingStory = '';
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _loadStories();
    flutterTts.setCompletionHandler(() {
      setState(() {
        isPlaying = false;
        currentPlayingStory = '';
      });
    });
  }

  Future<void> _speak(String story, String storyId) async {
    if (currentPlayingStory != storyId || !isPlaying) {
      await flutterTts.speak(story);
      setState(() {
        isPlaying = true;
        currentPlayingStory = storyId;
      });
    } else {
      await flutterTts.stop();
      setState(() {
        isPlaying = false;
        currentPlayingStory = '';
      });
    }
  }

  Future<void> _pause() async {
    await flutterTts.pause();
    setState(() {
      isPlaying = false;
    });
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  Future<void> _loadStories() async {
    String data = await rootBundle.loadString('assets/fyp_stories.json');
    final List<dynamic> jsonResult = json.decode(data);
    setState(() {
      _stories = jsonResult.where((story) => story['Genre'] == widget.genre).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stories in ${widget.genre}', style: TextStyle(fontFamily: 'ComicSans', fontSize: 24, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.purple[400],
      ),
      body: ListView.builder(
        itemCount: _stories.length,
        itemBuilder: (context, index) {
          var story = _stories[index];
          String storyId = '${story['Name']}-${index}';
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 5,
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: ListTile(
              contentPadding: EdgeInsets.all(10),
              title: Text(
                story['Name'],
                style: TextStyle(fontFamily: 'ComicSans', fontSize: 20, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Age: ${story['Age']} - Genre: ${story['Genre']}',
                style: TextStyle(fontFamily: 'ComicSans', fontSize: 16),
              ),
              trailing: Wrap(
                spacing: 12, // space between two icons
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      currentPlayingStory == storyId && isPlaying ? Icons.stop : Icons.play_arrow,
                      color: Colors.purple[400],
                    ),
                    onPressed: () => _speak(story['Story'], storyId),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.info_outline,
                      color: Colors.purple[400],
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StoryDetailScreen(story: story),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
