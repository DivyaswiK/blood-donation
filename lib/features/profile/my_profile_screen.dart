import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'edit_profile_screen.dart';

class MyProfileScreen extends StatefulWidget {
  final String username;
  const MyProfileScreen({super.key, required this.username});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  Map<String, dynamic>? userProfile;
  bool isLoading = true;

  Future<void> fetchProfile() async {
    final url = Uri.parse('http://localhost:3000/profile?username=${widget.username}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        userProfile = data['user'];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load profile')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Widget _buildDetailTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.redAccent),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Profile")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userProfile == null
              ? const Center(child: Text('No profile data found.'))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.red[200],
                        child: Text(
                          widget.username.substring(0, 1).toUpperCase(),
                          style: const TextStyle(fontSize: 40, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(widget.username,
                          style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 20),
                      Card(
                        margin: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                        child: Column(
                          children: [
                            _buildDetailTile(
                              icon: Icons.bloodtype,
                              label: 'Blood Group',
                              value: userProfile?['bloodGroup'] ?? 'Not provided',
                            ),
                            _buildDetailTile(
                              icon: Icons.phone,
                              label: 'Phone Number',
                              value: userProfile?['phone'] ?? 'Not provided',
                            ),
                            _buildDetailTile(
                              icon: Icons.date_range,
                              label: 'Last Donated',
                              value: userProfile?['lastDonatedAt'] != null
                                  ? DateTime.parse(userProfile!['lastDonatedAt'])
                                      .toLocal()
                                      .toString()
                                      .split(' ')[0]
                                  : 'N/A',
                            ),
                            _buildDetailTile(
                              icon: Icons.volunteer_activism,
                              label: 'Total Donations',
                              value: userProfile?['totalDonations']?.toString() ?? '0',
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          username: widget.username,
          userProfile: userProfile!,
        ),
      ),
    ).then((updated) {
      if (updated == true) fetchProfile(); // refresh
    });
  },
  label: const Text('Edit Profile', style: TextStyle(color: Colors.red)),
//   icon: const Icon(Icons.edit, color: Colors.red),
  style: ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    backgroundColor: Colors.red[30],
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
    );
  }
}
