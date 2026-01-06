const mongoose = require('mongoose');
require('dotenv').config();

// Connect to MongoDB
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/estate_manager')
  .then(() => {
    console.log('Connected to MongoDB');
    migrateImages();
  })
  .catch((error) => {
    console.error('Database connection error:', error);
    process.exit(1);
  });

async function migrateImages() {
  try {
    const db = mongoose.connection.db;
    const collection = db.collection('properties');
    
    // Find all properties with old imageUrl field
    const properties = await collection.find({
      $or: [
        { imageUrl: { $exists: true } },
        { cloudinaryPublicId: { $exists: true } }
      ]
    }).toArray();
    
    console.log(`Found ${properties.length} properties to migrate`);
    
    for (const property of properties) {
      const updateData = {};
      
      // Migrate imageUrl to imageUrls array
      if (property.imageUrl) {
        updateData.imageUrls = [property.imageUrl];
        updateData.$unset = { imageUrl: "" };
      }
      
      // Migrate cloudinaryPublicId to cloudinaryPublicIds array
      if (property.cloudinaryPublicId) {
        updateData.cloudinaryPublicIds = [property.cloudinaryPublicId];
        if (!updateData.$unset) updateData.$unset = {};
        updateData.$unset.cloudinaryPublicId = "";
      }
      
      if (Object.keys(updateData).length > 0) {
        await collection.updateOne(
          { _id: property._id },
          updateData
        );
        console.log(`Migrated property: ${property.title || property.id}`);
      }
    }
    
    console.log('Migration completed successfully');
    process.exit(0);
  } catch (error) {
    console.error('Migration error:', error);
    process.exit(1);
  }
}