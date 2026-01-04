const Joi = require('joi');

// Property validation schema
const propertySchema = Joi.object({
  id: Joi.string().uuid().optional(),
  title: Joi.string().trim().min(1).max(200).required().messages({
    'string.empty': 'Title is required',
    'string.max': 'Title cannot exceed 200 characters',
  }),
  address: Joi.string().trim().min(1).max(500).required().messages({
    'string.empty': 'Address is required',
    'string.max': 'Address cannot exceed 500 characters',
  }),
  price: Joi.number().min(0).required().messages({
    'number.base': 'Price must be a number',
    'number.min': 'Price cannot be negative',
    'any.required': 'Price is required',
  }),
  description: Joi.string().trim().min(1).max(2000).required().messages({
    'string.empty': 'Description is required',
    'string.max': 'Description cannot exceed 2000 characters',
  }),
  bedrooms: Joi.number().integer().min(0).max(50).required().messages({
    'number.base': 'Bedrooms must be a number',
    'number.integer': 'Bedrooms must be a whole number',
    'number.min': 'Bedrooms cannot be negative',
    'number.max': 'Bedrooms cannot exceed 50',
    'any.required': 'Number of bedrooms is required',
  }),
  bathrooms: Joi.number().integer().min(0).max(50).required().messages({
    'number.base': 'Bathrooms must be a number',
    'number.integer': 'Bathrooms must be a whole number',
    'number.min': 'Bathrooms cannot be negative',
    'number.max': 'Bathrooms cannot exceed 50',
    'any.required': 'Number of bathrooms is required',
  }),
  status: Joi.string().valid('active', 'pending', 'sold').default('active').messages({
    'any.only': 'Status must be either active, pending, or sold',
  }),
  squareFootage: Joi.number().min(0).optional().messages({
    'number.base': 'Square footage must be a number',
    'number.min': 'Square footage cannot be negative',
  }),
  yearBuilt: Joi.number().integer().min(1800).max(new Date().getFullYear() + 5).optional().messages({
    'number.base': 'Year built must be a number',
    'number.integer': 'Year built must be a whole number',
    'number.min': 'Year built cannot be before 1800',
    'number.max': 'Year built cannot be more than 5 years in the future',
  }),
  propertyType: Joi.string().valid('house', 'apartment', 'condo', 'townhouse', 'villa', 'land', 'commercial').default('house').messages({
    'any.only': 'Property type must be one of: house, apartment, condo, townhouse, villa, land, commercial',
  }),
  features: Joi.array().items(Joi.string().trim()).optional(),
  location: Joi.object({
    coordinates: Joi.array().items(Joi.number()).length(2).optional(),
    city: Joi.string().trim().optional(),
    state: Joi.string().trim().optional(),
    zipCode: Joi.string().trim().optional(),
    country: Joi.string().trim().default('US').optional(),
  }).optional(),
});

// Property update schema (all fields optional except id)
const propertyUpdateSchema = Joi.object({
  title: Joi.string().trim().min(1).max(200).optional(),
  address: Joi.string().trim().min(1).max(500).optional(),
  price: Joi.number().min(0).optional(),
  description: Joi.string().trim().min(1).max(2000).optional(),
  bedrooms: Joi.number().integer().min(0).max(50).optional(),
  bathrooms: Joi.number().integer().min(0).max(50).optional(),
  status: Joi.string().valid('active', 'pending', 'sold').optional(),
  squareFootage: Joi.number().min(0).optional(),
  yearBuilt: Joi.number().integer().min(1800).max(new Date().getFullYear() + 5).optional(),
  propertyType: Joi.string().valid('house', 'apartment', 'condo', 'townhouse', 'villa', 'land', 'commercial').optional(),
  features: Joi.array().items(Joi.string().trim()).optional(),
  location: Joi.object({
    coordinates: Joi.array().items(Joi.number()).length(2).optional(),
    city: Joi.string().trim().optional(),
    state: Joi.string().trim().optional(),
    zipCode: Joi.string().trim().optional(),
    country: Joi.string().trim().optional(),
  }).optional(),
});

// Query parameters validation schema
const querySchema = Joi.object({
  page: Joi.number().integer().min(1).default(1),
  limit: Joi.number().integer().min(1).max(100).default(10),
  sort: Joi.string().valid('price', '-price', 'createdAt', '-createdAt', 'title', '-title').default('-createdAt'),
  status: Joi.string().valid('active', 'pending', 'sold').optional(),
  minPrice: Joi.number().min(0).optional(),
  maxPrice: Joi.number().min(0).optional(),
  bedrooms: Joi.number().integer().min(0).optional(),
  bathrooms: Joi.number().integer().min(0).optional(),
  propertyType: Joi.string().valid('house', 'apartment', 'condo', 'townhouse', 'villa', 'land', 'commercial').optional(),
  city: Joi.string().trim().optional(),
  state: Joi.string().trim().optional(),
  search: Joi.string().trim().optional(),
});

// Validation middleware
const validateProperty = (req, res, next) => {
  const { error, value } = propertySchema.validate(req.body, { abortEarly: false });
  
  if (error) {
    const errors = error.details.map(detail => ({
      field: detail.path.join('.'),
      message: detail.message,
    }));
    
    return res.status(400).json({
      success: false,
      message: 'Validation error',
      errors,
    });
  }
  
  req.body = value;
  next();
};

const validatePropertyUpdate = (req, res, next) => {
  const { error, value } = propertyUpdateSchema.validate(req.body, { abortEarly: false });
  
  if (error) {
    const errors = error.details.map(detail => ({
      field: detail.path.join('.'),
      message: detail.message,
    }));
    
    return res.status(400).json({
      success: false,
      message: 'Validation error',
      errors,
    });
  }
  
  req.body = value;
  next();
};

const validateQuery = (req, res, next) => {
  const { error, value } = querySchema.validate(req.query, { abortEarly: false });
  
  if (error) {
    const errors = error.details.map(detail => ({
      field: detail.path.join('.'),
      message: detail.message,
    }));
    
    return res.status(400).json({
      success: false,
      message: 'Query validation error',
      errors,
    });
  }
  
  req.query = value;
  next();
};

module.exports = {
  validateProperty,
  validatePropertyUpdate,
  validateQuery,
};