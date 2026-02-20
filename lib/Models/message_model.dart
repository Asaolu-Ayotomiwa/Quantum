import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType {
  text,
  image,
  property, // For sharing property listings
}

class MessageModel {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String senderName;
  final String message;
  final MessageType type;
  final DateTime timestamp;
  final bool isRead;
  final String? imageUrl;
  final String? propertyId;

  MessageModel({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.senderName,
    required this.message,
    this.type = MessageType.text,
    required this.timestamp,
    this.isRead = false,
    this.imageUrl,
    this.propertyId,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chatRoomId': chatRoomId,
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'type': type.toString(),
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isRead': isRead,
      'imageUrl': imageUrl,
      'propertyId': propertyId,
    };
  }

  // Create from Firestore document
  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] ?? '',
      chatRoomId: map['chatRoomId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      message: map['message'] ?? '',
      type: MessageType.values.firstWhere(
            (e) => e.toString() == map['type'],
        orElse: () => MessageType.text,
      ),
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      isRead: map['isRead'] ?? false,
      imageUrl: map['imageUrl'],
      propertyId: map['propertyId'],
    );
  }

  // Create from Firestore DocumentSnapshot
  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MessageModel.fromMap(data);
  }
}