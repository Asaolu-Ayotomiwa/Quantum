// import 'package:flutter/material.dart';
// import 'package:quantum/Card/chatroom_card.dart';
//
// class ChatRoomsTab extends StatelessWidget {
//   const ChatRoomsTab({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     // Sample chat rooms data
//     final chatRooms = [
//       {
//         'name': 'Property Sellers',
//         'lastMessage': 'New villa available in Lekki',
//         'time': '2m ago',
//         'unread': 3,
//         'avatar': Icons.home_work,
//       },
//       {
//         'name': 'Real Estate Agents',
//         'lastMessage': 'Meeting scheduled for tomorrow',
//         'time': '1h ago',
//         'unread': 0,
//         'avatar': Icons.people,
//       },
//       {
//         'name': 'John Doe',
//         'lastMessage': 'Is the property still available?',
//         'time': '3h ago',
//         'unread': 1,
//         'avatar': Icons.person,
//       },
//       {
//         'name': 'Property Buyers',
//         'lastMessage': 'Looking for 3-bedroom apartment',
//         'time': '5h ago',
//         'unread': 0,
//         'avatar': Icons.group,
//       },
//     ];
//
//     return ListView.builder(
//       itemCount: chatRooms.length,
//       itemBuilder: (context, index) {
//         final chat = chatRooms[index];
//         return ChatRoomCard(
//           name: chat['name'] as String,
//           lastMessage: chat['lastMessage'] as String,
//           time: chat['time'] as String,
//           unreadCount: chat['unread'] as int,
//           avatar: chat['avatar'] as IconData,
//         );
//       },
//     );
//   }
// }