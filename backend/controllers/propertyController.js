const Property = require('../models/Property');
const { deleteImage, getImageVariants } = require('../config/cloudinary');
const { v4: uuidv4 } = require('uuid');

// @desc    Get all properties
// @route   GET /api/v1/properties
// @access  Public
const getProperties = async (req, res) => {
  try {
    const {
      page,
      limit,
      sort,
      status,
      minPrice,
      maxPrice,
      bedrooms,
      bathrooms,
      propertyType,
      city,
      state,
      search,
    } = req.query;

    // Build filter object
    const filter = {};

    if (status) filter.status = status;
    if (propertyType) filter.propertyType = propertyType;
    if (bedrooms) filter.bedrooms = bedrooms;
    if (bathrooms) filter.bathrooms = bathrooms;
    if (city) filter['location.city'] = new RegExp(city, 'i');
    if (state) filter['location.state'] = new RegExp(state, 'i');

    // Price range filter
    if (minPrice || maxPrice) {
      filter.price = {};
      if (minPrice) filter.price.$gte = minPrice;
      if (maxPrice) filter.price.$lte = maxPrice;
    }

    // Search filter (title, address, description)
    if (search) {
      filter.$or = [
        { title: new RegExp(search, 'i') },
        { address: new RegExp(search, 'i') },
        { description: new RegExp(search, 'i') },
      ];
    }

    // Calculate pagination
    const skip = (page - 1) * limit;

    // Execute query with pagination and sorting
    const properties = await Property.find(filter)
      .sort(sort)
      .skip(skip)
      .limit(limit)
      .lean();

    // Get total count for pagination
    const total = await Property.countDocuments(filter);

    // Calculate pagination info
    const totalPages = Math.ceil(total / limit);
    const hasNextPage = page < totalPages;
    const hasPrevPage = page > 1;

    res.status(200).json({
      success: true,
      data: properties,
      pagination: {
        currentPage: page,
        totalPages,
        totalItems: total,
        itemsPerPage: limit,
        hasNextPage,
        hasPrevPage,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching properties',
      error: error.message,
    });
  }
};

// @desc    Get single property
// @route   GET /api/v1/properties/:id
// @access  Public
const getProperty = async (req, res) => {
  try {
    const property = await Property.findOne({ id: req.params.id });

    if (!property) {
      return res.status(404).json({
        success: false,
        message: 'Property not found',
      });
    }

    res.status(200).json({
      success: true,
      data: property,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching property',
      error: error.message,
    });
  }
};

// @desc    Create new property
// @route   POST /api/v1/properties
// @access  Public
const createProperty = async (req, res) => {
  try {
    // Generate unique ID if not provided
    if (!req.body.id) {
      req.body.id = uuidv4();
    }

    // Handle image upload
    if (req.file) {
      req.body.imageUrl = req.file.path;
      req.body.cloudinaryPublicId = req.file.filename;
    }

    const property = await Property.create(req.body);

    res.status(201).json({
      success: true,
      message: 'Property created successfully',
      data: property,
    });
  } catch (error) {
    // If property creation fails and image was uploaded, delete the image
    if (req.file && req.file.filename) {
      try {
        await deleteImage(req.file.filename);
      } catch (deleteError) {
        console.error('Error deleting uploaded image:', deleteError);
      }
    }

    res.status(400).json({
      success: false,
      message: 'Error creating property',
      error: error.message,
    });
  }
};

// @desc    Update property
// @route   PUT /api/v1/properties/:id
// @access  Public
const updateProperty = async (req, res) => {
  try {
    const property = await Property.findOne({ id: req.params.id });

    if (!property) {
      return res.status(404).json({
        success: false,
        message: 'Property not found',
      });
    }

    let oldImagePublicId = null;

    // Handle new image upload
    if (req.file) {
      oldImagePublicId = property.cloudinaryPublicId;
      req.body.imageUrl = req.file.path;
      req.body.cloudinaryPublicId = req.file.filename;
    }

    // Update property
    const updatedProperty = await Property.findOneAndUpdate(
      { id: req.params.id },
      req.body,
      { new: true, runValidators: true }
    );

    // Delete old image if new image was uploaded
    if (oldImagePublicId && req.file) {
      try {
        await deleteImage(oldImagePublicId);
      } catch (deleteError) {
        console.error('Error deleting old image:', deleteError);
      }
    }

    res.status(200).json({
      success: true,
      message: 'Property updated successfully',
      data: updatedProperty,
    });
  } catch (error) {
    // If update fails and new image was uploaded, delete the new image
    if (req.file && req.file.filename) {
      try {
        await deleteImage(req.file.filename);
      } catch (deleteError) {
        console.error('Error deleting uploaded image:', deleteError);
      }
    }

    res.status(400).json({
      success: false,
      message: 'Error updating property',
      error: error.message,
    });
  }
};

// @desc    Delete property
// @route   DELETE /api/v1/properties/:id
// @access  Public
const deleteProperty = async (req, res) => {
  try {
    const property = await Property.findOne({ id: req.params.id });

    if (!property) {
      return res.status(404).json({
        success: false,
        message: 'Property not found',
      });
    }

    // Delete image from Cloudinary if exists
    if (property.cloudinaryPublicId) {
      try {
        await deleteImage(property.cloudinaryPublicId);
      } catch (deleteError) {
        console.error('Error deleting image from Cloudinary:', deleteError);
      }
    }

    // Delete property from database
    await Property.findOneAndDelete({ id: req.params.id });

    res.status(200).json({
      success: true,
      message: 'Property deleted successfully',
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error deleting property',
      error: error.message,
    });
  }
};

// @desc    Upload property image
// @route   POST /api/v1/properties/:id/image
// @access  Public
const uploadPropertyImage = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'No image file provided',
      });
    }

    const property = await Property.findOne({ id: req.params.id });

    if (!property) {
      // Delete uploaded image if property not found
      try {
        await deleteImage(req.file.filename);
      } catch (deleteError) {
        console.error('Error deleting uploaded image:', deleteError);
      }

      return res.status(404).json({
        success: false,
        message: 'Property not found',
      });
    }

    const oldImagePublicId = property.cloudinaryPublicId;

    // Update property with new image
    property.imageUrl = req.file.path;
    property.cloudinaryPublicId = req.file.filename;
    await property.save();

    // Delete old image if exists
    if (oldImagePublicId) {
      try {
        await deleteImage(oldImagePublicId);
      } catch (deleteError) {
        console.error('Error deleting old image:', deleteError);
      }
    }

    // Generate image variants
    const imageVariants = getImageVariants(req.file.filename);

    res.status(200).json({
      success: true,
      message: 'Image uploaded successfully',
      data: {
        imageUrl: req.file.path,
        publicId: req.file.filename,
        variants: imageVariants,
      },
    });
  } catch (error) {
    // Delete uploaded image if update fails
    if (req.file && req.file.filename) {
      try {
        await deleteImage(req.file.filename);
      } catch (deleteError) {
        console.error('Error deleting uploaded image:', deleteError);
      }
    }

    res.status(500).json({
      success: false,
      message: 'Error uploading image',
      error: error.message,
    });
  }
};

// @desc    Get property statistics
// @route   GET /api/v1/properties/stats
// @access  Public
const getPropertyStats = async (req, res) => {
  try {
    const stats = await Property.aggregate([
      {
        $group: {
          _id: null,
          totalProperties: { $sum: 1 },
          averagePrice: { $avg: '$price' },
          minPrice: { $min: '$price' },
          maxPrice: { $max: '$price' },
          activeProperties: {
            $sum: { $cond: [{ $eq: ['$status', 'active'] }, 1, 0] }
          },
          pendingProperties: {
            $sum: { $cond: [{ $eq: ['$status', 'pending'] }, 1, 0] }
          },
          soldProperties: {
            $sum: { $cond: [{ $eq: ['$status', 'sold'] }, 1, 0] }
          },
        }
      }
    ]);

    const propertyTypeStats = await Property.aggregate([
      {
        $group: {
          _id: '$propertyType',
          count: { $sum: 1 },
          averagePrice: { $avg: '$price' }
        }
      },
      { $sort: { count: -1 } }
    ]);

    res.status(200).json({
      success: true,
      data: {
        overview: stats[0] || {
          totalProperties: 0,
          averagePrice: 0,
          minPrice: 0,
          maxPrice: 0,
          activeProperties: 0,
          pendingProperties: 0,
          soldProperties: 0,
        },
        propertyTypes: propertyTypeStats,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching property statistics',
      error: error.message,
    });
  }
};

module.exports = {
  getProperties,
  getProperty,
  createProperty,
  updateProperty,
  deleteProperty,
  uploadPropertyImage,
  getPropertyStats,
};