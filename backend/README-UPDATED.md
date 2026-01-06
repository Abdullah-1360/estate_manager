# Estate Manager Backend API

A robust Node.js/Express backend API for the Estate Manager Flutter application with multiple image support, Cloudinary integration, and MongoDB storage.

## Features

- 🏠 Complete property CRUD operations
- 📸 **Multiple image upload support** with Cloudinary
- 🔍 Advanced property search and filtering
- 📊 Property statistics and analytics
- 🏷️ Automatic sold property management
- 🛡️ Input validation and error handling
- 🚀 Rate limiting and security middleware
- 📱 Optimized for Flutter mobile app

## API Endpoints

### Properties

#### Get All Properties
```
GET /api/v1/properties
```
Query parameters:
- `page` (number): Page number (default: 1)
- `limit` (number): Items per page (default: 10, max: 100)
- `sort` (string): Sort by field (price, -price, createdAt, -createdAt, title, -title)
- `status` (string): Filter by status (active, pending, sold)
- `minPrice` (number): Minimum price filter
- `maxPrice` (number): Maximum price filter
- `bedrooms` (number): Filter by number of bedrooms
- `bathrooms` (number): Filter by number of bathrooms
- `propertyType` (string): Filter by property type
- `city` (string): Filter by city
- `state` (string): Filter by state
- `search` (string): Search in title, address, description

#### Get Single Property
```
GET /api/v1/properties/:id
```

#### Create Property (with multiple images)
```
POST /api/v1/properties
Content-Type: multipart/form-data
```
Form fields:
- `title` (string, required): Property title
- `address` (string, required): Property address
- `price` (number, required): Property price
- `description` (string, required): Property description
- `bedrooms` (number, required): Number of bedrooms
- `bathrooms` (number, required): Number of bathrooms
- `status` (string): Property status (active, pending, sold)
- `propertyType` (string): Type of property
- `squareFootage` (number): Square footage
- `yearBuilt` (number): Year built
- `features` (array): Property features
- `images` (files): Multiple image files (max 10)

#### Update Property (with multiple images)
```
PUT /api/v1/properties/:id
Content-Type: multipart/form-data
```
Same fields as create (all optional except when uploading new images)

#### Delete Property
```
DELETE /api/v1/properties/:id
```

#### Upload Images to Existing Property
```
POST /api/v1/properties/:id/images
Content-Type: multipart/form-data
```
Form fields:
- `images` (files): Multiple image files (max 10)

#### Mark Property as Sold
```
POST /api/v1/properties/:id/sold
```
*Note: This automatically removes the property from the database*

### Statistics

#### Get Property Statistics
```
GET /api/v1/properties/stats
```

#### Get Sold Properties Statistics
```
GET /api/v1/properties/sold-stats?days=30
```

### Admin

#### Cleanup Sold Properties
```
POST /api/v1/properties/cleanup-sold
```

## Property Model

```json
{
  "id": "uuid-string",
  "title": "Beautiful Family Home",
  "address": "123 Main Street, City, State",
  "price": 450000,
  "description": "A wonderful property...",
  "imageUrls": [
    "https://cloudinary-url-1.jpg",
    "https://cloudinary-url-2.jpg"
  ],
  "bedrooms": 4,
  "bathrooms": 3,
  "status": "active",
  "squareFootage": 2500,
  "yearBuilt": 2010,
  "propertyType": "house",
  "features": ["garage", "garden", "fireplace"],
  "location": {
    "coordinates": [-122.4194, 37.7749],
    "city": "San Francisco",
    "state": "CA",
    "zipCode": "94102",
    "country": "US"
  },
  "createdAt": "2024-01-01T00:00:00.000Z",
  "updatedAt": "2024-01-01T00:00:00.000Z"
}
```

## Setup and Installation

1. **Clone and install dependencies:**
```bash
cd backend
npm install
```

2. **Environment setup:**
Create a `.env` file:
```env
NODE_ENV=development
PORT=3000
MONGODB_URI=mongodb://localhost:27017/estate_manager

# Cloudinary Configuration
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret

# Security
CORS_ORIGIN=*
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
```

3. **Database migration (if upgrading from single image):**
```bash
npm run migrate-images
```

4. **Start the server:**
```bash
# Development
npm run dev

# Production
npm start
```

5. **Test the API:**
```bash
node test-api.js
```

## Image Upload Details

### Multiple Image Support
- **Maximum images per property**: 10
- **Supported formats**: JPG, PNG, WebP
- **Automatic optimization**: Images are automatically optimized by Cloudinary
- **Responsive variants**: Multiple sizes generated automatically
- **Secure storage**: Images stored securely on Cloudinary CDN

### Image Upload Process
1. Images are uploaded to Cloudinary during property creation/update
2. Cloudinary URLs are stored in the `imageUrls` array
3. Public IDs are stored in `cloudinaryPublicIds` for deletion management
4. Old images are automatically deleted when new ones are uploaded
5. All images are deleted when property is marked as sold

## Error Handling

The API returns consistent error responses:

```json
{
  "success": false,
  "message": "Error description",
  "error": "Detailed error message",
  "errors": [
    {
      "field": "fieldName",
      "message": "Field-specific error"
    }
  ]
}
```

## Development Scripts

```bash
npm run dev          # Start development server with nodemon
npm run start        # Start production server
npm run test         # Run tests
npm run seed         # Seed database with sample data
npm run cleanup-sold # Clean up sold properties
npm run migrate-images # Migrate from single to multiple images
```

## Flutter Integration

The backend is specifically designed to work with the Estate Manager Flutter app:

- **Multipart form data**: Supports Flutter's `http.MultipartRequest`
- **Multiple images**: Handles `List<File>` from Flutter image picker
- **Error handling**: Provides detailed error messages for Flutter UI
- **Pagination**: Optimized for mobile list views
- **Search**: Full-text search across multiple fields

## Migration from Single Images

If you're upgrading from the previous single-image version:

1. **Run migration script**:
```bash
npm run migrate-images
```

2. **Update Flutter app**: Ensure your Flutter app uses the new multiple image endpoints

3. **Test thoroughly**: Verify all existing properties display correctly