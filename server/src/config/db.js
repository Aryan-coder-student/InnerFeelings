const mongoose = require('mongoose');

const connectDB = async () => {
  const mongoURI = process.env.MONGODB_URI;

  if (!mongoURI) {
    console.log('⚠️  MONGO_URI not found in .env file. Server running without database.');
    console.log('📝 Add to .env: MONGO_URI=mongodb://localhost:27017/MoodMind');
    return; // Don't exit—let server run without DB for dev
  }

  try {
    await mongoose.connect(mongoURI); // No deprecated options needed
    console.log('MongoDB connected');
  } catch (err) {
    console.error('MongoDB connection error:', err);
    process.exit(1); // Exit on failure
  }
};

module.exports = connectDB;