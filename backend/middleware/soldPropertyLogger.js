const fs = require('fs').promises;
const path = require('path');

/**
 * Middleware to log sold properties before they are deleted
 * This helps maintain a record of sales for analytics and reporting
 */
class SoldPropertyLogger {
  constructor() {
    this.logDir = path.join(__dirname, '../logs');
    this.logFile = path.join(this.logDir, 'sold-properties.log');
    this.ensureLogDirectory();
  }

  async ensureLogDirectory() {
    try {
      await fs.mkdir(this.logDir, { recursive: true });
    } catch (error) {
      console.error('Error creating logs directory:', error);
    }
  }

  /**
   * Log a sold property transaction
   * @param {Object} property - The property being sold
   * @param {string} action - The action taken (e.g., 'MARKED_AS_SOLD', 'AUTO_DELETED')
   */
  async logSoldProperty(property, action = 'SOLD') {
    try {
      const logEntry = {
        timestamp: new Date().toISOString(),
        action,
        property: {
          id: property.id,
          title: property.title,
          address: property.address,
          price: property.price,
          bedrooms: property.bedrooms,
          bathrooms: property.bathrooms,
          propertyType: property.propertyType,
          squareFootage: property.squareFootage,
          yearBuilt: property.yearBuilt,
          features: property.features,
          location: property.location,
          cloudinaryPublicId: property.cloudinaryPublicId,
          createdAt: property.createdAt,
          soldAt: new Date().toISOString(),
        },
      };

      const logLine = JSON.stringify(logEntry) + '\n';
      await fs.appendFile(this.logFile, logLine);
      
      console.log(`📝 Logged sold property: ${property.title} (ID: ${property.id})`);
    } catch (error) {
      console.error('Error logging sold property:', error);
    }
  }

  /**
   * Get sold properties statistics from logs
   * @param {number} days - Number of days to look back (default: 30)
   * @returns {Promise<Object>} Statistics object
   */
  async getSoldPropertiesStats(days = 30) {
    try {
      const logContent = await fs.readFile(this.logFile, 'utf8');
      const lines = logContent.trim().split('\n').filter(line => line);
      
      const cutoffDate = new Date();
      cutoffDate.setDate(cutoffDate.getDate() - days);
      
      const recentSales = lines
        .map(line => {
          try {
            return JSON.parse(line);
          } catch {
            return null;
          }
        })
        .filter(entry => entry && new Date(entry.timestamp) >= cutoffDate);

      const totalSales = recentSales.length;
      const totalValue = recentSales.reduce((sum, entry) => sum + (entry.property.price || 0), 0);
      const averagePrice = totalSales > 0 ? totalValue / totalSales : 0;

      // Group by property type
      const salesByType = recentSales.reduce((acc, entry) => {
        const type = entry.property.propertyType || 'unknown';
        acc[type] = (acc[type] || 0) + 1;
        return acc;
      }, {});

      // Group by month
      const salesByMonth = recentSales.reduce((acc, entry) => {
        const month = new Date(entry.timestamp).toISOString().substring(0, 7); // YYYY-MM
        acc[month] = (acc[month] || 0) + 1;
        return acc;
      }, {});

      return {
        period: `Last ${days} days`,
        totalSales,
        totalValue,
        averagePrice,
        salesByType,
        salesByMonth,
        recentSales: recentSales.slice(-10).map(entry => ({
          id: entry.property.id,
          title: entry.property.title,
          price: entry.property.price,
          soldAt: entry.timestamp,
        })),
      };
    } catch (error) {
      if (error.code === 'ENOENT') {
        return {
          period: `Last ${days} days`,
          totalSales: 0,
          totalValue: 0,
          averagePrice: 0,
          salesByType: {},
          salesByMonth: {},
          recentSales: [],
        };
      }
      throw error;
    }
  }

  /**
   * Express middleware to log sold properties
   */
  middleware() {
    return async (req, res, next) => {
      // Store original json method
      const originalJson = res.json;
      
      // Override json method to intercept responses
      res.json = function(data) {
        // Check if this is a successful sold property response
        if (data.success && 
            (data.message?.includes('sold') || data.message?.includes('removed')) &&
            req.method === 'POST' && 
            req.path.includes('/sold')) {
          
          // Log the sold property (property info should be in data.data)
          if (data.data) {
            logger.logSoldProperty(data.data, 'MARKED_AS_SOLD').catch(console.error);
          }
        }
        
        // Call original json method
        return originalJson.call(this, data);
      };
      
      next();
    };
  }
}

// Create singleton instance
const logger = new SoldPropertyLogger();

module.exports = {
  SoldPropertyLogger,
  soldPropertyLogger: logger,
  soldPropertyLoggerMiddleware: logger.middleware(),
};