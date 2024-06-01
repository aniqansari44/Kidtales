import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoryDetailScreen extends StatefulWidget {
  final Map<String, dynamic> story;

  StoryDetailScreen({Key? key, required this.story}) : super(key: key);

  @override
  _StoryDetailScreenState createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  final FlutterTts flutterTts = FlutterTts();
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _saveStoryToHistory(widget.story['Name']);
    flutterTts.setCompletionHandler(() {
      setState(() {
        isPlaying = false;
      });
    });
  }

  Future<void> _saveStoryToHistory(String storyTitle) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('viewedStories') ?? [];
    if (!history.contains(storyTitle)) {
      history.add(storyTitle);
      await prefs.setStringList('viewedStories', history);
    }
  }

  Future<void> _speak() async {
    if (!isPlaying) {
      await flutterTts.speak(widget.story['Story']);
      setState(() {
        isPlaying = true;
      });
    } else {
      await flutterTts.stop();
      setState(() {
        isPlaying = false;
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

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.story['Name'], style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.story['Story'],
                style: TextStyle(fontSize: 18.0, height: 1.5),
              ),
              SizedBox(height: 20),
              // Display additional story details (e.g., hero and villain names) if needed here
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
                    label: Text(isPlaying ? 'Stop' : 'Play'),
                    onPressed: _speak,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPlaying ? Colors.redAccent : theme.primaryColor,  // Changed from 'primary'
                      foregroundColor: Colors.black,  // Changed from 'onPrimary'
                      textStyle: TextStyle(fontWeight: FontWeight.bold),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: Icon(Icons.pause),
                    label: Text('Pause'),
                    onPressed: isPlaying ? _pause : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,  // Changed from 'primary'
                      foregroundColor: Colors.white,  // Changed from 'onPrimary'
                      textStyle: TextStyle(fontWeight: FontWeight.bold),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}