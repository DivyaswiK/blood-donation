const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema({
  username: { type: String, required: true },
  message: { type: String, required: true },
  createdAt: { type: Date, default: Date.now },
  read: { type: Boolean, default: false },
  metadata: {
    requesterUsername: String,
    bloodGroup: String,
    state: String,
    district: String,
  }
});
module.exports = mongoose.model('Notification', notificationSchema);
