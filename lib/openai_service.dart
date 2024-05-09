import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  static const String _apiKey = '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'; // Place your OpenAI API Key here
  static const String _apiUrl = 'https://api.openai.com/v1/completions';

  Future<String> generateStory(String prompt) async {
    final uri = Uri.parse(_apiUrl);
    final response = await http.post(uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': 'text-davinci-002', // Choose the model you want to use
        'prompt': prompt,
        'max_tokens': 100,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['choices'][0]['text'];
    } else {
      throw Exception('Failed to generate story: ${response.body}');
    }
  }
}
