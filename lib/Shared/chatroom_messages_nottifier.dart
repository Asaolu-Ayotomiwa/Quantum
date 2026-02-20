import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quantum/Bubbles/message_bubble.dart';

class ChatRoomMessagesNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  ChatRoomMessagesNotifier() : super([
    {
      'text': 'Hi! I saw your listing for the property in Lekki',
      'isUser': false,
      'time': TimeOfDay.now(),
    },
    {
      'text': 'Yes, it\'s still available. Would you like to schedule a viewing?',
      'isUser': true,
      'time': TimeOfDay.now(),
    },
  ]);

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
}

final chatRoomMessagesProvider = StateNotifierProvider<ChatRoomMessagesNotifier, List<Map<String, dynamic>>>((ref) {
  return ChatRoomMessagesNotifier();
});

// Individual Chat Room Screen
class ChatRoomScreen extends ConsumerWidget {
  final String chatName;

  const ChatRoomScreen({super.key, required this.chatName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(chatRoomMessagesProvider);
    final TextEditingController messageController = TextEditingController();

    void sendMessage() {
      if (messageController.text.trim().isEmpty) return;

      ref.read(chatRoomMessagesProvider.notifier).addMessage(
        messageController.text,
        true,
      );
      messageController.clear();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        title: Text(chatName),
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return MessageBubble(
                  text: message['text'],
                  isUser: message['isUser'],
                  time: message['time'],
                );
              },
            ),
          ),
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
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: (_) => sendMessage(),
                  ),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: Colors.green,
                  radius: 24,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: sendMessage,
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