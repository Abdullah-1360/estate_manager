# Estate Manager - Complete Setup Guide

This guide will help you set up the complete Estate Manager application with the new Node.js backend and Cloudinary integration.

## Overview

The application has been updated to replace mock data with a proper backend:

- **Frontend**: Flutter app (unchanged UI, updated to use real API)
- **Backend**: Node.js with Express, MongoDB, and Cloudinary
- **Database**: MongoDB for property data
- **Images**: Cloudinary for optimized image storage and delivery

## Prerequisites

Before starting, ensure you have:

- **Node.js** (v16 or higher)
- **Flutter SDK** (latest stable version)
- **MongoDB** (local installation or cloud service)
- **Cloudinary Account** (free tier available)

## Backend Setup

### 1. Install Dependencies

```bash
cd backend
npm install
```

### 2. Environment Configuration

Create a `.env` file in the backend directory:

```bash
cp .env.example .env
```

Update the `.env` file with your configuration:

```env
# Server Configuration
PORT=3000
NODE_ENV=development

# Database Configuration
MONGODB_URI=mongodb://localhost:27017/estate_manager

# Cloudinary Configuration (Get these from your Cloudinary dashboard)
CLOUDINARY_CLOUD_NAME=your_cloud_name_here
CLOUDINARY_API_KEY=your_api_key_here
CLOUDINARY_API_SECRET=your_api_secret_here

# Security
JWT_SECRET=your_jwt_secret_key_here
CORS_ORIGIN=http://localhost:3000

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
```

### 3. Cloudinary Setup

1. **Create Account**: Go to [Cloudinary](https://cloudinary.com/) and create a free account
2. **Get Credentials**: From your dashboard, copy:
   - Cloud Name
   - API Key
   - API Secret
3. **Update .env**: Add these credentials to your `.env` file

### 4. Database Setup

#### Option A: Local MongoDB

1. **Install MongoDB**: Follow the [MongoDB installation guide](https://docs.mongodb.com/manual/installation/)
2. **Start MongoDB**: 
   ```bash
   mongod
   ```
3. **Use default URI**: `mongodb://localhost:27017/estate_manager`

#### Option B: MongoDB Atlas (Cloud)

1. **Create Account**: Go to [MongoDB Atlas](https://www.mongodb.com/atlas)
2. **Create Cluster**: Follow the setup wizard
3. **Get Connection String**: Copy the connection URI
4. **Update .env**: Replace `MONGODB_URI` with your Atlas URI

#### Option C: Docker (Recommended for Development)

```bash
cd backend
docker-compose up -d mongodb
```

### 5. Seed Database (Optional)

Populate the database with sample data:

```bash
cd backend
node scripts/seed-database.js
```

### 6. Start Backend Server

```bash
# Development mode (with auto-restart)
npm run dev

# Production mode
npm start
```

The server will start on `http://localhost:3000`

### 7. Verify Backend

Test the API endpoints:

```bash
# Health check
curl http://localhost:3000/health

# Get properties
curl http://localhost:3000/api/v1/properties

# Get property statistics
curl http://localhost:3000/api/v1/properties/stats
```

## Flutter Frontend Setup

### 1. Install Dependencies

```bash
# In the root directory (where pubspec.yaml is located)
flutter pub get
```

### 2. Update Environment Configuration

The `.env` file has been updated to point to the local backend:

```env
API_URL=http://localhost:3000/api/v1
```

For production, update this to your deployed backend URL.

### 3. Run Flutter App

```bash
# For development
flutter run

# For web
flutter run -d chrome

# For specific device
flutter devices
flutter run -d <device_id>
```

## Key Changes Made

### Backend Features

1. **RESTful API** with full CRUD operations
2. **Cloudinary Integration** for image management
3. **Advanced Filtering** and search capabilities
4. **Pagination** for efficient data loading
5. **Input Validation** with comprehensive error handling
6. **Image Optimization** with multiple size variants
7. **Property Statistics** and analytics
8. **Security Features** (CORS, rate limiting, input sanitization)

### Frontend Updates

1. **API Repository** replaces mock data
2. **HTTP Client** for API communication
3. **Enhanced Property Model** with additional fields
4. **Error Handling** for network issues
5. **JSON Serialization** for API communication

### Image Management

- **Automatic Optimization**: Images are compressed and optimized by Cloudinary
- **Multiple Formats**: Supports JPG, PNG, WebP with auto-format selection
- **Responsive Images**: Multiple size variants (thumbnail, medium, large)
- **Smart Naming**: Images named with property ID for easy retrieval
- **Secure Upload**: File validation and size limits

## API Endpoints

### Properties

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/properties` | Get all properties with filtering |
| GET | `/api/v1/properties/:id` | Get single property |
| POST | `/api/v1/properties` | Create new property |
| PUT | `/api/v1/properties/:id` | Update property |
| DELETE | `/api/v1/properties/:id` | Delete property |
| POST | `/api/v1/properties/:id/image` | Upload property image |
| GET | `/api/v1/properties/stats` | Get property statistics |

### Query Parameters

- `page`, `limit` - Pagination
- `status` - Filter by status (active, pending, sold)
- `minPrice`, `maxPrice` - Price range filtering
- `bedrooms`, `bathrooms` - Room filtering
- `propertyType` - Property type filtering
- `city`, `state` - Location filtering
- `search` - Text search in title, address, description
- `sort` - Sorting (price, -price, createdAt, -createdAt, title, -title)

## Testing the Integration

### 1. Create a Property

1. **Open Flutter App**
2. **Tap the + button** to add a new property
3. **Fill in the form** with property details
4. **Add an image URL** or upload an image (if implemented)
5. **Save the property**

### 2. Verify in Backend

Check that the property was created:

```bash
curl http://localhost:3000/api/v1/properties
```

### 3. Test Filtering

Try different filters in the Flutter app or via API:

```bash
# Filter by status
curl "http://localhost:3000/api/v1/properties?status=active"

# Filter by price range
curl "http://localhost:3000/api/v1/properties?minPrice=100000&maxPrice=500000"

# Search properties
curl "http://localhost:3000/api/v1/properties?search=apartment"
```

## Troubleshooting

### Common Issues

1. **Connection Refused**
   - Ensure backend server is running on port 3000
   - Check if MongoDB is running
   - Verify .env configuration

2. **Cloudinary Upload Fails**
   - Verify Cloudinary credentials in .env
   - Check image file size (max 10MB)
   - Ensure image format is supported (JPG, PNG, WebP)

3. **Flutter Build Errors**
   - Run `flutter clean && flutter pub get`
   - Ensure all dependencies are installed
   - Check for any import errors

4. **Database Connection Issues**
   - Verify MongoDB is running
   - Check MONGODB_URI in .env
   - For Atlas, ensure IP whitelist includes your IP

### Logs and Debugging

- **Backend Logs**: Check console output where you started the server
- **Flutter Logs**: Check the debug console in your IDE
- **MongoDB Logs**: Check MongoDB logs for database issues
- **Cloudinary**: Check Cloudinary dashboard for upload status

## Production Deployment

### Backend Deployment

1. **Environment Variables**: Set all required env vars on your hosting platform
2. **Database**: Use MongoDB Atlas or similar cloud service
3. **Images**: Cloudinary handles CDN automatically
4. **SSL**: Ensure HTTPS is enabled
5. **Process Management**: Use PM2 or similar for process management

### Flutter Deployment

1. **Update API_URL**: Point to your production backend
2. **Build**: Use `flutter build` for your target platform
3. **Deploy**: Follow platform-specific deployment guides

## Next Steps

1. **Authentication**: Add user authentication and authorization
2. **Real-time Updates**: Implement WebSocket for live updates
3. **Advanced Search**: Add geolocation-based search
4. **Image Upload**: Implement direct image upload from Flutter
5. **Caching**: Add Redis for improved performance
6. **Testing**: Add comprehensive test suites
7. **Monitoring**: Add logging and monitoring services

## Support

If you encounter issues:

1. Check the logs for detailed error messages
2. Verify all environment variables are set correctly
3. Ensure all services (MongoDB, backend) are running
4. Test API endpoints directly with curl or Postman
5. Check Cloudinary dashboard for image upload issues

The backend provides comprehensive error messages to help with debugging.