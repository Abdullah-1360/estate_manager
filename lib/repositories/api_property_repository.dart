import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/property_model.dart';
import 'property_repository.dart';

class ApiPropertyRepository implements PropertyRepository {
  final String baseUrl;
  final http.Client _client;

  ApiPropertyRepository({
    String? baseUrl,
    http.Client? client,
  }) : baseUrl = baseUrl ?? dotenv.env['API_URL'] ?? 'http://localhost:3000/api/v1',
        _client = client ?? http.Client();

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

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
    try {
      // Build query parameters
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        'sort': sort,
      };

      if (status != null) queryParams['status'] = status;
      if (minPrice != null) queryParams['minPrice'] = minPrice.toString();
      if (maxPrice != null) queryParams['maxPrice'] = maxPrice.toString();
      if (bedrooms != null) queryParams['bedrooms'] = bedrooms.toString();
      if (bathrooms != null) queryParams['bathrooms'] = bathrooms.toString();
      if (propertyType != null) queryParams['propertyType'] = propertyType;
      if (city != null) queryParams['city'] = city;
      if (state != null) queryParams['state'] = state;
      if (search != null) queryParams['search'] = search;

      final uri = Uri.parse('$baseUrl/properties').replace(queryParameters: queryParams);
      
      final response = await _client.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> propertiesJson = data['data'];
          return propertiesJson.map((json) => PropertyModel.fromJson(json)).toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to load properties');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to load properties');
      }
    } catch (e) {
      if (e is SocketException) {
        throw Exception('Network error: Please check your internet connection');
      } else if (e is FormatException) {
        throw Exception('Invalid response format from server');
      } else {
        throw Exception('Failed to load properties: ${e.toString()}');
      }
    }
  }

  @override
  Future<PropertyModel> getProperty(String id) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/properties/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return PropertyModel.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Property not found');
        }
      } else if (response.statusCode == 404) {
        throw Exception('Property not found');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to load property');
      }
    } catch (e) {
      if (e is SocketException) {
        throw Exception('Network error: Please check your internet connection');
      } else if (e is FormatException) {
        throw Exception('Invalid response format from server');
      } else {
        throw Exception('Failed to load property: ${e.toString()}');
      }
    }
  }

  @override
  Future<void> addProperty(PropertyModel property) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/properties'),
        headers: _headers,
        body: json.encode(property.toJson()),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] != true) {
          throw Exception(data['message'] ?? 'Failed to create property');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create property');
      }
    } catch (e) {
      if (e is SocketException) {
        throw Exception('Network error: Please check your internet connection');
      } else if (e is FormatException) {
        throw Exception('Invalid response format from server');
      } else {
        throw Exception('Failed to create property: ${e.toString()}');
      }
    }
  }

  @override
  Future<void> updateProperty(PropertyModel property) async {
    try {
      final response = await _client.put(
        Uri.parse('$baseUrl/properties/${property.id}'),
        headers: _headers,
        body: json.encode(property.toJson()),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] != true) {
          throw Exception(data['message'] ?? 'Failed to update property');
        }
      } else if (response.statusCode == 404) {
        throw Exception('Property not found');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update property');
      }
    } catch (e) {
      if (e is SocketException) {
        throw Exception('Network error: Please check your internet connection');
      } else if (e is FormatException) {
        throw Exception('Invalid response format from server');
      } else {
        throw Exception('Failed to update property: ${e.toString()}');
      }
    }
  }

  @override
  Future<void> deleteProperty(String id) async {
    try {
      final response = await _client.delete(
        Uri.parse('$baseUrl/properties/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] != true) {
          throw Exception(data['message'] ?? 'Failed to delete property');
        }
      } else if (response.statusCode == 404) {
        throw Exception('Property not found');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to delete property');
      }
    } catch (e) {
      if (e is SocketException) {
        throw Exception('Network error: Please check your internet connection');
      } else if (e is FormatException) {
        throw Exception('Invalid response format from server');
      } else {
        throw Exception('Failed to delete property: ${e.toString()}');
      }
    }
  }

  /// Upload image for a property
  Future<String> uploadPropertyImage(String propertyId, File imageFile) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/properties/$propertyId/image'),
      );

      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      final streamedResponse = await _client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data']['imageUrl'];
        } else {
          throw Exception(data['message'] ?? 'Failed to upload image');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to upload image');
      }
    } catch (e) {
      if (e is SocketException) {
        throw Exception('Network error: Please check your internet connection');
      } else if (e is FormatException) {
        throw Exception('Invalid response format from server');
      } else {
        throw Exception('Failed to upload image: ${e.toString()}');
      }
    }
  }

  /// Get property statistics
  Future<Map<String, dynamic>> getPropertyStats() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/properties/stats'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'];
        } else {
          throw Exception(data['message'] ?? 'Failed to load statistics');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to load statistics');
      }
    } catch (e) {
      if (e is SocketException) {
        throw Exception('Network error: Please check your internet connection');
      } else if (e is FormatException) {
        throw Exception('Invalid response format from server');
      } else {
        throw Exception('Failed to load statistics: ${e.toString()}');
      }
    }
  }

  void dispose() {
    _client.close();
  }
}