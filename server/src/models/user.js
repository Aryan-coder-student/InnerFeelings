const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  username: { type: String, required: true, unique: true, maxlength: 50 },
  email: { type: String, required: true, unique: true, maxlength: 100 },
  password_hash: { type: String, required: true, maxlength: 255 },
  created_at: { type: Date, default: Date.now },
  updated_at: { type: Date, default: Date.now },
  // Add privacy settings as embedded (from privacysettings table)
  privacy: {
    share_entries: { type: Boolean, default: false },
    share_community: { type: Boolean, default: false },
    encryption_key: { type: String, maxlength: 255 },
    updated_at: { type: Date, default: Date.now },
  },
});

module.exports = mongoose.model('User', userSchema);