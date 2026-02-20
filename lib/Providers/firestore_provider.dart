import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quantum/Services/firestore_service.dart';
import 'package:quantum/Models/user_models.dart';
import 'package:quantum/Models/chatroom_model.dart';
import 'package:quantum/Models/message_model.dart';

// Firestore Service Provider
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

// Current User Profile Provider
final currentUserProfileProvider = StreamProvider<UserModel?>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final userId = firestoreService.currentUserId;

  if (userId.isEmpty) {
    return Stream.value(null);
  }

  return firestoreService.streamUserProfile(userId);
});

// User Chat Rooms Provider
final userChatRoomsProvider = StreamProvider<List<ChatRoomModel>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final userId = firestoreService.currentUserId;

  if (userId.isEmpty) {
    return Stream.value([]);
  }

  return firestoreService.getUserChatRooms(userId);
});

// Chat Messages Provider (requires chatRoomId parameter)
final chatMessagesProvider = StreamProvider.family<List<MessageModel>, String>((ref, chatRoomId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getMessages(chatRoomId);
});

// Search Users Provider
final searchUsersProvider = FutureProvider.family<List<UserModel>, String>((ref, query) async {
  if (query.isEmpty) return [];

  final firestoreService = ref.watch(firestoreServiceProvider);
  return await firestoreService.searchUsers(query);
});