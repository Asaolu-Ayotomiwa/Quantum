import 'package:cloud_firestore/cloud_firestore.dart';

enum PropertyType {
  apartment,
  house,
  villa,
  condo,
  land,
  commercial,
}

enum PropertyStatus {
  available,
  sold,
  rented,
  pending,
}

class PropertyModel {
  final String id;
  final String title;
  final String description;
  final double price;
  final String location;
  final String city;
  final String state;
  final PropertyType type;
  final PropertyStatus status;
  final int bedrooms;
  final int bathrooms;
  final double area; // in square meters
  final List<String> imageUrls;
  final List<String> amenities;
  final String ownerId;
  final String ownerName;
  final String ownerPhone;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int views;
  final List<String> savedBy; // User IDs who saved this property
  final bool isFeatured;
  final Map<String, dynamic>? coordinates; // {lat: double, lng: double}

  PropertyModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.location,
    required this.city,
    required this.state,
    required this.type,
    this.status = PropertyStatus.available,
    required this.bedrooms,
    required this.bathrooms,
    required this.area,
    required this.imageUrls,
    required this.amenities,
    required this.ownerId,
    required this.ownerName,
    required this.ownerPhone,
    required this.createdAt,
    required this.updatedAt,
    this.views = 0,
    this.savedBy = const [],
    this.isFeatured = false,
    this.coordinates,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'location': location,
      'city': city,
      'state': state,
      'type': type.toString(),
      'status': status.toString(),
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'area': area,
      'imageUrls': imageUrls,
      'amenities': amenities,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'ownerPhone': ownerPhone,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'views': views,
      'savedBy': savedBy,
      'isFeatured': isFeatured,
      'coordinates': coordinates,
    };
  }

  // Create from Firestore document
  factory PropertyModel.fromMap(Map<String, dynamic> map) {
    return PropertyModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      location: map['location'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      type: PropertyType.values.firstWhere(
            (e) => e.toString() == map['type'],
        orElse: () => PropertyType.apartment,
      ),
      status: PropertyStatus.values.firstWhere(
            (e) => e.toString() == map['status'],
        orElse: () => PropertyStatus.available,
      ),
      bedrooms: map['bedrooms'] ?? 0,
      bathrooms: map['bathrooms'] ?? 0,
      area: (map['area'] ?? 0).toDouble(),
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      amenities: List<String>.from(map['amenities'] ?? []),
      ownerId: map['ownerId'] ?? '',
      ownerName: map['ownerName'] ?? '',
      ownerPhone: map['ownerPhone'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
      views: map['views'] ?? 0,
      savedBy: List<String>.from(map['savedBy'] ?? []),
      isFeatured: map['isFeatured'] ?? false,
      coordinates: map['coordinates'],
    );
  }

  // Create from Firestore DocumentSnapshot
  factory PropertyModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PropertyModel.fromMap(data);
  }

  // CopyWith for updates
  PropertyModel copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    String? location,
    String? city,
    String? state,
    PropertyType? type,
    PropertyStatus? status,
    int? bedrooms,
    int? bathrooms,
    double? area,
    List<String>? imageUrls,
    List<String>? amenities,
    String? ownerId,
    String? ownerName,
    String? ownerPhone,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? views,
    List<String>? savedBy,
    bool? isFeatured,
    Map<String, dynamic>? coordinates,
  }) {
    return PropertyModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      location: location ?? this.location,
      city: city ?? this.city,
      state: state ?? this.state,
      type: type ?? this.type,
      status: status ?? this.status,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      area: area ?? this.area,
      imageUrls: imageUrls ?? this.imageUrls,
      amenities: amenities ?? this.amenities,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      views: views ?? this.views,
      savedBy: savedBy ?? this.savedBy,
      isFeatured: isFeatured ?? this.isFeatured,
      coordinates: coordinates ?? this.coordinates,
    );
  }

  // Helper methods
  String get formattedPrice {
    if (price >= 1000000) {
      return '₦${(price / 1000000).toStringAsFixed(1)}M';
    } else if (price >= 1000) {
      return '₦${(price / 1000).toStringAsFixed(0)}K';
    }
    return '₦${price.toStringAsFixed(0)}';
  }

  String get propertyTypeDisplay {
    return type.toString().split('.').last.toUpperCase();
  }

  String get statusDisplay {
    return status.toString().split('.').last.toUpperCase();
  }

  bool isSavedBy(String userId) {
    return savedBy.contains(userId);
  }
}