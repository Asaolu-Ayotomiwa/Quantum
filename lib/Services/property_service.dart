import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quantum/Models/property_model.dart';

class PropertyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get currentUserId => _auth.currentUser?.uid ?? '';

  // ==================== CREATE ====================

  // Add new property
  Future<String> createProperty({
    required String title,
    required String description,
    required double price,
    required String location,
    required String city,
    required String state,
    required PropertyType type,
    required int bedrooms,
    required int bathrooms,
    required double area,
    required List<String> imageUrls,
    required List<String> amenities,
    required String ownerName,
    required String ownerPhone,
    Map<String, dynamic>? coordinates,
  }) async {
    try {
      final propertyId = _firestore.collection('properties').doc().id;

      final property = PropertyModel(
        id: propertyId,
        title: title,
        description: description,
        price: price,
        location: location,
        city: city,
        state: state,
        type: type,
        status: PropertyStatus.available,
        bedrooms: bedrooms,
        bathrooms: bathrooms,
        area: area,
        imageUrls: imageUrls,
        amenities: amenities,
        ownerId: currentUserId,
        ownerName: ownerName,
        ownerPhone: ownerPhone,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        coordinates: coordinates,
      );

      await _firestore
          .collection('properties')
          .doc(propertyId)
          .set(property.toMap());

      return propertyId;
    } catch (e) {
      throw Exception('Failed to create property: $e');
    }
  }

  // ==================== READ ====================

  // Get all properties
  Stream<List<PropertyModel>> getAllProperties() {
    return _firestore
        .collection('properties')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PropertyModel.fromFirestore(doc))
          .toList();
    });
  }

  // Get featured properties
  Stream<List<PropertyModel>> getFeaturedProperties() {
    return _firestore
        .collection('properties')
        .where('isFeatured', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PropertyModel.fromFirestore(doc))
          .toList();
    });
  }

  // Get properties by city
  Stream<List<PropertyModel>> getPropertiesByCity(String city) {
    return _firestore
        .collection('properties')
        .where('city', isEqualTo: city)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PropertyModel.fromFirestore(doc))
          .toList();
    });
  }

  // Get properties by type
  Stream<List<PropertyModel>> getPropertiesByType(PropertyType type) {
    return _firestore
        .collection('properties')
        .where('type', isEqualTo: type.toString())
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PropertyModel.fromFirestore(doc))
          .toList();
    });
  }

  // Get single property
  Future<PropertyModel?> getProperty(String propertyId) async {
    try {
      final doc = await _firestore.collection('properties').doc(propertyId).get();
      if (doc.exists) {
        return PropertyModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get property: $e');
    }
  }

  // Get property stream (real-time)
  Stream<PropertyModel?> streamProperty(String propertyId) {
    return _firestore
        .collection('properties')
        .doc(propertyId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return PropertyModel.fromFirestore(doc);
      }
      return null;
    });
  }

  // Get user's properties
  Stream<List<PropertyModel>> getUserProperties(String userId) {
    return _firestore
        .collection('properties')
        .where('ownerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PropertyModel.fromFirestore(doc))
          .toList();
    });
  }

  // Search properties
  Future<List<PropertyModel>> searchProperties({
    String? query,
    String? city,
    PropertyType? type,
    double? minPrice,
    double? maxPrice,
    int? minBedrooms,
    int? maxBedrooms,
  }) async {
    try {
      Query queryRef = _firestore.collection('properties');

      // Apply filters
      if (city != null && city.isNotEmpty) {
        queryRef = queryRef.where('city', isEqualTo: city);
      }

      if (type != null) {
        queryRef = queryRef.where('type', isEqualTo: type.toString());
      }

      if (minPrice != null) {
        queryRef = queryRef.where('price', isGreaterThanOrEqualTo: minPrice);
      }

      if (maxPrice != null) {
        queryRef = queryRef.where('price', isLessThanOrEqualTo: maxPrice);
      }

      if (minBedrooms != null) {
        queryRef = queryRef.where('bedrooms', isGreaterThanOrEqualTo: minBedrooms);
      }

      if (maxBedrooms != null) {
        queryRef = queryRef.where('bedrooms', isLessThanOrEqualTo: maxBedrooms);
      }

      final snapshot = await queryRef.get();
      var properties = snapshot.docs
          .map((doc) => PropertyModel.fromFirestore(doc))
          .toList();

      // Filter by query text (title, description, location)
      if (query != null && query.isNotEmpty) {
        final lowerQuery = query.toLowerCase();
        properties = properties.where((property) {
          return property.title.toLowerCase().contains(lowerQuery) ||
              property.description.toLowerCase().contains(lowerQuery) ||
              property.location.toLowerCase().contains(lowerQuery) ||
              property.city.toLowerCase().contains(lowerQuery);
        }).toList();
      }

      return properties;
    } catch (e) {
      throw Exception('Failed to search properties: $e');
    }
  }

  // ==================== UPDATE ====================

  // Update property
  Future<void> updateProperty({
    required String propertyId,
    String? title,
    String? description,
    double? price,
    String? location,
    PropertyType? type,
    PropertyStatus? status,
    int? bedrooms,
    int? bathrooms,
    double? area,
    List<String>? imageUrls,
    List<String>? amenities,
  }) async {
    try {
      Map<String, dynamic> updates = {'updatedAt': DateTime.now().millisecondsSinceEpoch};

      if (title != null) updates['title'] = title;
      if (description != null) updates['description'] = description;
      if (price != null) updates['price'] = price;
      if (location != null) updates['location'] = location;
      if (type != null) updates['type'] = type.toString();
      if (status != null) updates['status'] = status.toString();
      if (bedrooms != null) updates['bedrooms'] = bedrooms;
      if (bathrooms != null) updates['bathrooms'] = bathrooms;
      if (area != null) updates['area'] = area;
      if (imageUrls != null) updates['imageUrls'] = imageUrls;
      if (amenities != null) updates['amenities'] = amenities;

      await _firestore.collection('properties').doc(propertyId).update(updates);
    } catch (e) {
      throw Exception('Failed to update property: $e');
    }
  }

  // Increment property views
  Future<void> incrementViews(String propertyId) async {
    try {
      await _firestore.collection('properties').doc(propertyId).update({
        'views': FieldValue.increment(1),
      });
    } catch (e) {
      print('Failed to increment views: $e');
    }
  }

  // Toggle save property
  Future<void> toggleSaveProperty(String propertyId) async {
    try {
      final property = await getProperty(propertyId);
      if (property == null) return;

      if (property.isSavedBy(currentUserId)) {
        // Remove from saved
        await _firestore.collection('properties').doc(propertyId).update({
          'savedBy': FieldValue.arrayRemove([currentUserId]),
        });
      } else {
        // Add to saved
        await _firestore.collection('properties').doc(propertyId).update({
          'savedBy': FieldValue.arrayUnion([currentUserId]),
        });
      }
    } catch (e) {
      throw Exception('Failed to toggle save property: $e');
    }
  }

  // Get saved properties
  Stream<List<PropertyModel>> getSavedProperties() {
    return _firestore
        .collection('properties')
        .where('savedBy', arrayContains: currentUserId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PropertyModel.fromFirestore(doc))
          .toList();
    });
  }

  // ==================== DELETE ====================

  // Delete property
  Future<void> deleteProperty(String propertyId) async {
    try {
      await _firestore.collection('properties').doc(propertyId).delete();
    } catch (e) {
      throw Exception('Failed to delete property: $e');
    }
  }

  // ==================== STATISTICS ====================

  // Get property statistics
  Future<Map<String, dynamic>> getPropertyStats(String propertyId) async {
    try {
      final property = await getProperty(propertyId);
      if (property == null) {
        return {
          'views': 0,
          'saves': 0,
        };
      }

      return {
        'views': property.views,
        'saves': property.savedBy.length,
      };
    } catch (e) {
      return {
        'views': 0,
        'saves': 0,
      };
    }
  }
}