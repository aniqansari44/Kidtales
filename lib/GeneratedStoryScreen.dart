import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'DatabaseHelper.dart'; // Ensure you have this import for the DatabaseHelper

class GeneratedStoryScreen extends StatefulWidget {
  final String initialStoryText;
  final List<String> initialChoices;
  final List<String> imagesURLs;  // List of URLs for images
  final String storyTitle;  // Title of the story

  GeneratedStoryScreen({
    Key? key,
    required this.initialStoryText,
    required this.initialChoices,
    required this.imagesURLs,
    required this.storyTitle,
  }) : super(key: key);

  @override
  _GeneratedStoryScreenState createState() => _GeneratedStoryScreenState();
}

class _GeneratedStoryScreenState extends State<GeneratedStoryScreen> {
  final FlutterTts flutterTts = FlutterTts();
  bool isPlaying = false;
  int wordIndex = 0;
  List<String> words = [];

  @override
  void initState() {
    super.initState();
    words = widget.initialStoryText.split(' ');
    flutterTts.setProgressHandler((String text, int startOffset, int endOffset, String word) {
      setState(() {
        wordIndex = words.indexOf(word, wordIndex);
      });
    });
    flutterTts.setCompletionHandler(() {
      setState(() {
        isPlaying = false;
        wordIndex = 0;  // Reset word index when speech completes
      });
    });
  }

  Future<void> _speak() async {
    if (!isPlaying) {
      await flutterTts.speak(widget.initialStoryText);
      setState(() {
        isPlaying = true;
      });
    } else {
      await flutterTts.stop();
      setState(() {
        isPlaying = false;
        wordIndex = 0;  // Reset word index when stopped manually
      });
    }
  }

  Future<void> _saveStory() async {
    int id = await DatabaseHelper().saveStory(widget.storyTitle, widget.initialStoryText, widget.imagesURLs);
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(id != 0 ? 'Story saved successfully' : 'Failed to save the story'))
    );
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.storyTitle),  // Use the story title
        backgroundColor: Colors.purple[400],
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.download),
            onPressed: _saveStory,
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: CarouselSlider(
              options: CarouselOptions(
                autoPlay: true,
                enlargeCenterPage: true,
                viewportFraction: 1.0,
                aspectRatio: 1.0,
                autoPlayCurve: Curves.fastOutSlowIn,
                enableInfiniteScroll: true,
                autoPlayAnimationDuration: Duration(milliseconds: 800),
                autoPlayInterval: Duration(seconds: 3),
              ),
              items: widget.imagesURLs.map((item) => Center(
                  child: Image.network(item, fit: BoxFit.cover, width: MediaQuery.of(context).size.width)
              )).toList(),
            ),
          ),
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 18, color: Colors.black, fontFamily: 'Chilanka'),
                  children: List<TextSpan>.generate(words.length, (index) {
                    return TextSpan(
                      text: words[index] + ' ',
                      style: TextStyle(
                        backgroundColor: index == wordIndex ? Colors.yellow : Colors.transparent,
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow, size: 24),
                  label: Text(isPlaying ? 'Stop' : 'Play'),
                  onPressed: _speak,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,  // Previously 'primary'
                    foregroundColor: Colors.white,  // Previously 'onPrimary'
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
