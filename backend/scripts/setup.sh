#!/bin/bash

echo "🏠 Estate Manager Backend Setup Script"
echo "======================================"

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js v16 or higher."
    exit 1
fi

# Check Node.js version
NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 16 ]; then
    echo "❌ Node.js version $NODE_VERSION is too old. Please install Node.js v16 or higher."
    exit 1
fi

echo "✅ Node.js $(node -v) detected"

# Install dependencies
echo "📦 Installing dependencies..."
npm install

if [ $? -ne 0 ]; then
    echo "❌ Failed to install dependencies"
    exit 1
fi

echo "✅ Dependencies installed successfully"

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "📝 Creating .env file from template..."
    cp .env.example .env
    echo "⚠️  Please update the .env file with your configuration:"
    echo "   - MongoDB URI"
    echo "   - Cloudinary credentials"
    echo "   - Other environment variables"
else
    echo "✅ .env file already exists"
fi

# Check if MongoDB is running (local)
if command -v mongod &> /dev/null; then
    if pgrep -x "mongod" > /dev/null; then
        echo "✅ MongoDB is running"
    else
        echo "⚠️  MongoDB is installed but not running"
        echo "   Start it with: mongod"
    fi
else
    echo "⚠️  MongoDB not found locally"
    echo "   Install MongoDB or use MongoDB Atlas"
    echo "   Or use Docker: docker-compose up -d mongodb"
fi

echo ""
echo "🎉 Setup complete!"
echo ""
echo "Next steps:"
echo "1. Update .env file with your configuration"
echo "2. Start MongoDB (if using local installation)"
echo "3. Run: npm run dev"
echo "4. Optional: Seed database with: node scripts/seed-database.js"
echo ""
echo "The server will be available at: http://localhost:3000"