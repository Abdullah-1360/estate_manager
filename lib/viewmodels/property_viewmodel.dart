import 'package:flutter/material.dart';
import '../models/property_model.dart';
import '../repositories/property_repository.dart';

class PropertyViewModel extends ChangeNotifier {
  final PropertyRepository _repository;

  List<PropertyModel> _properties = [];
  bool _isLoading = false;
  String? _error;

  List<PropertyModel> get properties => _properties;
  bool get isLoading => _isLoading;
  String? get error => _error;

  PropertyViewModel(this._repository) {
    fetchProperties();
  }

  Future<void> fetchProperties({
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
    _setLoading(true);
    try {
      _properties = await _repository.getProperties(
        page: page,
        limit: limit,
        status: status,
        minPrice: minPrice,
        maxPrice: maxPrice,
        bedrooms: bedrooms,
        bathrooms: bathrooms,
        propertyType: propertyType,
        city: city,
        state: state,
        search: search,
        sort: sort,
      );
      _error = null;
    } catch (e) {
      _error = 'Failed to load properties: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addProperty(PropertyModel property) async {
    _setLoading(true);
    try {
      await _repository.addProperty(property);
      await fetchProperties(); // Refresh list
      _error = null;
    } catch (e) {
      _error = 'Failed to add property: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProperty(PropertyModel property) async {
    _setLoading(true);
    try {
      await _repository.updateProperty(property);
      await fetchProperties(); // Refresh list
      _error = null;
    } catch (e) {
      _error = 'Failed to update property: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteProperty(String id) async {
    _setLoading(true);
    try {
      await _repository.deleteProperty(id);
      await fetchProperties(); // Refresh list
      _error = null;
    } catch (e) {
      _error = 'Failed to delete property: $e';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
