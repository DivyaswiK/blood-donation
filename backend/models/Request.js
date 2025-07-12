// // const mongoose = require('mongoose');

// // const requestSchema = new mongoose.Schema({
// //   username: { type: String, required: true },
// //   bloodGroup: { type: String, required: true },
// //   patientName: { type: String, required: true },
// //   hospitalName: { type: String, required: true },
// //   contactNumber: { type: String, required: true },
// //   dateOfRequirement: { type: Date, required: true },
// //   location: {
// //     state: String,
// //     district: String,
// //     city: String,
// //     area: String,
// //     pincode: String,
// //   },
// // }, { timestamps: true });

// // module.exports = mongoose.model('Request', requestSchema);
const mongoose = require('mongoose');

const requestSchema = new mongoose.Schema({
  username: { type: String, required: true, unique: true },
  requests: [
    {
      bloodGroup: { type: String, required: true },
      patientName: { type: String, required: true },
      hospitalName: { type: String, required: true },
      contactNumber: { type: String, required: true },
      dateOfRequirement: { type: Date, required: true },
      location: {
        state: String,
        district: String,
        city: String,
        area: String,
        pincode: String,
      },
      createdAt: { type: Date, default: Date.now }
    }
  ]
}, { timestamps: true });

module.exports = mongoose.model('Request', requestSchema);

