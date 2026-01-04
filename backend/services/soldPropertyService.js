const Property = require('../models/Property');
const { deleteImage } = require('../config/cloudinary');

/**
 * Service for handling sold properties and their automatic cleanup
 */
class SoldPropertyService {
  /**
   * Mark a property as sold and automatically remove it
   * @param {string} propertyId - The property ID
   * @returns {Promise<Object>} Result of the operation
   */
  static async markAsSold(propertyId) {
    try {
      const property = await Property.findOne({ id: propertyId });

      if (!property) {
        throw new Error('Property not found');
      }

      if (property.status === 'sold') {
        throw new Error('Property is already marked as sold');
      }

      // Store property info for logging
      const propertyInfo = {
        id: property.id,
        title: property.title,
        price: property.price,
        cloudinaryPublicId: property.cloudinaryPublicId,
      };

      // Delete image from Cloudinary if exists
      if (property.cloudinaryPublicId) {
        try {
          await deleteImage(property.cloudinaryPublicId);
          console.log(`Deleted image from Cloudinary: ${property.cloudinaryPublicId}`);
        } catch (deleteError) {
          console.error('Error deleting image from Cloudinary:', deleteError);
          // Continue with property deletion even if image deletion fails
        }
      }

      // Delete the property from database
      await Property.findOneAndDelete({ id: propertyId });

      console.log(`Property marked as sold and removed: ${propertyInfo.title} (ID: ${propertyInfo.id})`);

      return {
        success: true,
        message: 'Property marked as sold and removed from listings',
        propertyInfo: {
          id: propertyInfo.id,
          title: propertyInfo.title,
          price: propertyInfo.price,
        },
      };
    } catch (error) {
      console.error('Error marking property as sold:', error);
      throw error;
    }
  }

  /**
   * Get statistics about sold properties (from logs or external tracking)
   * This is a placeholder for future implementation
   * @returns {Promise<Object>} Sold properties statistics
   */
  static async getSoldPropertiesStats() {
    // In a real implementation, you might want to:
    // 1. Store sold properties in a separate collection before deletion
    // 2. Keep logs of sold properties
    // 3. Track sales metrics
    
    return {
      message: 'Sold properties are automatically removed from the system',
      note: 'Consider implementing a sales tracking system for analytics',
    };
  }

  /**
   * Batch cleanup of properties marked as sold
   * This can be used as a scheduled job
   * @returns {Promise<Object>} Cleanup results
   */
  static async cleanupSoldProperties() {
    try {
      const soldProperties = await Property.find({ status: 'sold' });
      
      if (soldProperties.length === 0) {
        return {
          success: true,
          message: 'No sold properties found to cleanup',
          count: 0,
        };
      }

      let cleanedCount = 0;
      const errors = [];

      for (const property of soldProperties) {
        try {
          // Delete image from Cloudinary if exists
          if (property.cloudinaryPublicId) {
            try {
              await deleteImage(property.cloudinaryPublicId);
            } catch (deleteError) {
              console.error(`Error deleting image ${property.cloudinaryPublicId}:`, deleteError);
            }
          }

          // Delete property from database
          await Property.findByIdAndDelete(property._id);
          cleanedCount++;
          
          console.log(`Cleaned up sold property: ${property.title} (ID: ${property.id})`);
        } catch (error) {
          errors.push({
            propertyId: property.id,
            title: property.title,
            error: error.message,
          });
        }
      }

      return {
        success: true,
        message: `Cleanup completed. Removed ${cleanedCount} sold properties`,
        count: cleanedCount,
        errors: errors.length > 0 ? errors : undefined,
      };
    } catch (error) {
      console.error('Error during sold properties cleanup:', error);
      throw error;
    }
  }
}

module.exports = SoldPropertyService;