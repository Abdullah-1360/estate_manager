const mongoose = require('mongoose');

const propertySchema = new mongoose.Schema({
  id: {
    type: String,
    required: true,
    unique: true,
    index: true,
  },
  title: {
    type: String,
    required: [true, 'Property title is required'],
    trim: true,
    maxlength: [200, 'Title cannot exceed 200 characters'],
  },
  address: {
    type: String,
    required: [true, 'Property address is required'],
    trim: true,
    maxlength: [500, 'Address cannot exceed 500 characters'],
  },
  price: {
    type: Number,
    required: [true, 'Property price is required'],
    min: [0, 'Price cannot be negative'],
  },
  description: {
    type: String,
    required: [true, 'Property description is required'],
    trim: true,
    maxlength: [2000, 'Description cannot exceed 2000 characters'],
  },
  imageUrl: {
    type: String,
    required: [true, 'Property image is required'],
    trim: true,
  },
  cloudinaryPublicId: {
    type: String,
    trim: true,
  },
  bedrooms: {
    type: Number,
    required: [true, 'Number of bedrooms is required'],
    min: [0, 'Bedrooms cannot be negative'],
    max: [50, 'Bedrooms cannot exceed 50'],
  },
  bathrooms: {
    type: Number,
    required: [true, 'Number of bathrooms is required'],
    min: [0, 'Bathrooms cannot be negative'],
    max: [50, 'Bathrooms cannot exceed 50'],
  },
  status: {
    type: String,
    required: [true, 'Property status is required'],
    enum: {
      values: ['active', 'pending', 'sold'],
      message: 'Status must be either active, pending, or sold',
    },
    default: 'active',
  },
  squareFootage: {
    type: Number,
    min: [0, 'Square footage cannot be negative'],
  },
  yearBuilt: {
    type: Number,
    min: [1800, 'Year built cannot be before 1800'],
    max: [new Date().getFullYear() + 5, 'Year built cannot be more than 5 years in the future'],
  },
  propertyType: {
    type: String,
    enum: ['house', 'apartment', 'condo', 'townhouse', 'villa', 'land', 'commercial'],
    default: 'house',
  },
  features: [{
    type: String,
    trim: true,
  }],
  location: {
    coordinates: {
      type: [Number], // [longitude, latitude]
      index: '2dsphere',
    },
    city: {
      type: String,
      trim: true,
    },
    state: {
      type: String,
      trim: true,
    },
    zipCode: {
      type: String,
      trim: true,
    },
    country: {
      type: String,
      trim: true,
      default: 'US',
    },
  },
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true },
});

// Indexes for better query performance
propertySchema.index({ status: 1 });
propertySchema.index({ price: 1 });
propertySchema.index({ bedrooms: 1 });
propertySchema.index({ bathrooms: 1 });
propertySchema.index({ propertyType: 1 });
propertySchema.index({ 'location.city': 1 });
propertySchema.index({ createdAt: -1 });

// Virtual for formatted price
propertySchema.virtual('formattedPrice').get(function() {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
  }).format(this.price);
});

// Virtual for property age
propertySchema.virtual('propertyAge').get(function() {
  if (this.yearBuilt) {
    return new Date().getFullYear() - this.yearBuilt;
  }
  return null;
});

// Pre-save middleware to generate unique ID if not provided
propertySchema.pre('save', function(next) {
  if (!this.id) {
    const { v4: uuidv4 } = require('uuid');
    this.id = uuidv4();
  }
  next();
});

// Static method to find properties by status
propertySchema.statics.findByStatus = function(status) {
  return this.find({ status });
};

// Static method to find properties within price range
propertySchema.statics.findByPriceRange = function(minPrice, maxPrice) {
  return this.find({
    price: {
      $gte: minPrice || 0,
      $lte: maxPrice || Number.MAX_SAFE_INTEGER,
    },
  });
};

// Instance method to update status
propertySchema.methods.updateStatus = function(newStatus) {
  this.status = newStatus;
  return this.save();
};

module.exports = mongoose.model('Property', propertySchema);