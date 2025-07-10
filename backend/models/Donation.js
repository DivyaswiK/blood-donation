const mongoose = require('mongoose');

const donationSchema = new mongoose.Schema({
  username: { type: String, required: true, unique: true },
  donations: [
    {
      bloodGroup: { type: String, required: true },
      location: {
        state: { type: String, required: true },
        district: { type: String, required: true },
        city: { type: String, required: true },
        area: { type: String, required: true },
        pincode: { type: String, required: true },
        landmark: { type: String } // optional
      },
      availableDateTime: { type: Date, required: true },
      lastDonatedAt: { type: Date }
    }
  ]
}, { timestamps: true });

module.exports = mongoose.model('Donation', donationSchema);
