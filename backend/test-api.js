const axios = require('axios');
const FormData = require('form-data');
const fs = require('fs');
const path = require('path');

const BASE_URL = 'http://localhost:3000/api/v1';

async function testAPI() {
  try {
    console.log('Testing Estate Manager API...\n');

    // Test 1: Health check
    console.log('1. Testing health check...');
    const healthResponse = await axios.get('http://localhost:3000/health');
    console.log('✅ Health check passed:', healthResponse.data.status);

    // Test 2: Get properties
    console.log('\n2. Testing get properties...');
    const propertiesResponse = await axios.get(`${BASE_URL}/properties`);
    console.log('✅ Get properties passed. Count:', propertiesResponse.data.data.length);

    // Test 3: Create property without images
    console.log('\n3. Testing create property without images...');
    const newProperty = {
      title: 'Test Property',
      address: '123 Test Street, Test City',
      price: 250000,
      description: 'A beautiful test property',
      bedrooms: 3,
      bathrooms: 2,
      status: 'active',
      propertyType: 'house'
    };

    const createResponse = await axios.post(`${BASE_URL}/properties`, newProperty);
    console.log('✅ Create property passed. ID:', createResponse.data.data.id);
    const propertyId = createResponse.data.data.id;

    // Test 4: Get single property
    console.log('\n4. Testing get single property...');
    const singlePropertyResponse = await axios.get(`${BASE_URL}/properties/${propertyId}`);
    console.log('✅ Get single property passed:', singlePropertyResponse.data.data.title);

    // Test 5: Update property
    console.log('\n5. Testing update property...');
    const updateData = {
      title: 'Updated Test Property',
      price: 275000
    };
    const updateResponse = await axios.put(`${BASE_URL}/properties/${propertyId}`, updateData);
    console.log('✅ Update property passed:', updateResponse.data.data.title);

    // Test 6: Get property stats
    console.log('\n6. Testing property stats...');
    const statsResponse = await axios.get(`${BASE_URL}/properties/stats`);
    console.log('✅ Property stats passed. Total properties:', statsResponse.data.data.overview.totalProperties);

    // Test 7: Delete property
    console.log('\n7. Testing delete property...');
    const deleteResponse = await axios.delete(`${BASE_URL}/properties/${propertyId}`);
    console.log('✅ Delete property passed:', deleteResponse.data.message);

    console.log('\n🎉 All API tests passed successfully!');

  } catch (error) {
    console.error('❌ API test failed:', error.response?.data || error.message);
    process.exit(1);
  }
}

// Run tests
testAPI();