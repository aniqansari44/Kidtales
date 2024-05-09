import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'GeneratedStoryScreen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:shared_preferences/shared_preferences.dart';

class InputScreen extends StatefulWidget {
  @override
  _InputScreenState createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final TextEditingController _storyPromptController = TextEditingController();
  stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _selectedGenre = 'Adventure';
  List<String> _availableGenres = ['Adventure', 'Folk Tale', 'Fiction', 'Educational', 'Mystery'];
  String _selectedLanguage = 'English';
  List<String> _availableLanguages = ['English', 'Urdu', 'French'];
  bool _isLoading = false;
  List<String> _imagesURLs = []; // To store URLs of generated images

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _loadParentalControls();
  }

  void _loadParentalControls() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _availableGenres = prefs.getStringList('selectedGenres') ?? _availableGenres;
      _selectedGenre = _availableGenres.isNotEmpty ? _availableGenres.first : 'Adventure';
      _availableLanguages = prefs.getStringList('allowedLanguages') ?? _availableLanguages;
      _selectedLanguage = _availableLanguages.isNotEmpty ? _availableLanguages.first : 'English';
    });
  }

  Future<void> _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _storyPromptController.text = val.recognizedWords;
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  void dispose() {
    _speech.stop();
    _storyPromptController.dispose();
    super.dispose();
  }

  Future<void> _generateContent() async {
    setState(() => _isLoading = true);
    final String apiKey = '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';
    final Uri textUri = Uri.parse('https://api.openai.com/v1/completions');
    final Uri imageUri = Uri.parse('https://api.openai.com/v1/images/generations');

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final double ageRestriction = prefs.getDouble('ageRestriction') ?? 7.0;
    final List<String> selectedGenres = prefs.getStringList('selectedGenres') ?? [];
    final int wordLimit = prefs.getInt('wordLimit') ?? 1000;
    final List<String> allowedLanguages = prefs.getStringList('allowedLanguages') ?? [];
    final String customKeywords = prefs.getString('customKeywords') ?? '';
    final double dailyTimeLimit = prefs.getDouble('dailyTimeLimit') ?? 1.0;
    final double difficultyLevel = prefs.getDouble('difficultyLevel') ?? 1.0;

    final String storyPrompt = "Generate a detailed story suitable for children aged $ageRestriction+ "
        "about ${_storyPromptController.text}. Include genres such as ${selectedGenres.join(', ')}, "
        "with a word limit of $wordLimit, in languages like ${allowedLanguages.join(', ')}. "
        "Exclude custom keywords: $customKeywords. The content should fit within a daily reading time of $dailyTimeLimit hours "
        "and be at a difficulty level of $difficultyLevel.";

    try {
      final textResponse = await http.post(
        textUri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo-instruct',
          'prompt': storyPrompt,
          'max_tokens': 800,
          'temperature': 0.7,
        }),
      );

      if (textResponse.statusCode == 200) {
        final data = json.decode(textResponse.body);
        final fullStory = data['choices'][0]['text'].trim();
        List<String> paragraphs = _splitIntoParagraphs(fullStory, 4);

        _imagesURLs.clear(); // Clear existing URLs

        for (String paragraph in paragraphs) {
          final imageResponse = await http.post(
            imageUri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $apiKey',
            },
            body: jsonEncode({
              'model': 'dall-e-2',  // Use DALL-E 2 for image generation
              'prompt': "generate an animated-style image for " + _storyPromptController.text + " and do not include any text in the pictures they should be clear ",
              'n': 1,
              'size': '1024x1024'
            }),
          );

          if (imageResponse.statusCode == 200) {
            final imageData = json.decode(imageResponse.body);
            _imagesURLs.add(imageData['data'][0]['url']);
          }
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GeneratedStoryScreen(
              initialStoryText: fullStory,
              initialChoices: ['Restart', 'New Story'],
              imagesURLs: _imagesURLs,
              storyTitle: _storyPromptController.text, // Pass the story title
            ),
          ),
        );
      } else {
        print("Error generating story: ${textResponse.body}");
      }
    } catch (e) {
      print('Exception caught: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to generate story and images.")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<String> _splitIntoParagraphs(String text, int count) {
    List<String> paragraphs = text.split(RegExp(r"\.\s+")).toList();
    return paragraphs.sublist(0, min(count, paragraphs.length)); // Ensure only required number of paragraphs are taken.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Generate Story and Images'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _storyPromptController,
              decoration: InputDecoration(
                labelText: 'Story Prompt',
                hintText: 'What is your story about?',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
                  onPressed: _listen,
                ),
              ),
              maxLines: null,
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedGenre,
              items: _availableGenres.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Genre',
                border: OutlineInputBorder(),
              ),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() => _selectedGenre = newValue);
                }
              },
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedLanguage,
              items: _availableLanguages.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Language',
                border: OutlineInputBorder(),
              ),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() => _selectedLanguage = newValue);
                }
              },
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _generateContent,
              child: Text(
                'Generate Story',
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.deepPurple,
                onPrimary: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _listen,
        child: Icon(_isListening ? Icons.mic_off : Icons.mic),
      ),
    );
  }
}
