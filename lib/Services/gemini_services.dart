import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:quantum/config/api_keys.dart';

class GeminiService {
  late final GenerativeModel _model;
  late final ChatSession _chat;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: ApiKeys.geminiApiKey,
    );
    _chat = _model.startChat(history: []);
  }

  // Send message and get AI response
  Future<String> sendMessage(String message) async {
    try {
      final content = Content.text(message);
      final response = await _chat.sendMessage(content);

      return response.text ?? 'Sorry, I could not generate a response.';
    } catch (e) {
      print('Error sending message to Gemini: $e');
      return 'Sorry, I encountered an error. Please try again.';
    }
  }

  // Send message with real estate context
  Future<String> sendRealEstateQuery(String message) async {
    try {
      // Add context to make AI act as real estate assistant
      final contextualMessage = '''
You are a helpful AI real estate assistant for a Nigerian property app called Quantum.
Your role is to help users find properties, answer questions about real estate, locations, prices, and provide advice.

User question: $message

Please provide a helpful, friendly response focused on Nigerian real estate.
''';

      final content = Content.text(contextualMessage);
      final response = await _model.generateContent([content]);

      return response.text ?? 'Sorry, I could not generate a response.';
    } catch (e) {
      print('Error: $e');
      return 'Sorry, I encountered an error. Please try again.';
    }
  }

  // Clear chat history
  void clearHistory() {
    _chat = _model.startChat(history: []);
  }
}