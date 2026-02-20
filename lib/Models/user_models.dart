class UserModel {
  final String uid;
  final String email;
  final String username;
  final String bio;
  final String? profilePicUrl;
  final DateTime createdAt;
  final DateTime lastSeen;
  final bool isOnline;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    this.bio = '',
    this.profilePicUrl,
    required this.createdAt,
    required this.lastSeen,
    this.isOnline = false,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'bio': bio,
      'profilePicUrl': profilePicUrl,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastSeen': lastSeen.millisecondsSinceEpoch,
      'isOnline': isOnline,
    };
  }

  // Create from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      bio: map['bio'] ?? '',
      profilePicUrl: map['profilePicUrl'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      lastSeen: DateTime.fromMillisecondsSinceEpoch(map['lastSeen'] ?? 0),
      isOnline: map['isOnline'] ?? false,
    );
  }

  // CopyWith for updates
  UserModel copyWith({
    String? uid,
    String? email,
    String? username,
    String? bio,
    String? profilePicUrl,
    DateTime? createdAt,
    DateTime? lastSeen,
    bool? isOnline,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      profilePicUrl: profilePicUrl ?? this.profilePicUrl,
      createdAt: createdAt ?? this.createdAt,
      lastSeen: lastSeen ?? this.lastSeen,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}