import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quantum/Providers/firestore_provider.dart';
import 'package:quantum/Screens/chatroom_screen_realtime.dart';
import 'package:intl/intl.dart';

class ChatRoomsTabRealtime extends ConsumerWidget {
  const ChatRoomsTabRealtime({super.key});

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(time);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatRoomsAsync = ref.watch(userChatRoomsProvider);
    final currentUserAsync = ref.watch(currentUserProfileProvider);

    return chatRoomsAsync.when(
      data: (chatRooms) {
        if (chatRooms.isEmpty) {
          // Empty state - no chats yet
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 20),
                Text(
                  'No conversations yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Tap the + button to start a new chat!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return currentUserAsync.when(
          data: (currentUser) {
            if (currentUser == null) {
              return const Center(
                child: Text('Please sign in to view messages'),
              );
            }

            return ListView.builder(
              itemCount: chatRooms.length,
              itemBuilder: (context, index) {
                final chatRoom = chatRooms[index];
                final otherUserName = chatRoom.getOtherUserName(currentUser.uid);
                final unreadCount = chatRoom.getUnreadCount(currentUser.uid);
                final isUnread = unreadCount > 0;

                return ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatRoomScreenRealtime(
                          chatRoomId: chatRoom.id,
                          chatName: otherUserName,
                        ),
                      ),
                    );
                  },
                  leading: CircleAvatar(
                    backgroundColor: Colors.green[100],
                    radius: 28,
                    child: Text(
                      otherUserName.isNotEmpty
                          ? otherUserName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    otherUserName,
                    style: TextStyle(
                      fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    chatRoom.lastMessage.isEmpty
                        ? 'Start a conversation'
                        : chatRoom.lastMessage,
                    style: TextStyle(
                      color: isUnread ? Colors.black87 : Colors.grey[600],
                      fontSize: 14,
                      fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatTime(chatRoom.lastMessageTime),
                        style: TextStyle(
                          color: isUnread ? Colors.green : Colors.grey[600],
                          fontSize: 12,
                          fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      if (unreadCount > 0) ...[
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            unreadCount > 99 ? '99+' : '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: $error'),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
        ),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading chats',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                '$error',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}