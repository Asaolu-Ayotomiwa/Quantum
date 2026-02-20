import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quantum/Screens/user_search_screen.dart';
import 'package:quantum/Tab/chatroom_tab_realtime.dart';
import 'package:quantum/Tab/ai_assistant_tab.dart';
import '../Helper/helper_function.dart' show buildTabItem;

// State provider for selected tab
final messagesTabProvider = StateProvider<int>((ref) => 0);

class MessagesScreenComplete extends ConsumerWidget {
  const MessagesScreenComplete({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch which tab is selected (0 for Chats, 1 for AI Assistant)
    final selectedTab = ref.watch(messagesTabProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        // Custom Tab Bar implementation
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            color: Colors.white,
            child: Row(
              children: [
                buildTabItem(ref, 'Chats', 0, selectedTab, messagesTabProvider, icon: Icons.chat_rounded),
                buildTabItem(ref, 'AI Assistant', 1, selectedTab, messagesTabProvider, icon: Icons.smart_toy_rounded)
              ],
            ),
          ),
        ),
      ),

      // The body now switches based on the state provider
      body: IndexedStack(
        index: selectedTab,
        children: const [
          ChatRoomsTabRealtime(), // This should contain your ListView.builder for chat rooms
          AIAssistantTab(),       // The AI Assistant view
        ],
      ),

      // FAB only appears on the Chats tab
      floatingActionButton: selectedTab == 0
          ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const UserSearchScreen(),
            ),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
    );
  }
}