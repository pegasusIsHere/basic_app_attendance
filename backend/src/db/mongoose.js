// db/mongoose.js
const mongoose = require('mongoose');

const uri = process.env.MONGODB_URI || 'mongodb://localhost:27017/attendance';

async function connectMongoose() {
  await mongoose.connect(uri, {
    maxPoolSize: 10,
    serverSelectionTimeoutMS: 5000,
  }).then(() => console.log('✅ Connected to MongoDB Atlas'))
  .catch(err => console.error('❌ Mongo connection error:', err));;
//   console.log('Mongoose connected');
}

module.exports = { connectMongoose };
