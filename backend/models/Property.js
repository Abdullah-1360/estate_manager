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
  imageUrls: [{
    type: String,
    trim: true,
  }],
  cloudinaryPublicIds: [{
    type: String,
    trim: true,
  }],
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

// Pre-save middleware to handle sold properties
propertySchema.pre('save', async function(next) {
  // Check if status is being changed to 'sold'
  if (this.isModified('status') && this.status === 'sold') {
    // Mark for deletion after save
    this._shouldDelete = true;
  }
  next();
});

// Post-save middleware to delete sold properties
propertySchema.post('save', async function(doc) {
  if (doc._shouldDelete) {
    try {
      const { deleteImage } = require('../config/cloudinary');
      
      // Delete images from Cloudinary if exists
      if (doc.cloudinaryPublicIds && doc.cloudinaryPublicIds.length > 0) {
        for (const publicId of doc.cloudinaryPublicIds) {
          try {
            await deleteImage(publicId);
            console.log(`Deleted image from Cloudinary: ${publicId}`);
          } catch (deleteError) {
            console.error('Error deleting image from Cloudinary:', deleteError);
          }
        }
      }
      
      // Delete the property from database
      await this.model('Property').findByIdAndDelete(doc._id);
      console.log(`Auto-deleted sold property: ${doc.title} (ID: ${doc.id})`);
      
    } catch (error) {
      console.error('Error auto-deleting sold property:', error);
    }
  }
});

// Pre-findOneAndUpdate middleware to handle sold properties
propertySchema.pre('findOneAndUpdate', async function(next) {
  const update = this.getUpdate();
  
  // Check if status is being updated to 'sold'
  if (update && (update.status === 'sold' || (update.$set && update.$set.status === 'sold'))) {
    // Get the document before update to access cloudinaryPublicId
    const doc = await this.model.findOne(this.getQuery());
    
    if (doc) {
      try {
        const { deleteImage } = require('../config/cloudinary');
        
        // Delete images from Cloudinary if exists
        if (doc.cloudinaryPublicIds && doc.cloudinaryPublicIds.length > 0) {
          for (const publicId of doc.cloudinaryPublicIds) {
            try {
              await deleteImage(publicId);
              console.log(`Deleted image from Cloudinary: ${publicId}`);
            } catch (deleteError) {
              console.error('Error deleting image from Cloudinary:', deleteError);
            }
          }
        }
        
        // Instead of updating, delete the document
        await this.model.findOneAndDelete(this.getQuery());
        console.log(`Auto-deleted sold property: ${doc.title} (ID: ${doc.id})`);
        
        // Prevent the original update from executing
        return next(new Error('PROPERTY_DELETED'));
        
      } catch (error) {
        console.error('Error auto-deleting sold property:', error);
        return next(error);
      }
    }
  }
  
  next();
});

module.exports = mongoose.model('Property', propertySchema);