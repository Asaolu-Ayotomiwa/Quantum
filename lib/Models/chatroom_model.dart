class ChatRoomModel {
  final String id;
  final List<String> members; // User IDs
  final Map<String, String> memberNames; // userId: userName
  final String lastMessage;
  final String lastMessageSenderId;
  final DateTime lastMessageTime;
  final Map<String, int> unreadCount; // userId: count
  final String? chatName; // For group chats
  final String? chatImage; // For group chats
  final bool isGroup;

  ChatRoomModel({
    required this.id,
    required this.members,
    required this.memberNames,
    required this.lastMessage,
    required this.lastMessageSenderId,
    required this.lastMessageTime,
    required this.unreadCount,
    this.chatName,
    this.chatImage,
    this.isGroup = false,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'members': members,
      'memberNames': memberNames,
      'lastMessage': lastMessage,
      'lastMessageSenderId': lastMessageSenderId,
      'lastMessageTime': lastMessageTime.millisecondsSinceEpoch,
      'unreadCount': unreadCount,
      'chatName': chatName,
      'chatImage': chatImage,
      'isGroup': isGroup,
    };
  }

  // Create from Firestore document
  factory ChatRoomModel.fromMap(Map<String, dynamic> map) {
    return ChatRoomModel(
      id: map['id'] ?? '',
      members: List<String>.from(map['members'] ?? []),
      memberNames: Map<String, String>.from(map['memberNames'] ?? {}),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageSenderId: map['lastMessageSenderId'] ?? '',
      lastMessageTime: DateTime.fromMillisecondsSinceEpoch(
        map['lastMessageTime'] ?? 0,
      ),
      unreadCount: Map<String, int>.from(map['unreadCount'] ?? {}),
      chatName: map['chatName'],
      chatImage: map['chatImage'],
      isGroup: map['isGroup'] ?? false,
    );
  }

  // Helper to get other user's name in 1-on-1 chat
  String getOtherUserName(String currentUserId) {
    if (isGroup) return chatName ?? 'Group Chat';

    final otherUserId = members.firstWhere(
          (id) => id != currentUserId,
      orElse: () => '',
    );

    return memberNames[otherUserId] ?? 'Unknown User';
  }

  // Helper to get unread count for current user
  int getUnreadCount(String currentUserId) {
    return unreadCount[currentUserId] ?? 0;
  }
}