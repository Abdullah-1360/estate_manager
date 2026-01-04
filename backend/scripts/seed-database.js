const mongoose = require('mongoose');
const { v4: uuidv4 } = require('uuid');
require('dotenv').config();

const Property = require('../models/Property');

const sampleProperties = [
  {
    id: uuidv4(),
    title: 'Modern Downtown Apartment',
    address: '123 Main Street, Downtown, CA 90210',
    price: 450000,
    description: 'A beautiful modern apartment with stunning city views. Features include hardwood floors, stainless steel appliances, and a private balcony. Close to all amenities including shopping, dining, and public transportation.',
    imageUrl: 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?ixlib=rb-4.0.3&auto=format&fit=crop&w=1170&q=80',
    bedrooms: 2,
    bathrooms: 2,
    status: 'active',
    squareFootage: 1200,
    yearBuilt: 2020,
    propertyType: 'apartment',
    features: ['balcony', 'hardwood floors', 'stainless steel appliances', 'city view'],
    location: {
      coordinates: [-118.2437, 34.0522],
      city: 'Los Angeles',
      state: 'CA',
      zipCode: '90210',
      country: 'US',
    },
  },
  {
    id: uuidv4(),
    title: 'Cozy Suburban Family Home',
    address: '456 Oak Avenue, Suburbia, CA 91234',
    price: 320000,
    description: 'Perfect for a small family. This charming home features a large backyard, updated kitchen, and is located in a quiet, family-friendly neighborhood with excellent schools nearby.',
    imageUrl: 'https://images.unsplash.com/photo-1568605114967-8130f3a36994?ixlib=rb-4.0.3&auto=format&fit=crop&w=1170&q=80',
    bedrooms: 3,
    bathrooms: 2,
    status: 'pending',
    squareFootage: 1800,
    yearBuilt: 2015,
    propertyType: 'house',
    features: ['large backyard', 'updated kitchen', 'garage', 'near schools'],
    location: {
      coordinates: [-118.1937, 34.1522],
      city: 'Pasadena',
      state: 'CA',
      zipCode: '91234',
      country: 'US',
    },
  },
  {
    id: uuidv4(),
    title: 'Luxury Beachfront Villa',
    address: '789 Beach Boulevard, Seaside, CA 90401',
    price: 1200000,
    description: 'Exclusive villa with private pool and direct beach access. This stunning property offers panoramic ocean views, a gourmet kitchen, and luxurious finishes throughout. Perfect for entertaining.',
    imageUrl: 'https://images.unsplash.com/photo-1613490493576-7fde63acd811?ixlib=rb-4.0.3&auto=format&fit=crop&w=1171&q=80',
    bedrooms: 5,
    bathrooms: 4,
    status: 'active',
    squareFootage: 3500,
    yearBuilt: 2018,
    propertyType: 'villa',
    features: ['private pool', 'beach access', 'ocean view', 'gourmet kitchen', 'luxury finishes'],
    location: {
      coordinates: [-118.4912, 34.0195],
      city: 'Santa Monica',
      state: 'CA',
      zipCode: '90401',
      country: 'US',
    },
  },
  {
    id: uuidv4(),
    title: 'Urban Loft in Arts District',
    address: '321 Industrial Way, Arts District, CA 90013',
    price: 580000,
    description: 'Converted warehouse loft with exposed brick walls, high ceilings, and industrial charm. Located in the heart of the vibrant Arts District with galleries, restaurants, and nightlife.',
    imageUrl: 'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?ixlib=rb-4.0.3&auto=format&fit=crop&w=1170&q=80',
    bedrooms: 1,
    bathrooms: 1,
    status: 'active',
    squareFootage: 1000,
    yearBuilt: 1995,
    propertyType: 'apartment',
    features: ['exposed brick', 'high ceilings', 'industrial design', 'arts district location'],
    location: {
      coordinates: [-118.2353, 34.0391],
      city: 'Los Angeles',
      state: 'CA',
      zipCode: '90013',
      country: 'US',
    },
  },
  {
    id: uuidv4(),
    title: 'Mountain View Townhouse',
    address: '654 Hill Street, Mountain View, CA 94041',
    price: 750000,
    description: 'Three-story townhouse with stunning mountain views. Features include a rooftop deck, modern kitchen, and attached garage. Great for commuters with easy access to tech companies.',
    imageUrl: 'https://images.unsplash.com/photo-1570129477492-45c003edd2be?ixlib=rb-4.0.3&auto=format&fit=crop&w=1170&q=80',
    bedrooms: 3,
    bathrooms: 3,
    status: 'active',
    squareFootage: 2200,
    yearBuilt: 2019,
    propertyType: 'townhouse',
    features: ['mountain view', 'rooftop deck', 'modern kitchen', 'attached garage', 'tech corridor'],
    location: {
      coordinates: [-122.0838, 37.3861],
      city: 'Mountain View',
      state: 'CA',
      zipCode: '94041',
      country: 'US',
    },
  },
  {
    id: uuidv4(),
    title: 'Historic Victorian Home',
    address: '987 Heritage Lane, Historic District, CA 94102',
    price: 890000,
    description: 'Beautifully restored Victorian home with original architectural details. Features include ornate moldings, hardwood floors, and a charming garden. Located in a prestigious historic district.',
    imageUrl: 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?ixlib=rb-4.0.3&auto=format&fit=crop&w=1170&q=80',
    bedrooms: 4,
    bathrooms: 3,
    status: 'sold',
    squareFootage: 2800,
    yearBuilt: 1895,
    propertyType: 'house',
    features: ['victorian architecture', 'original details', 'hardwood floors', 'garden', 'historic district'],
    location: {
      coordinates: [-122.4194, 37.7749],
      city: 'San Francisco',
      state: 'CA',
      zipCode: '94102',
      country: 'US',
    },
  },
];

async function seedDatabase() {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/estate_manager');
    console.log('Connected to MongoDB');

    // Clear existing properties
    await Property.deleteMany({});
    console.log('Cleared existing properties');

    // Insert sample properties
    await Property.insertMany(sampleProperties);
    console.log(`Inserted ${sampleProperties.length} sample properties`);

    console.log('Database seeded successfully!');
    process.exit(0);
  } catch (error) {
    console.error('Error seeding database:', error);
    process.exit(1);
  }
}

// Run the seed function
seedDatabase();