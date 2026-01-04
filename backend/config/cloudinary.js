const cloudinary = require('cloudinary').v2;
const { CloudinaryStorage } = require('multer-storage-cloudinary');
const multer = require('multer');

// Configure Cloudinary
cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
});

// Create Cloudinary storage for multer
const storage = new CloudinaryStorage({
  cloudinary: cloudinary,
  params: {
    folder: 'estate-manager/properties',
    allowed_formats: ['jpg', 'jpeg', 'png', 'webp'],
    transformation: [
      { width: 1200, height: 800, crop: 'fill', quality: 'auto' },
      { fetch_format: 'auto' }
    ],
    public_id: (req, file) => {
      // Generate a unique filename based on property info
      const timestamp = Date.now();
      const propertyId = req.body.propertyId || req.params.id || 'unknown';
      return `property-${propertyId}-${timestamp}`;
    },
  },
});

// Configure multer with Cloudinary storage
const upload = multer({
  storage: storage,
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB limit
  },
  fileFilter: (req, file, cb) => {
    // Check file type
    if (file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('Only image files are allowed!'), false);
    }
  },
});

// Helper function to delete image from Cloudinary
const deleteImage = async (publicId) => {
  try {
    const result = await cloudinary.uploader.destroy(publicId);
    return result;
  } catch (error) {
    console.error('Error deleting image from Cloudinary:', error);
    throw error;
  }
};

// Helper function to generate optimized image URLs
const getOptimizedImageUrl = (publicId, options = {}) => {
  const defaultOptions = {
    width: 800,
    height: 600,
    crop: 'fill',
    quality: 'auto',
    fetch_format: 'auto',
  };
  
  const finalOptions = { ...defaultOptions, ...options };
  
  return cloudinary.url(publicId, finalOptions);
};

// Helper function to generate multiple image sizes
const getImageVariants = (publicId) => {
  return {
    thumbnail: getOptimizedImageUrl(publicId, { width: 300, height: 200 }),
    medium: getOptimizedImageUrl(publicId, { width: 600, height: 400 }),
    large: getOptimizedImageUrl(publicId, { width: 1200, height: 800 }),
    original: cloudinary.url(publicId),
  };
};

module.exports = {
  cloudinary,
  upload,
  deleteImage,
  getOptimizedImageUrl,
  getImageVariants,
};