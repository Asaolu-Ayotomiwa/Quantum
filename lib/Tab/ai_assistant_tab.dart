import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quantum/Bubbles/ai_message_bubble.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:quantum/Services/gemini_services.dart';

class AIMessageNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  final GeminiService _geminiService = GeminiService();
  bool _isLoading = false;

  AIMessageNotifier() : super([]);

  bool get isLoading => _isLoading;

  void addMessage(String text, bool isUser) {
    state = [
      ...state,
      {'text': text, 'isUser': isUser, 'time': TimeOfDay.now()},
    ];
  }

  Future<void> sendMessageToAI(String userMessage) async {
    // Add user message
    addMessage(userMessage, true);

    // Set loading state
    _isLoading = true;

    // Add typing indicator
    addMessage('...', false);

    try {
      // Get AI response
      final aiResponse = await _geminiService.sendRealEstateQuery(userMessage);

      // Remove typing indicator
      state = state.where((msg) => msg['text'] != '...').toList();

      // Add AI response
      addMessage(aiResponse, false);
    } catch (e) {
      // Remove typing indicator
      state = state.where((msg) => msg['text'] != '...').toList();

      // Add error message
      addMessage(
        'Sorry, I encountered an error. Please try again.',
        false,
      );
    } finally {
      _isLoading = false;
    }
  }

  void clearMessages() {
    state = [];
    _geminiService.clearHistory();
  }
}

  String getAIResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();

    // Basic AI responses for real estate queries
    if (lowerMessage.contains('property') || lowerMessage.contains('house')) {
      return "I can help you find properties! What type of property are you looking for? Apartment, Villa, or House?";
    } else if (lowerMessage.contains('price') || lowerMessage.contains('cost')) {
      return "Property prices vary by location and type. What's your budget range?";
    } else if (lowerMessage.contains('location') || lowerMessage.contains('where')) {
      return "We have properties in Lagos, Abuja, Port Harcourt, and Ibadan. Which city interests you?";
    } else if (lowerMessage.contains('bedroom') || lowerMessage.contains('bed')) {
      return "How many bedrooms are you looking for? We have options from 1 to 5+ bedrooms.";
    } else if (lowerMessage.contains('hello') || lowerMessage.contains('hi')) {
      return "Hello! I'm your AI real estate assistant. How can I help you find your dream home today?";
    } else if (lowerMessage.contains('thank')) {
      return "You're welcome! Feel free to ask me anything about properties.";
    } else {
      return "I'm here to help you find the perfect property! You can ask me about prices, locations, property types, or any other real estate questions.";
    }
  }

  void clearMessages() {
    state = [];
  }
}

// Provider
final aiMessagesProvider =
StateNotifierProvider<AIMessageNotifier, List<Map<String, dynamic>>>(
      (ref) => AIMessageNotifier(),
);

// ==================== AI ASSISTANT TAB ====================
class AIAssistantTab extends ConsumerStatefulWidget {
  const AIAssistantTab({super.key});

  @override
  ConsumerState<AIAssistantTab> createState() => _AIAssistantTabState();
}

class _AIAssistantTabState extends ConsumerState<AIAssistantTab> {
  late final TextEditingController messageController;
  bool _chatStarted = false;

  @override
  void initState() {
    super.initState();
    messageController = TextEditingController();
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  void startChat() {
    setState(() {
      _chatStarted = true;
    });
    // Add welcome message
    ref.read(aiMessagesProvider.notifier).addMessage(
      "Hello! I'm your AI real estate assistant. I can help you find properties, answer questions about locations, prices, and more. How can I assist you today?",
      false,
    );
  }

  void sendMessage() {
    if (messageController.text.trim().isEmpty) return;

    final userMessage = messageController.text.trim();

    // Add user message
    ref.read(aiMessagesProvider.notifier).addMessage(userMessage, true);

    // Get AI response after a delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        final aiResponse =
        ref.read(aiMessagesProvider.notifier).getAIResponse(userMessage);
        ref.read(aiMessagesProvider.notifier).addMessage(aiResponse, false);
      }
    });

    messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(aiMessagesProvider);

    // Show welcome screen if chat not started
    if (!_chatStarted) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // AI Icon
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 80,
                  color: Colors.green,
                ),
              ),

              const SizedBox(height: 30),

              // Title
              const Text(
                'AI Real Estate Assistant',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Description
              Text(
                'Get instant help finding properties, asking about locations, prices, amenities, and more. Your smart real estate companion!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 40),

              // Features
              _buildFeatureItem(
                Icons.search_rounded,
                'Find Properties',
                'Search by location, price, and type',
              ),
              const SizedBox(height: 16),
              _buildFeatureItem(
                Icons.info_outline_rounded,
                'Get Instant Answers',
                'Ask anything about real estate',
              ),
              const SizedBox(height: 16),
              _buildFeatureItem(
                Icons.location_on_rounded,
                'Location Info',
                'Learn about different areas',
              ),

              const SizedBox(height: 40),

              // Start Button
              ElevatedButton.icon(
                onPressed: startChat,
                icon: const Icon(Icons.chat_rounded),
                label: const Text(
                  'Start Conversation',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 2,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show chat interface
    return Column(
      children: [
        // Chat Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.green.withOpacity(0.2),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Assistant',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Online',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.delete_outline),
                            title: const Text('Clear Chat'),
                            onTap: () {
                              ref
                                  .read(aiMessagesProvider.notifier)
                                  .clearMessages();
                              Navigator.pop(context);
                              setState(() {
                                _chatStarted = false;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        // Messages List
        Expanded(
          child: messages.isEmpty
              ? Center(
            child: Text(
              'No messages yet',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              return AIMessageBubble(
                text: message['text'],
                isUser: message['isUser'],
                time: message['time'],
              );
            },
          ),
        ),

        // Input Field
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 5,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: messageController,
                  decoration: InputDecoration(
                    hintText: 'Ask me about properties...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => sendMessage(),
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
              const SizedBox(width: 10),
              CircleAvatar(
                backgroundColor: Colors.green,
                radius: 24,
                child: IconButton(
                  icon: const Icon(Icons.send_rounded, color: Colors.white),
                  onPressed: sendMessage,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Feature Item Widget
  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.green, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
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