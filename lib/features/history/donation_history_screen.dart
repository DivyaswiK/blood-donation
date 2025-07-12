import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'edit_donation_screen.dart'; // Make sure this file is created in same folder

class DonationHistoryScreen extends StatefulWidget {
  final String username;

  const DonationHistoryScreen({super.key, required this.username});

  @override
  State<DonationHistoryScreen> createState() => _DonationHistoryScreenState();
}

class _DonationHistoryScreenState extends State<DonationHistoryScreen> {
  late Future<List<dynamic>> _donationHistory;

  Future<List<dynamic>> fetchDonationHistory() async {
    final url = Uri.parse('http://localhost:3000/donations?username=${widget.username}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['donations'];
    } else {
      throw Exception('Failed to load donation history');
    }
  }

  @override
  void initState() {
    super.initState();
    _donationHistory = fetchDonationHistory();
  }

  String formatDateTime(String isoDate) {
    final dt = DateTime.parse(isoDate);
    return '${dt.day}-${dt.month}-${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donation History'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _donationHistory,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No donation records found.'));
          }

          final donations = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: donations.length,
            itemBuilder: (context, index) {
              final donation = donations[index];
              final location = donation['location'] ?? {};

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text.rich(
                            TextSpan(
                              text: 'Blood Group: ',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              children: [
                                TextSpan(text: donation['bloodGroup'] ?? '-'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text.rich(
                            TextSpan(
                              text: 'Date & Time: ',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              children: [
                                TextSpan(text: formatDateTime(donation['availableDateTime'] ?? '')),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text.rich(
                            TextSpan(
                              text: 'Location: ',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              children: [
                                TextSpan(
                                  text:
                                      '${location['area'] ?? '-'}, ${location['city'] ?? '-'}, ${location['district'] ?? '-'}, ${location['state'] ?? '-'} - ${location['pincode'] ?? '-'}',
                                ),
                              ],
                            ),
                          ),
                          if ((location['landmark'] ?? '').toString().trim().isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text.rich(
                                TextSpan(
                                  text: 'Landmark: ',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                  children: [
                                    TextSpan(text: location['landmark']),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.red),
                        tooltip: 'Edit',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditDonationScreen(
                                username: widget.username,
                                donation: donation,
                                index: index,
                              ),
                            ),
                          ).then((_) {
                            setState(() {
                              _donationHistory = fetchDonationHistory();
                            });
                          });
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
