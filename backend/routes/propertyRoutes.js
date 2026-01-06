const express = require('express');
const {
  getProperties,
  getProperty,
  createProperty,
  updateProperty,
  deleteProperty,
  uploadPropertyImages,
  getPropertyStats,
  markPropertyAsSold,
  cleanupSoldProperties,
  getSoldPropertiesStats,
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

// Sold properties statistics route
router.get('/sold-stats', getSoldPropertiesStats);

// Cleanup sold properties route (admin endpoint)
router.post('/cleanup-sold', cleanupSoldProperties);

// Main property routes
router
  .route('/')
  .get(validateQuery, getProperties)
  .post(upload.array('images', 10), validateProperty, createProperty);

router
  .route('/:id')
  .get(getProperty)
  .put(upload.array('images', 10), validatePropertyUpdate, updateProperty)
  .delete(deleteProperty);

// Image upload route
router.post('/:id/images', upload.array('images', 10), uploadPropertyImages);

// Mark property as sold route
router.post('/:id/sold', markPropertyAsSold);

module.exports = router;