import '../models/property_model.dart';

abstract class PropertyRepository {
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
  });
  Future<PropertyModel> getProperty(String id);
  Future<void> addProperty(PropertyModel property);
  Future<void> updateProperty(PropertyModel property);
  Future<void> deleteProperty(String id);
}
