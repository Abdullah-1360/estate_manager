import 'package:uuid/uuid.dart';
import '../models/property_model.dart';
import 'property_repository.dart';

class MockPropertyRepository implements PropertyRepository {
  final List<PropertyModel> _properties = [];

  MockPropertyRepository() {
    // Seed with some data
    _properties.addAll([
      PropertyModel(
        id: const Uuid().v4(),
        title: 'Modern Apartment in City Center',
        address: '123 Main St, Metropolis',
        price: 450000,
        description: 'A beautiful modern apartment with stunning city views. Close to all amenities.',
        imageUrls: ['https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?ixlib=rb-4.0.3&auto=format&fit=crop&w=1170&q=80'],
        bedrooms: 2,
        bathrooms: 2,
        status: PropertyStatus.active,
      ),
      PropertyModel(
        id: const Uuid().v4(),
        title: 'Cozy Suburban Home',
        address: '456 Oak Ave, Suburbia',
        price: 320000,
        description: 'Perfect for a small family. Large backyard and quiet neighborhood.',
        imageUrls: ['https://images.unsplash.com/photo-1568605114967-8130f3a36994?ixlib=rb-4.0.3&auto=format&fit=crop&w=1170&q=80'],
        bedrooms: 3,
        bathrooms: 2,
        status: PropertyStatus.pending,
      ),
      PropertyModel(
        id: const Uuid().v4(),
        title: 'Luxury Villa',
        address: '789 Beach Blvd, Seaside',
        price: 1200000,
        description: 'Exclusive villa with private pool and beach access.',
        imageUrls: [
          'https://images.unsplash.com/photo-1613490493576-7fde63acd811?ixlib=rb-4.0.3&auto=format&fit=crop&w=1171&q=80',
          'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?ixlib=rb-4.0.3&auto=format&fit=crop&w=1175&q=80',
          'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?ixlib=rb-4.0.3&auto=format&fit=crop&w=1153&q=80'
        ],
        bedrooms: 5,
        bathrooms: 4,
        status: PropertyStatus.active,
      ),
    ]);
  }

  @override
  Future<List<PropertyModel>> getProperties({
    int page = 1,
    int limit = 10,
    String? status,
    double? minPrice,
    double? maxPrice,
    int? bedrooms,
    int? bathrooms,
    String? propertyType,
    String? city,
    String? state,
    String? search,
    String sort = '-createdAt',
  }) async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate network delay
    
    // Apply filters (basic implementation for mock)
    var filteredProperties = List<PropertyModel>.from(_properties);
    
    if (status != null) {
      filteredProperties = filteredProperties.where((p) => p.statusString == status).toList();
    }
    
    if (minPrice != null) {
      filteredProperties = filteredProperties.where((p) => p.price >= minPrice).toList();
    }
    
    if (maxPrice != null) {
      filteredProperties = filteredProperties.where((p) => p.price <= maxPrice).toList();
    }
    
    if (bedrooms != null) {
      filteredProperties = filteredProperties.where((p) => p.bedrooms == bedrooms).toList();
    }
    
    if (bathrooms != null) {
      filteredProperties = filteredProperties.where((p) => p.bathrooms == bathrooms).toList();
    }
    
    if (search != null && search.isNotEmpty) {
      final searchLower = search.toLowerCase();
      filteredProperties = filteredProperties.where((p) => 
        p.title.toLowerCase().contains(searchLower) ||
        p.address.toLowerCase().contains(searchLower) ||
        p.description.toLowerCase().contains(searchLower)
      ).toList();
    }
    
    // Apply sorting
    if (sort == 'price') {
      filteredProperties.sort((a, b) => a.price.compareTo(b.price));
    } else if (sort == '-price') {
      filteredProperties.sort((a, b) => b.price.compareTo(a.price));
    } else if (sort == 'title') {
      filteredProperties.sort((a, b) => a.title.compareTo(b.title));
    } else if (sort == '-title') {
      filteredProperties.sort((a, b) => b.title.compareTo(a.title));
    }
    
    // Apply pagination
    final startIndex = (page - 1) * limit;
    final endIndex = startIndex + limit;
    
    if (startIndex >= filteredProperties.length) {
      return [];
    }
    
    return filteredProperties.sublist(
      startIndex, 
      endIndex > filteredProperties.length ? filteredProperties.length : endIndex
    );
  }

  @override
  Future<PropertyModel> getProperty(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _properties.firstWhere((p) => p.id == id);
  }

  @override
  Future<void> addProperty(PropertyModel property) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    // Ensure ID is set if empty (though usually handled by caller or backend, here we can ensure uniqueness if needed, but assuming caller handles ID generation or we assume new ID)
    // For this mock, we accept the object as is.
    _properties.add(property);
  }

  @override
  Future<void> updateProperty(PropertyModel property) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    final index = _properties.indexWhere((p) => p.id == property.id);
    if (index != -1) {
      _properties[index] = property;
    }
  }

  @override
  Future<void> deleteProperty(String id) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _properties.removeWhere((p) => p.id == id);
  }
}
