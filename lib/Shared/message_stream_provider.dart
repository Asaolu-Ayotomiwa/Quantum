import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String text;
  final DateTime timestamp;

  Message({
    required this.senderId,
    required this.text,
    required this.timestamp,
  });

  // Factory to create a Message from Firestore document data
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      // Handles Firestore Timestamp conversion to Dart DateTime
      timestamp: map['timestamp'] != null
          ? (map['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  // Method to turn a Message into a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}