import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quantum/Models/user_models.dart';
import 'package:quantum/Models/message_model.dart';
import 'package:quantum/Models/chatroom_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String get currentUserId => _auth.currentUser?.uid ?? '';

  // ==================== USER OPERATIONS ====================

  // Create user profile in Firestore when they register
  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String username,
  }) async {
    try {
      final user = UserModel(
        uid: uid,
        email: email,
        username: username,
        bio: '',
        createdAt: DateTime.now(),
        lastSeen: DateTime.now(),
        isOnline: true,
      );

      await _firestore.collection('users').doc(uid).set(user.toMap());
    } catch (e) {
      throw Exception('Failed to create user profile: $e');
    }
  }

  // Get user profile
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String uid,
    String? username,
    String? bio,
    String? profilePicUrl,
  }) async {
    try {
      Map<String, dynamic> updates = {};
      if (username != null) updates['username'] = username;
      if (bio != null) updates['bio'] = bio;
      if (profilePicUrl != null) updates['profilePicUrl'] = profilePicUrl;

      if (updates.isNotEmpty) {
        await _firestore.collection('users').doc(uid).update(updates);
      }
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  // Update user online status
  Future<void> updateUserStatus(String uid, bool isOnline) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'isOnline': isOnline,
        'lastSeen': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      print('Failed to update user status: $e');
    }
  }

  // Stream user profile (real-time updates)
  Stream<UserModel?> streamUserProfile(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    });
  }

  // Search users by username
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThanOrEqualTo: query + '\uf8ff')
          .limit(10)
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  // ==================== CHAT ROOM OPERATIONS ====================

  // Create or get existing chat room
  Future<String> createChatRoom({
    required String otherUserId,
    required String otherUserName,
    required String currentUserName,
  }) async {
    try {
      // Check if chat room already exists
      final existingRoom = await _firestore
          .collection('chatRooms')
          .where('members', arrayContains: currentUserId)
          .get();

      for (var doc in existingRoom.docs) {
        final members = List<String>.from(doc.data()['members']);
        if (members.contains(otherUserId) && members.length == 2) {
          return doc.id; // Return existing chat room
        }
      }

      // Create new chat room
      final chatRoomId = _firestore.collection('chatRooms').doc().id;
      final chatRoom = ChatRoomModel(
        id: chatRoomId,
        members: [currentUserId, otherUserId],
        memberNames: {
          currentUserId: currentUserName,
          otherUserId: otherUserName,
        },
        lastMessage: '',
        lastMessageSenderId: '',
        lastMessageTime: DateTime.now(),
        unreadCount: {
          currentUserId: 0,
          otherUserId: 0,
        },
      );

      await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .set(chatRoom.toMap());

      return chatRoomId;
    } catch (e) {
      throw Exception('Failed to create chat room: $e');
    }
  }

  // Get user's chat rooms
  Stream<List<ChatRoomModel>> getUserChatRooms(String userId) {
    return _firestore
        .collection('chatRooms')
        .where('members', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatRoomModel.fromMap(doc.data()))
          .toList();
    });
  }

  // ==================== MESSAGE OPERATIONS ====================

  // Send message
  Future<void> sendMessage({
    required String chatRoomId,
    required String message,
    required String senderName,
    MessageType type = MessageType.text,
    String? imageUrl,
    String? propertyId,
  }) async {
    try {
      final messageId = _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc()
          .id;

      final messageModel = MessageModel(
        id: messageId,
        chatRoomId: chatRoomId,
        senderId: currentUserId,
        senderName: senderName,
        message: message,
        type: type,
        timestamp: DateTime.now(),
        isRead: false,
        imageUrl: imageUrl,
        propertyId: propertyId,
      );

      // Add message to subcollection
      await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId)
          .set(messageModel.toMap());

      // Update chat room's last message
      final chatRoomDoc =
      await _firestore.collection('chatRooms').doc(chatRoomId).get();
      final chatRoom = ChatRoomModel.fromMap(chatRoomDoc.data()!);

      Map<String, int> updatedUnreadCount = Map.from(chatRoom.unreadCount);
      for (String memberId in chatRoom.members) {
        if (memberId != currentUserId) {
          updatedUnreadCount[memberId] = (updatedUnreadCount[memberId] ?? 0) + 1;
        }
      }

      await _firestore.collection('chatRooms').doc(chatRoomId).update({
        'lastMessage': message,
        'lastMessageSenderId': currentUserId,
        'lastMessageTime': DateTime.now().millisecondsSinceEpoch,
        'unreadCount': updatedUnreadCount,
      });
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  // Get messages stream (real-time)
  Stream<List<MessageModel>> getMessages(String chatRoomId) {
    return _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MessageModel.fromFirestore(doc))
          .toList();
    });
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String chatRoomId) async {
    try {
      // Reset unread count for current user
      final chatRoomDoc =
      await _firestore.collection('chatRooms').doc(chatRoomId).get();
      final chatRoom = ChatRoomModel.fromMap(chatRoomDoc.data()!);

      Map<String, int> updatedUnreadCount = Map.from(chatRoom.unreadCount);
      updatedUnreadCount[currentUserId] = 0;

      await _firestore.collection('chatRooms').doc(chatRoomId).update({
        'unreadCount': updatedUnreadCount,
      });

      // Mark unread messages as read
      final unreadMessages = await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .where('senderId', isNotEqualTo: currentUserId)
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in unreadMessages.docs) {
        await doc.reference.update({'isRead': true});
      }
    } catch (e) {
      print('Failed to mark messages as read: $e');
    }
  }

  // Delete message
  Future<void> deleteMessage(String chatRoomId, String messageId) async {
    try {
      await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete message: $e');
    }
  }
}