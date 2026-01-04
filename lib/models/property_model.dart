enum PropertyStatus { active, pending, sold }

class PropertyModel {
  final String id;
  final String title;
  final String address;
  final double price;
  final String description;
  final String imageUrl;
  final int bedrooms;
  final int bathrooms;
  final PropertyStatus status;
  final String? cloudinaryPublicId;
  final double? squareFootage;
  final int? yearBuilt;
  final String? propertyType;
  final List<String>? features;
  final PropertyLocation? location;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PropertyModel({
    required this.id,
    required this.title,
    required this.address,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.bedrooms,
    required this.bathrooms,
    required this.status,
    this.cloudinaryPublicId,
    this.squareFootage,
    this.yearBuilt,
    this.propertyType,
    this.features,
    this.location,
    this.createdAt,
    this.updatedAt,
  });

  PropertyModel copyWith({
    String? id,
    String? title,
    String? address,
    double? price,
    String? description,
    String? imageUrl,
    int? bedrooms,
    int? bathrooms,
    PropertyStatus? status,
    String? cloudinaryPublicId,
    double? squareFootage,
    int? yearBuilt,
    String? propertyType,
    List<String>? features,
    PropertyLocation? location,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PropertyModel(
      id: id ?? this.id,
      title: title ?? this.title,
      address: address ?? this.address,
      price: price ?? this.price,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      status: status ?? this.status,
      cloudinaryPublicId: cloudinaryPublicId ?? this.cloudinaryPublicId,
      squareFootage: squareFootage ?? this.squareFootage,
      yearBuilt: yearBuilt ?? this.yearBuilt,
      propertyType: propertyType ?? this.propertyType,
      features: features ?? this.features,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper to convert status to string for UI or storage if needed
  String get statusString => status.toString().split('.').last;

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'address': address,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'status': statusString,
      if (cloudinaryPublicId != null) 'cloudinaryPublicId': cloudinaryPublicId,
      if (squareFootage != null) 'squareFootage': squareFootage,
      if (yearBuilt != null) 'yearBuilt': yearBuilt,
      if (propertyType != null) 'propertyType': propertyType,
      if (features != null) 'features': features,
      if (location != null) 'location': location?.toJson(),
    };
  }

  // JSON deserialization
  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: json['id'] as String,
      title: json['title'] as String,
      address: json['address'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      bedrooms: json['bedrooms'] as int,
      bathrooms: json['bathrooms'] as int,
      status: _parseStatus(json['status'] as String),
      cloudinaryPublicId: json['cloudinaryPublicId'] as String?,
      squareFootage: json['squareFootage'] != null 
          ? (json['squareFootage'] as num).toDouble() 
          : null,
      yearBuilt: json['yearBuilt'] as int?,
      propertyType: json['propertyType'] as String?,
      features: json['features'] != null 
          ? List<String>.from(json['features'] as List) 
          : null,
      location: json['location'] != null 
          ? PropertyLocation.fromJson(json['location'] as Map<String, dynamic>) 
          : null,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
    );
  }

  static PropertyStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return PropertyStatus.active;
      case 'pending':
        return PropertyStatus.pending;
      case 'sold':
        return PropertyStatus.sold;
      default:
        return PropertyStatus.active;
    }
  }
}

class PropertyLocation {
  final List<double>? coordinates; // [longitude, latitude]
  final String? city;
  final String? state;
  final String? zipCode;
  final String? country;

  PropertyLocation({
    this.coordinates,
    this.city,
    this.state,
    this.zipCode,
    this.country,
  });

  Map<String, dynamic> toJson() {
    return {
      if (coordinates != null) 'coordinates': coordinates,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (zipCode != null) 'zipCode': zipCode,
      if (country != null) 'country': country,
    };
  }

  factory PropertyLocation.fromJson(Map<String, dynamic> json) {
    return PropertyLocation(
      coordinates: json['coordinates'] != null 
          ? List<double>.from(json['coordinates'] as List) 
          : null,
      city: json['city'] as String?,
      state: json['state'] as String?,
      zipCode: json['zipCode'] as String?,
      country: json['country'] as String?,
    );
  }
}
