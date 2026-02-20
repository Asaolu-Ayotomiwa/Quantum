import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quantum/Services/property_service.dart';
import 'package:quantum/Services/storage_service.dart';
import 'package:quantum/Models/property_model.dart';

// Services Providers
final propertyServiceProvider = Provider<PropertyService>((ref) {
  return PropertyService();
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

// All Properties Provider
final allPropertiesProvider = StreamProvider<List<PropertyModel>>((ref) {
  final propertyService = ref.watch(propertyServiceProvider);
  return propertyService.getAllProperties();
});

// Featured Properties Provider
final featuredPropertiesProvider = StreamProvider<List<PropertyModel>>((ref) {
  final propertyService = ref.watch(propertyServiceProvider);
  return propertyService.getFeaturedProperties();
});

// Properties by City Provider
final propertiesByCityProvider = StreamProvider.family<List<PropertyModel>, String>((ref, city) {
  final propertyService = ref.watch(propertyServiceProvider);
  return propertyService.getPropertiesByCity(city);
});

// Properties by Type Provider
final propertiesByTypeProvider = StreamProvider.family<List<PropertyModel>, PropertyType>((ref, type) {
  final propertyService = ref.watch(propertyServiceProvider);
  return propertyService.getPropertiesByType(type);
});

// Single Property Provider
final propertyProvider = StreamProvider.family<PropertyModel?, String>((ref, propertyId) {
  final propertyService = ref.watch(propertyServiceProvider);
  return propertyService.streamProperty(propertyId);
});

// User's Properties Provider
final userPropertiesProvider = StreamProvider.family<List<PropertyModel>, String>((ref, userId) {
  final propertyService = ref.watch(propertyServiceProvider);
  return propertyService.getUserProperties(userId);
});

// Saved Properties Provider
final savedPropertiesProvider = StreamProvider<List<PropertyModel>>((ref) {
  final propertyService = ref.watch(propertyServiceProvider);
  return propertyService.getSavedProperties();
});

// Search Properties Provider
class SearchParams {
  final String? query;
  final String? city;
  final PropertyType? type;
  final double? minPrice;
  final double? maxPrice;
  final int? minBedrooms;
  final int? maxBedrooms;

  SearchParams({
    this.query,
    this.city,
    this.type,
    this.minPrice,
    this.maxPrice,
    this.minBedrooms,
    this.maxBedrooms,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchParams &&
        other.query == query &&
        other.city == city &&
        other.type == type &&
        other.minPrice == minPrice &&
        other.maxPrice == maxPrice &&
        other.minBedrooms == minBedrooms &&
        other.maxBedrooms == maxBedrooms;
  }

  @override
  int get hashCode {
    return query.hashCode ^
    city.hashCode ^
    type.hashCode ^
    minPrice.hashCode ^
    maxPrice.hashCode ^
    minBedrooms.hashCode ^
    maxBedrooms.hashCode;
  }
}

final searchPropertiesProvider = FutureProvider.family<List<PropertyModel>, SearchParams>((ref, params) async {
  final propertyService = ref.watch(propertyServiceProvider);
  return await propertyService.searchProperties(
    query: params.query,
    city: params.city,
    type: params.type,
    minPrice: params.minPrice,
    maxPrice: params.maxPrice,
    minBedrooms: params.minBedrooms,
    maxBedrooms: params.maxBedrooms,
  );
});