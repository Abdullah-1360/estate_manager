# Estate Manager Backend API

A robust Node.js backend API for the Estate Manager Flutter application with Cloudinary integration for image management.

## Features

- **RESTful API** for property management
- **Cloudinary Integration** for optimized image storage and delivery
- **MongoDB** with Mongoose for data persistence
- **Input Validation** with Joi
- **Error Handling** with comprehensive error middleware
- **Image Upload** with automatic optimization and multiple variants
- **Search & Filtering** with pagination support
- **Property Statistics** and analytics
- **Security** with Helmet, CORS, and rate limiting
- **Performance** with compression and optimized queries

## Quick Start

### Prerequisites

- Node.js (v16 or higher)
- MongoDB (local or cloud)
- Cloudinary account

### Installation

1. **Clone and setup**
   ```bash
   cd backend
   npm install
   ```

2. **Environment Configuration**
   ```bash
   cp .env.example .env
   ```
   
   Update `.env` with your configuration:
   ```env
   PORT=3000
   NODE_ENV=development
   MONGODB_URI=mongodb://localhost:27017/estate_manager
   CLOUDINARY_CLOUD_NAME=your_cloud_name
   CLOUDINARY_API_KEY=your_api_key
   CLOUDINARY_API_SECRET=your_api_secret
   ```

3. **Start the server**
   ```bash
   # Development
   npm run dev
   
   # Production
   npm start
   ```

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
| POST | `/api/v1/properties/:id/sold` | Mark property as sold (auto-deletes) |
| GET | `/api/v1/properties/sold-stats` | Get sold properties statistics |
| POST | `/api/v1/properties/cleanup-sold` | Cleanup any remaining sold properties |

### Query Parameters (GET /properties)

- `page` - Page number (default: 1)
- `limit` - Items per page (default: 10, max: 100)
- `sort` - Sort field (price, -price, createdAt, -createdAt, title, -title)
- `status` - Filter by status (active, pending, sold)
- `minPrice` - Minimum price filter
- `maxPrice` - Maximum price filter
- `bedrooms` - Filter by number of bedrooms
- `bathrooms` - Filter by number of bathrooms
- `propertyType` - Filter by property type
- `city` - Filter by city (case-insensitive)
- `state` - Filter by state (case-insensitive)
- `search` - Search in title, address, description

### Example Requests

#### Get Properties with Filters
```bash
GET /api/v1/properties?status=active&minPrice=100000&maxPrice=500000&bedrooms=3&page=1&limit=10
```

#### Create Property with Image
```bash
POST /api/v1/properties
Content-Type: multipart/form-data

{
  "title": "Beautiful Family Home",
  "address": "123 Main St, City, State",
  "price": 350000,
  "description": "A lovely home perfect for families",
  "bedrooms": 3,
  "bathrooms": 2,
  "status": "active",
  "propertyType": "house",
  "image": [file]
}
```

## Property Data Model

```javascript
{
  "id": "uuid-v4-string",
  "title": "Property Title",
  "address": "Full Address",
  "price": 350000,
  "description": "Property description",
  "imageUrl": "https://cloudinary-url",
  "cloudinaryPublicId": "cloudinary-public-id",
  "bedrooms": 3,
  "bathrooms": 2,
  "status": "active", // active, pending, sold
  "squareFootage": 1500,
  "yearBuilt": 2020,
  "propertyType": "house", // house, apartment, condo, townhouse, villa, land, commercial
  "features": ["garage", "pool", "garden"],
  "location": {
    "coordinates": [-122.4194, 37.7749], // [longitude, latitude]
    "city": "San Francisco",
    "state": "CA",
    "zipCode": "94102",
    "country": "US"
  },
  "createdAt": "2024-01-01T00:00:00.000Z",
  "updatedAt": "2024-01-01T00:00:00.000Z"
}
```

## Sold Property Auto-Deletion

### Overview

When a property status is changed to "sold", the system automatically:

1. **Removes the property** from the database
2. **Deletes the associated image** from Cloudinary
3. **Logs the transaction** for analytics and record-keeping
4. **Returns confirmation** of the sale and removal

### How It Works

#### Automatic Deletion Triggers

1. **Status Update**: When `PUT /api/v1/properties/:id` is called with `status: "sold"`
2. **Direct Sale**: When `POST /api/v1/properties/:id/sold` is called
3. **Batch Cleanup**: When `POST /api/v1/properties/cleanup-sold` is called

#### Database Middleware

The Property model includes pre-save and pre-update middleware that:
- Detects when status changes to "sold"
- Automatically deletes the Cloudinary image
- Removes the property from the database
- Logs the transaction

#### Sale Logging

All sold properties are logged to `backend/logs/sold-properties.log` with:
- Complete property details
- Sale timestamp
- Cloudinary image information
- Transaction metadata

### API Endpoints for Sold Properties

#### Mark Property as Sold
```bash
POST /api/v1/properties/{id}/sold
```

**Response:**
```json
{
  "success": true,
  "message": "Property marked as sold and automatically removed from listings",
  "data": {
    "id": "property-uuid",
    "title": "Property Title",
    "price": 450000
  }
}
```

#### Get Sold Properties Statistics
```bash
GET /api/v1/properties/sold-stats?days=30
```

**Response:**
```json
{
  "success": true,
  "data": {
    "period": "Last 30 days",
    "totalSales": 5,
    "totalValue": 2250000,
    "averagePrice": 450000,
    "salesByType": {
      "house": 3,
      "apartment": 2
    },
    "salesByMonth": {
      "2024-01": 3,
      "2024-02": 2
    },
    "recentSales": [...]
  }
}
```

#### Cleanup Remaining Sold Properties
```bash
POST /api/v1/properties/cleanup-sold
```

This endpoint manually cleans up any properties that might have the "sold" status but weren't automatically deleted.

### Scheduled Cleanup

Run the cleanup script manually or as a cron job:

```bash
# Manual cleanup
npm run cleanup-sold

# Or directly
node scripts/cleanup-sold-properties.js
```

### Cron Job Example

Add to your crontab for daily cleanup at 2 AM:
```bash
0 2 * * * cd /path/to/backend && npm run cleanup-sold
```

### Sale Records

Sold properties are logged with complete details for:
- **Analytics**: Track sales performance and trends
- **Reporting**: Generate sales reports and statistics
- **Audit Trail**: Maintain records of all transactions
- **Recovery**: Restore property data if needed

### Configuration

The sold property system works automatically with no configuration needed. However, you can:

1. **Disable Auto-Deletion**: Modify the Property model middleware
2. **Change Log Location**: Update `soldPropertyLogger.js`
3. **Customize Logging**: Modify the logging format and fields
4. **Add Notifications**: Integrate with email/SMS services

### Important Notes

⚠️ **Data Loss Warning**: Once a property is marked as sold, it is permanently deleted from the database and Cloudinary. Only log records remain.

✅ **Backup Strategy**: Consider implementing a backup system or archive database for sold properties if you need to retain the data.

🔄 **Immediate Effect**: The deletion happens immediately when the status changes - there's no undo functionality.

## Image Management

### Cloudinary Features

- **Automatic Optimization** - Images are automatically compressed and optimized
- **Multiple Formats** - Supports JPG, PNG, WebP with auto-format selection
- **Responsive Images** - Multiple size variants generated automatically
- **Smart Naming** - Images named with property ID and timestamp for easy retrieval
- **Secure Upload** - File type validation and size limits (10MB max)

### Image Variants

When an image is uploaded, multiple optimized variants are created:

- **Thumbnail**: 300x200px
- **Medium**: 600x400px  
- **Large**: 1200x800px
- **Original**: Full resolution

### Image Naming Convention

```
estate-manager/properties/property-{propertyId}-{timestamp}
```

Example: `estate-manager/properties/property-123e4567-e89b-12d3-a456-426614174000-1704067200000`

## Error Handling

The API returns consistent error responses:

```javascript
{
  "success": false,
  "message": "Error description",
  "errors": [
    {
      "field": "fieldName",
      "message": "Specific error message"
    }
  ],
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

## Security Features

- **Helmet** - Security headers
- **CORS** - Cross-origin resource sharing
- **Rate Limiting** - Prevents abuse
- **Input Validation** - Joi schema validation
- **File Upload Security** - Type and size validation
- **Error Sanitization** - No sensitive data in error responses

## Performance Optimizations

- **Database Indexing** - Optimized queries for common filters
- **Image Compression** - Automatic Cloudinary optimization
- **Response Compression** - Gzip compression
- **Pagination** - Efficient data loading
- **Lean Queries** - Reduced memory usage

## Development

### Project Structure

```
backend/
├── config/
│   └── cloudinary.js          # Cloudinary configuration
├── controllers/
│   └── propertyController.js  # Property business logic
├── middleware/
│   ├── errorMiddleware.js     # Error handling
│   └── validation.js          # Input validation
├── models/
│   └── Property.js            # MongoDB schema
├── routes/
│   └── propertyRoutes.js      # API routes
├── .env.example               # Environment template
├── package.json               # Dependencies
├── server.js                  # Application entry point
└── README.md                  # This file
```

### Scripts

```bash
npm start          # Start production server
npm run dev        # Start development server with nodemon
npm test           # Run tests (when implemented)
```

## Deployment

### Environment Variables

Ensure all required environment variables are set:

- `PORT` - Server port
- `NODE_ENV` - Environment (production/development)
- `MONGODB_URI` - MongoDB connection string
- `CLOUDINARY_CLOUD_NAME` - Cloudinary cloud name
- `CLOUDINARY_API_KEY` - Cloudinary API key
- `CLOUDINARY_API_SECRET` - Cloudinary API secret

### Production Considerations

1. **Database** - Use MongoDB Atlas or similar cloud service
2. **Images** - Cloudinary handles CDN and optimization
3. **Monitoring** - Add logging and monitoring services
4. **SSL** - Use HTTPS in production
5. **Process Management** - Use PM2 or similar for process management

## Flutter Integration

### Update Flutter App

1. **Add HTTP Package**
   ```yaml
   dependencies:
     http: ^1.1.0
   ```

2. **Create API Repository**
   ```dart
   class ApiPropertyRepository implements PropertyRepository {
     final String baseUrl = 'http://your-api-url/api/v1';
     
     @override
     Future<List<PropertyModel>> getProperties() async {
       final response = await http.get(Uri.parse('$baseUrl/properties'));
       // Handle response and convert to PropertyModel list
     }
   }
   ```

3. **Update Dependency Injection**
   ```dart
   Provider<PropertyRepository>(
     create: (_) => ApiPropertyRepository(), // Replace MockPropertyRepository
   ),
   ```

## Support

For issues and questions:
1. Check the API documentation above
2. Verify environment configuration
3. Check server logs for detailed error information
4. Ensure Cloudinary credentials are correct