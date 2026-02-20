import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Shared/message_stream_provider.dart';

// The StreamProvider listens to the 'messages' sub-collection in real-time
final messagesStreamProvider = StreamProvider.family<List<Message>, String>((ref, roomId) {
  return FirebaseFirestore.instance
      .collection('rooms')
      .doc(roomId)
      .collection('messages')
      .orderBy('timestamp', descending: true) // Newest messages first
      .snapshots()
      .map((snapshot) => snapshot.docs
      .map((doc) => Message.fromMap(doc.data()))
      .toList());
});