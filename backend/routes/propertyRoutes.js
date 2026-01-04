const express = require('express');
const {
  getProperties,
  getProperty,
  createProperty,
  updateProperty,
  deleteProperty,
  uploadPropertyImage,
  getPropertyStats,
} = require('../controllers/propertyController');
const {
  validateProperty,
  validatePropertyUpdate,
  validateQuery,
} = require('../middleware/validation');
const { upload } = require('../config/cloudinary');

const router = express.Router();

// Property statistics route (must be before /:id routes)
router.get('/stats', getPropertyStats);

// Main property routes
router
  .route('/')
  .get(validateQuery, getProperties)
  .post(upload.single('image'), validateProperty, createProperty);

router
  .route('/:id')
  .get(getProperty)
  .put(upload.single('image'), validatePropertyUpdate, updateProperty)
  .delete(deleteProperty);

// Image upload route
router.post('/:id/image', upload.single('image'), uploadPropertyImage);

module.exports = router;