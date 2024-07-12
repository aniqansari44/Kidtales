import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'GeneratedStoryScreen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

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
  List<String> _imagesPaths = []; // To store local paths of generated images
  List<String> _restrictedWords = ['Kiss', 'Romance', 'Sex']; // Add your restricted words here

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

  Future<void> _saveSearchHistory(String searchText) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> searchHistory = prefs.getStringList('searchHistory') ?? [];
    searchHistory.add(searchText);
    await prefs.setStringList('searchHistory', searchHistory);
  }

  bool _containsRestrictedWords(String input) {
    for (String word in _restrictedWords) {
      if (input.toLowerCase().contains(word.toLowerCase())) {
        return true;
      }
    }
    return false;
  }

  Future<void> _generateContent() async {
    final String storyPrompt = _storyPromptController.text;

    if (_containsRestrictedWords(storyPrompt)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Your input contains restricted words. Please modify your input and try again.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final String apiKey = dotenv.get('API_KEY');  // Get API key from .env
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

    final String fullStoryPrompt = "Generate a detailed story suitable for children aged $ageRestriction+ "
        "about $storyPrompt. Include genres such as ${selectedGenres.join(', ')}, "
        "with a word limit of $wordLimit, in language $_selectedLanguage "
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
          'prompt': fullStoryPrompt,
          'max_tokens': 800,
          'temperature': 0.7,
        }),
      );

      if (textResponse.statusCode == 200) {
        final data = json.decode(textResponse.body);
        final fullStory = data['choices'][0]['text'].trim();
        List<String> paragraphs = _splitIntoParagraphs(fullStory, 4);

        _imagesPaths.clear(); // Clear existing paths

        for (String paragraph in paragraphs) {
          final imageResponse = await http.post(
            imageUri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $apiKey',
            },
            body: jsonEncode({
              'model': 'dall-e-3',  // Use DALL-E 3 for image generation
              'prompt': "generate an animated-style image for " + storyPrompt + " and do not include any text in the pictures they should be clear ",
              'n': 1,
              'size': '1024x1024'
            }),
          );

          if (imageResponse.statusCode == 200) {
            final imageData = json.decode(imageResponse.body);
            String imageUrl = imageData['data'][0]['url'];
            File imageFile = await _downloadAndSaveImage(imageUrl, 'image_${Uuid().v4()}.png');
            _imagesPaths.add(imageFile.path);
          }
        }

        // Save search text to history
        await _saveSearchHistory(storyPrompt);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GeneratedStoryScreen(
              initialStoryText: fullStory,
              initialChoices: ['Restart', 'New Story'],
              imagePaths: _imagesPaths,
              storyTitle: storyPrompt, // Pass the story title
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

  Future<File> _downloadAndSaveImage(String url, String filename) async {
    var response = await http.get(Uri.parse(url));
    Directory directory = await getApplicationDocumentsDirectory();
    String filePath = path.join(directory.path, filename);
    File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return file;
  }

  List<String> _splitIntoParagraphs(String text, int count) {
    List<String> paragraphs = text.split(RegExp(r"\.\s+")).toList();
    return paragraphs.sublist(0, min(count, paragraphs.length)); // Ensure only required number of paragraphs are taken.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Generate Story and Images', style: TextStyle(fontFamily: 'ComicSans', fontSize: 24)),
        backgroundColor: Colors.purple[400],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _storyPromptController,
              decoration: InputDecoration(
                labelText: 'Story Prompt',
                labelStyle: TextStyle(fontFamily: 'ComicSans', fontSize: 18, color: Colors.blue),
                hintText: 'What is your story about?',
                hintStyle: TextStyle(fontFamily: 'ComicSans', fontSize: 16, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                suffixIcon: IconButton(
                  icon: Icon(_isListening ? Icons.mic_off : Icons.mic, color: Colors.blue),
                  onPressed: _listen,
                ),
              ),
              maxLines: null,
              style: TextStyle(fontFamily: 'ComicSans', fontSize: 16, color: Colors.black),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedGenre,
              items: _availableGenres.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: TextStyle(fontFamily: 'ComicSans', fontSize: 16)),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Genre',
                labelStyle: TextStyle(fontFamily: 'ComicSans', fontSize: 18, color: Colors.blue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
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
                  child: Text(value, style: TextStyle(fontFamily: 'ComicSans', fontSize: 16)),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Language',
                labelStyle: TextStyle(fontFamily: 'ComicSans', fontSize: 18, color: Colors.blue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
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
              child: _isLoading ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ) : Text(
                'Generate Story',
                style: TextStyle(fontSize: 18, fontFamily: 'ComicSans'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[400],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            if (_isLoading) // Show loading message when content is being generated
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  'Generating story, please wait...',
                  style: TextStyle(fontSize: 16, color: Colors.grey, fontFamily: 'ComicSans'),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _listen,
        backgroundColor: Colors.blueAccent,
        child: Icon(_isListening ? Icons.mic_off : Icons.mic, color: Colors.white),
      ),
    );
  }
}
