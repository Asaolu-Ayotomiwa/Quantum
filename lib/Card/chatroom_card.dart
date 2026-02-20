import 'package:flutter/material.dart';
import 'package:quantum/Screens/message_screen_complete.dart';


class ChatRoomCard extends StatelessWidget {
  final String name;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final IconData avatar;

  const ChatRoomCard({
    super.key,
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.unreadCount,
    required this.avatar,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MessagesScreenComplete(),
          ),
        );
      },
      leading: CircleAvatar(
        backgroundColor: Colors.green[100],
        radius: 28,
        child: Icon(avatar, color: Colors.green, size: 28),
      ),
      title: Text(
        name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        lastMessage,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            time,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          if (unreadCount > 0) ...[
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}