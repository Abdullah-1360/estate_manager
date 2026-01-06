import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/config/app_config.dart';
import '../models/property_model.dart';
import 'property_repository.dart';

class ApiPropertyRepository implements PropertyRepository {
  final String baseUrl;
  final http.Client _client;

  ApiPropertyRepository({
    String? baseUrl,
    http.Client? client,
  }) : baseUrl = baseUrl ?? AppConfig.apiUrl,
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

  /// Create property with image upload
  Future<PropertyModel> createPropertyWithImage(PropertyModel property, File? imageFile) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/properties'),
      );

      // Add property data
      final propertyJson = property.toJson();
      propertyJson.forEach((key, value) {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });

      // Add image if provided
      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', imageFile.path),
        );
      }

      final streamedResponse = await _client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return PropertyModel.fromJson(data['data']);
        } else {
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

  /// Mark property as sold (automatically removes from database)
  Future<Map<String, dynamic>> markPropertyAsSold(String propertyId) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/properties/$propertyId/sold'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return {
            'success': true,
            'message': data['message'],
            'propertyInfo': data['data'],
          };
        } else {
          throw Exception(data['message'] ?? 'Failed to mark property as sold');
        }
      } else if (response.statusCode == 404) {
        throw Exception('Property not found');
      } else if (response.statusCode == 400) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Property is already sold');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to mark property as sold');
      }
    } catch (e) {
      if (e is SocketException) {
        throw Exception('Network error: Please check your internet connection');
      } else if (e is FormatException) {
        throw Exception('Invalid response format from server');
      } else {
        throw Exception('Failed to mark property as sold: ${e.toString()}');
      }
    }
  }

  /// Update property with optional image upload
  Future<PropertyModel> updatePropertyWithImage(PropertyModel property, File? imageFile) async {
    try {
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/properties/${property.id}'),
      );

      // Add property data
      final propertyJson = property.toJson();
      propertyJson.forEach((key, value) {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });

      // Add image if provided
      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', imageFile.path),
        );
      }

      final streamedResponse = await _client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return PropertyModel.fromJson(data['data']);
        } else {
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

  /// Create property with multiple images upload
  Future<PropertyModel> createPropertyWithImages(PropertyModel property, List<File> imageFiles) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/properties'),
      );

      // Add property data
      final propertyJson = property.toJson();
      propertyJson.forEach((key, value) {
        if (value != null) {
          if (key == 'imageUrls') {
            // Skip imageUrls as we'll add the actual files
            return;
          }
          if (value is List) {
            request.fields[key] = jsonEncode(value);
          } else {
            request.fields[key] = value.toString();
          }
        }
      });

      // Add multiple images
      for (int i = 0; i < imageFiles.length; i++) {
        request.files.add(
          await http.MultipartFile.fromPath('images', imageFiles[i].path),
        );
      }

      final streamedResponse = await _client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return PropertyModel.fromJson(data['data']);
        } else {
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

  /// Update property with multiple images upload
  Future<PropertyModel> updatePropertyWithImages(PropertyModel property, List<File> imageFiles) async {
    try {
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/properties/${property.id}'),
      );

      // Add property data
      final propertyJson = property.toJson();
      propertyJson.forEach((key, value) {
        if (value != null) {
          if (key == 'imageUrls') {
            // Skip imageUrls as we'll add the actual files
            return;
          }
          if (value is List) {
            request.fields[key] = jsonEncode(value);
          } else {
            request.fields[key] = value.toString();
          }
        }
      });

      // Add multiple images
      for (int i = 0; i < imageFiles.length; i++) {
        request.files.add(
          await http.MultipartFile.fromPath('images', imageFiles[i].path),
        );
      }

      final streamedResponse = await _client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return PropertyModel.fromJson(data['data']);
        } else {
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

  void dispose() {
    _client.close();
  }
}