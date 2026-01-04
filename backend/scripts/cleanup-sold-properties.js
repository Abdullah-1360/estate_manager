const mongoose = require('mongoose');
const SoldPropertyService = require('../services/soldPropertyService');
require('dotenv').config();

/**
 * Scheduled job to cleanup sold properties
 * This can be run as a cron job or scheduled task
 */
async function cleanupSoldPropertiesJob() {
  try {
    console.log('🧹 Starting sold properties cleanup job...');
    
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/estate_manager');
    console.log('✅ Connected to MongoDB');

    // Run cleanup
    const result = await SoldPropertyService.cleanupSoldProperties();
    
    console.log('✅ Cleanup completed:');
    console.log(`   - Properties removed: ${result.count}`);
    console.log(`   - Message: ${result.message}`);
    
    if (result.errors && result.errors.length > 0) {
      console.log('⚠️  Errors encountered:');
      result.errors.forEach(error => {
        console.log(`   - ${error.propertyId} (${error.title}): ${error.error}`);
      });
    }

    process.exit(0);
  } catch (error) {
    console.error('❌ Error during cleanup job:', error);
    process.exit(1);
  }
}

// Run the cleanup job
cleanupSoldPropertiesJob();