import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class AIMessagesNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  AIMessagesNotifier() : super([]) {
    // Add welcome message
    state = [
      {
        'text': 'Hello! I\'m your AI Real Estate Assistant. How can I help you today?\n\nI can help you with:\n• Finding properties\n• Price estimates\n• Neighborhood information\n• Property recommendations',
        'isUser': false,
        'time': TimeOfDay.now(),
      }
    ];
  }

  void addMessage(String text, bool isUser) {
    state = [
      ...state,
      {
        'text': text,
        'isUser': isUser,
        'time': TimeOfDay.now(),
      }
    ];
  }

  String getAIResponse(String userMessage) {
    final message = userMessage.toLowerCase();

    if (message.contains('price') || message.contains('cost')) {
      return 'Property prices vary by location. In Lagos, apartments range from ₦15M-₦50M, while in Abuja they range from ₦20M-₦60M. Would you like specific information about a particular area?';
    } else if (message.contains('recommend') || message.contains('suggest')) {
      return 'Based on popular demand, I recommend checking out:\n• Lekki Phase 1 - Modern apartments\n• Victoria Island - Luxury condos\n• Ikoyi - Premium houses\n\nWhat\'s your budget range?';
    } else if (message.contains('location') || message.contains('area')) {
      return 'Popular areas include:\n• Lagos: Lekki, VI, Ikoyi\n• Abuja: Maitama, Asokoro, Wuse 2\n• Ibadan: Bodija, Ring Road\n\nWhich city interests you?';
    } else if (message.contains('bedroom') || message.contains('bed')) {
      return 'We have properties ranging from studios to 5-bedroom houses. What size are you looking for and in which location?';
    } else {
      return 'I understand you\'re interested in real estate. Could you please provide more details about what you\'re looking for? For example:\n• Your budget\n• Preferred location\n• Number of bedrooms\n• Property type (apartment, house, etc.)';
    }
  }
}

final aiMessagesProvider = StateNotifierProvider<AIMessagesNotifier, List<Map<String, dynamic>>>((ref) {
  return AIMessagesNotifier();
});