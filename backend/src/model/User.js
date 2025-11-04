const mongoose = require('mongoose');


// Define User Schema
const userSchema = new mongoose.Schema(
  {
    email: { type: String, required: true, unique: true, index: true },
    name: { type: String },
    role: { type: String, default: 'employee' },
    passwordHash: { type: String, required: true },
    refreshTokenHash: { type: String, default: null },
  }, {
  timestamps: true // Add createdAt and updatedAt fields
});
const User = mongoose.model('User', userSchema);



module.exports = User;