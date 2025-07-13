const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const User = require('./models/User');
const Donation = require('./models/Donation');
const Request = require('./models/Request');
const Notification = require('./models/Notification');



const app = express();
const PORT = 3000;

const MONGO_URI = 'mongodb+srv://Divyaswi_15:Divya%402005@eep.8r1ngb7.mongodb.net/blood?retryWrites=true&w=majority&appName=EEP'; 

app.use(cors());
app.use(express.json());

mongoose.connect(MONGO_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
}).then(() => {
  console.log('✅ Connected to MongoDB');
}).catch(err => {
  console.error('❌ MongoDB connection error:', err);
});

// 👤 Register
app.post('/register', async (req, res) => {
  const { username, phone, password, bloodGroup } = req.body;

  if (!username || !phone || !password) {
    return res.status(400).json({ error: 'All fields are required' });
  }

  const existingUser = await User.findOne({ username });
  if (existingUser) {
    return res.status(400).json({ error: 'Username already exists' });
  }

  const newUser = new User({ username, phone, password, bloodGroup });
  await newUser.save();

  res.status(200).json({ message: 'User registered successfully' });
});

// 🔐 Login
app.post('/login', async (req, res) => {
  const { username, password } = req.body;

  const user = await User.findOne({ username, password });
  if (!user) {
    return res.status(401).json({ error: 'Invalid username or password' });
  }

  res.status(200).json({ message: 'Login successful', user });
});

// 🩸 Donate Blood (Array-based)
app.post('/donate', async (req, res) => {
  try {
    const { username, donation } = req.body;

    if (
      !username || !donation?.bloodGroup || !donation?.contactNumber || !donation?.availableDateTime ||
      !donation?.location?.state || !donation?.location?.district ||
      !donation?.location?.city || !donation?.location?.area || !donation?.location?.pincode
    ) {
      return res.status(400).json({ error: 'All required fields must be filled' });
    }

    const donationEntry = {
      bloodGroup: donation.bloodGroup,
      contactNumber: donation.contactNumber,
      location: donation.location,
      availableDateTime: new Date(donation.availableDateTime),
      lastDonatedAt: donation.lastDonatedAt ? new Date(donation.lastDonatedAt) : undefined
    };

    const existing = await Donation.findOne({ username });

    if (existing) {
      existing.donations.push(donationEntry);
      await existing.save();
    } else {
      const newDonation = new Donation({
        username,
        donations: [donationEntry]
      });
      await newDonation.save();
    }

    res.status(201).json({ message: 'Donation recorded successfully' });
  } catch (err) {
    console.error('❌ Error in /donate:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});



// 📜 Get Donation History by Username
app.get('/donations', async (req, res) => {
  const { username } = req.query;

  if (!username) return res.status(400).json({ error: 'Username is required' });

  try {
    const userDonation = await Donation.findOne({ username });

    if (!userDonation) return res.status(200).json({ donations: [] });

    const sorted = userDonation.donations.sort(
      (a, b) => new Date(b.availableDateTime) - new Date(a.availableDateTime)
    );

    res.status(200).json({ donations: sorted });
  } catch (err) {
    console.error('❌ Error fetching donations:', err);
    res.status(500).json({ error: 'Failed to fetch donation history' });
  }
});

// 🏥 Request Blood
// app.post('/request', async (req, res) => {
//   const {
//     username,
//     bloodGroup,
//     patientName,
//     hospitalName,
//     contactNumber,
//     dateOfRequirement,
//     location
//   } = req.body;

//   if (
//     !username || !bloodGroup || !patientName || !hospitalName ||
//     !contactNumber || !dateOfRequirement || !location?.city
//   ) {
//     return res.status(400).json({ error: 'All required fields must be filled' });
//   }

//   const newRequestEntry = {
//     bloodGroup,
//     patientName,
//     hospitalName,
//     contactNumber,
//     dateOfRequirement: new Date(dateOfRequirement),
//     location,
//     createdAt: new Date()
//   };

//   try {
//     const existing = await Request.findOne({ username });

//     if (existing) {
//       existing.requests.push(newRequestEntry);
//       await existing.save();
//     } else {
//       const newRequestDoc = new Request({
//         username,
//         requests: [newRequestEntry]
//       });
//       await newRequestDoc.save();
//     }

//     res.status(201).json({ message: 'Blood request submitted successfully' });
//   } catch (err) {
//     console.error('❌ /request error:', err);
//     res.status(500).json({ error: 'Internal server error' });
//   }
// });

app.post('/request', async (req, res) => {
  const {
    username,
    bloodGroup,
    patientName,
    hospitalName,
    contactNumber,
    dateOfRequirement,
    location
  } = req.body;
  if (
    !username || !bloodGroup || !patientName || !hospitalName ||
    !contactNumber || !dateOfRequirement || !location?.city
  ) {
    return res.status(400).json({ error: 'All required fields must be filled' });
  }

  const newRequestEntry = {
    bloodGroup,
    patientName,
    hospitalName,
    contactNumber,
    dateOfRequirement: new Date(dateOfRequirement),
    location,
    createdAt: new Date()
  };

  try {
    const existing = await Request.findOne({ username });

    if (existing) {
      existing.requests.push(newRequestEntry);
      await existing.save();
    } else {
      const newRequestDoc = new Request({
        username,
        requests: [newRequestEntry]
      });
      await newRequestDoc.save();
    }
    const matchedDonors = await User.find({
      role: 'donor',
      bloodGroup,
      'location.state': location.state,
      'location.district': location.district
    });

    // ✅ Notify matching donors
    for (const donor of matchedDonors) {
      await Notification.create({
        username: donor.username, // 🧑‍💉 recipient = donor
        message: `🚨 Blood Needed!\nPatient: ${patientName}\nHospital: ${hospitalName}\nContact: ${contactNumber}\nRequires ${bloodGroup} blood urgently.`,
        metadata: {
          requesterUsername: username,
          bloodGroup,
          state: location.state,
          district: location.district
        },
        createdAt: new Date(),
        read: false
      });
    }

    res.status(201).json({ message: 'Blood request submitted and notifications sent successfully' });

  } catch (err) {
    console.error('❌ /request error:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});


// 🧠 AI Donor Matching
// app.post('/match-donors', async (req, res) => {
//   const { bloodGroup, location, dateOfRequirement } = req.body;

//   if (!bloodGroup || !location?.district || !dateOfRequirement) {
//     return res.status(400).json({ error: 'Missing required fields' });
//   }

//   try {
//     const allDonors = await Donation.find({
//       donations: {
//         $elemMatch: {
//           bloodGroup,
//           availableDateTime: { $gte: new Date(dateOfRequirement) },
//           'location.district': location.district
//         }
//       }
//     });

//     const matchedDonors = [];

//     allDonors.forEach(donor => {
//       donor.donations.forEach(d => {
//         if (
//           d.bloodGroup === bloodGroup &&
//           d.availableDateTime >= new Date(dateOfRequirement) &&
//           d.location.district === location.district
//         ) {
//           let score = 0;
//           if (d.location.city === location.city) score += 1;
//           if (!d.lastDonatedAt || new Date(d.lastDonatedAt) <= new Date(Date.now() - 90 * 86400000)) score += 2;

//           matchedDonors.push({ ...d.toObject(), username: donor.username, score });
//         }
//       });
//     });

//     matchedDonors.sort((a, b) => b.score - a.score);
//     res.status(200).json({ matchedDonors });
//   } catch (err) {
//     console.error('❌ Error matching donors:', err);
//     res.status(500).json({ error: 'Internal server error' });
//   }
// });
 // Add this at the top if not already

app.post('/match-donors', async (req, res) => {
  const {
    bloodGroup,
    location,
    dateOfRequirement,
    patientName,
    hospitalName,
    contactNumber,
    username // ✅ Add this to capture requester (e.g., pavani)
  } = req.body;

  if (!bloodGroup || !location?.district || !dateOfRequirement || !patientName || !hospitalName || !contactNumber || !username) {
    return res.status(400).json({ error: 'Missing required fields' });
  }

  try {
    const dateReq = new Date(dateOfRequirement);

    const allDonors = await Donation.find({
      donations: {
        $elemMatch: {
          bloodGroup,
          availableDateTime: { $gte: dateReq },
          'location.district': location.district
        }
      }
    });

    const matchedDonors = [];

    for (const donor of allDonors) {
      for (const donation of donor.donations) {
        if (
          donation.bloodGroup === bloodGroup &&
          donation.availableDateTime >= dateReq &&
          donation.location.district === location.district
        ) {
          let score = 0;
          if (donation.location.city === location.city) score += 1;
          if (!donation.lastDonatedAt || new Date(donation.lastDonatedAt) <= new Date(Date.now() - 90 * 86400000)) {
            score += 2;
          }
          const user = await User.findOne({ username: donor.username });
          matchedDonors.push({
            username: donor.username,
            bloodGroup: donation.bloodGroup,
            contactNumber: user?.phone ?? "N/A",
            availableDateTime: donation.availableDateTime,
            lastDonatedAt: donation.lastDonatedAt,
            location: donation.location,
            score
          });

          // ✅ Add metadata with requester username
          const message = `🚨 Blood Needed!,Patient: ${patientName},Hospital: ${hospitalName},Contact: ${contactNumber},Requires ${bloodGroup} blood urgently.`;

          await Notification.create({
            username: donor.username,
            message,
            metadata: {
              requesterUsername: username  // ✅ this is the actual user who made the request (pavani)
            }
          });
        }
      }
    }

    matchedDonors.sort((a, b) => b.score - a.score);
    res.status(200).json({ matchedDonors });

  } catch (err) {
    console.error('❌ Error matching donors:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});


// View My Requests
app.get('/requests', async (req, res) => {
  const { username } = req.query;

  if (!username) return res.status(400).json({ error: 'Username is required' });

  try {
    const userRequests = await Request.findOne({ username });
    if (!userRequests) {
      return res.status(200).json({ requests: [] }); // or maybe 404
    }
    res.status(200).json({ requests: userRequests.requests });
  } catch (err) {
    console.error('❌ Error fetching requests:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});


app.listen(PORT, () => {
  console.log(`🚀 Server running at http://localhost:${PORT}`);
});

app.get('/notifications', async (req, res) => {
  const { username } = req.query;
  if (!username) return res.status(400).json({ error: 'Username is required' });

  try {
    const notifications = await Notification.find({ username }).sort({ timestamp: -1 });
    res.status(200).json({ notifications });
  } catch (err) {
    console.error('❌ Error fetching notifications:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

app.post('/notifications/mark-read', async (req, res) => {
  const { username } = req.query;
  if (!username) return res.status(400).json({ error: 'Username is required' });

  try {
    await Notification.updateMany({ username, read: false }, { $set: { read: true } });
    res.status(200).json({ message: 'Marked all as read' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

app.delete('/notifications/:id', async (req, res) => {
  const { id } = req.params;
  try {
    await Notification.findByIdAndDelete(id);
    res.status(200).json({ message: 'Notification deleted successfully' });
  } catch (err) {
    console.error('❌ Error deleting notification:', err);
    res.status(500).json({ error: 'Failed to delete notification' });
  }
});

// GET /notifications/unread-count?username=pavani
app.get('/notifications/unread-count', async (req, res) => {
  const { username } = req.query;
  if (!username) return res.status(400).json({ error: 'Username required' });

  try {
    const count = await Notification.countDocuments({ username, read: false });
    res.status(200).json({ count });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch unread count' });
  }
});

// ✏️ Edit a specific donation entry
app.put('/donations/:username/:index', async (req, res) => {
  const { username, index } = req.params;
  const updatedDonation = req.body;

  try {
    const donationDoc = await Donation.findOne({ username });
    if (!donationDoc || !donationDoc.donations[index]) {
      return res.status(404).json({ error: 'Donation not found' });
    }

    donationDoc.donations[index] = {
      ...donationDoc.donations[index]._doc,
      ...updatedDonation,
      availableDateTime: new Date(updatedDonation.availableDateTime),
      lastDonatedAt: updatedDonation.lastDonatedAt
        ? new Date(updatedDonation.lastDonatedAt)
        : undefined,
    };

    await donationDoc.save();
    res.status(200).json({ message: 'Donation updated successfully' });
  } catch (err) {
    console.error('❌ Error updating donation:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

app.put('/requests/:username/:index', async (req, res) => {
  const { username, index } = req.params;
  const updatedRequest = req.body;

  try {
    const requestDoc = await Request.findOne({ username });
    if (!requestDoc || !requestDoc.requests || requestDoc.requests.length <= index) {
      return res.status(404).json({ error: 'Request not found' });
    }

    // Replace the request at index with the updated one
    requestDoc.requests[index] = {
      ...requestDoc.requests[index],
      ...updatedRequest,
      dateOfRequirement: new Date(updatedRequest.dateOfRequirement)
    };

    await requestDoc.save();
    res.status(200).json({ message: 'Request updated successfully' });
  } catch (err) {
    console.error('❌ Error updating request:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

app.get('/profile', async (req, res) => {
  const { username } = req.query;
  const user = await User.findOne({ username });
  const donation = await Donation.findOne({ username });

  if (!user) return res.status(404).json({ error: 'User not found' });

  let lastDonatedAt = null;
  let totalDonations = 0;

  if (donation) {
    totalDonations = donation.donations.length;
    lastDonatedAt = donation.donations[donation.donations.length - 1]?.availableDateTime;
  }

  res.json({
    user: {
      username: user.username,
      phone: user.phone,
      bloodGroup: user.bloodGroup,
      lastDonatedAt,
      totalDonations
    }
  });
});

// PUT /profile/:username
app.put('/profile/:username', async (req, res) => {
  const { username } = req.params;
  const { phone, bloodGroup, lastDonatedAt } = req.body;

  try {
    const updated = await User.findOneAndUpdate(
      { username },
      { phone, bloodGroup, lastDonatedAt: lastDonatedAt ? new Date(lastDonatedAt) : undefined },
      { new: true }
    );

    if (!updated) return res.status(404).json({ error: 'User not found' });

    res.status(200).json({ message: 'Profile updated successfully', user: updated });
  } catch (err) {
    console.error('❌ Error updating profile:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

app.post('/notifications/accept-request', async (req, res) => {
  const { donor, notificationId } = req.body;

  try {
    const oldNote = await Notification.findById(notificationId);
    if (!oldNote) return res.status(404).json({ error: 'Original notification not found' });

    const requesterUsername = oldNote?.metadata?.requesterUsername;
    if (!requesterUsername) {
      return res.status(400).json({ error: 'Requester username missing in metadata' });
    }

    const donorUser = await User.findOne({ username: donor });

    // 🔍 DEBUG: print donorUser
    console.log('👉 Donor User:', donorUser);

    if (!donorUser || !donorUser.phone) {
      return res.status(404).json({ error: 'Donor user or phone not found' });
    }

    await Notification.create({
      username: requesterUsername,
      message: `Your blood request has been accepted by ${donorUser.username}. Contact: ${donorUser.phone}`,
      metadata: {
        donorUsername: donorUser.username,
        donorContact: donorUser.phone,
      },
      read: false,
      createdAt: new Date(),
    });

    res.status(200).json({ message: 'Request accepted and requester notified' });
  } catch (err) {
    console.error('❌ Error in accept-request:', err);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});


// app.post('/accept-request', async (req, res) => {
//   const { donor, notificationId } = req.body;

//   try {
//     // Get the original notification (sent to donor)
//     const donorNotification = await Notification.findById(notificationId);
//     if (!donorNotification || !donorNotification.metadata || !donorNotification.metadata.requesterUsername) {
//       return res.status(404).json({ message: "Original request notification not found." });
//     }

//     const requesterUsername = donorNotification.metadata.requesterUsername;

//     // Get donor details to include contact number
//     const donorUser = await User.findOne({ username: donor });
//     if (!donorUser) {
//       return res.status(404).json({ message: "Donor not found." });
//     }

//     // Create a new notification for the requester
//     const newNotification = new Notification({
//       username: requesterUsername,
//       message: `Your blood request has been accepted by ${donorUser.username}. Contact: ${donorUser.contactNumber}`,
//       read: false,
//     });

//     await newNotification.save();

//     return res.json({ message: "Request accepted and requester notified" });
//   } catch (err) {
//     console.error(err);
//     return res.status(500).json({ message: "Server error while accepting request" });
//   }
// });
