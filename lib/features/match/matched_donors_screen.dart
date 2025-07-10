import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MatchedDonorsScreen extends StatefulWidget {
  final String bloodGroup;
  final String dateOfRequirement;
  final String state;
  final String district;
  final String city;
  final String patientName;
  final String hospitalName;
  final String contactNumber;

  const MatchedDonorsScreen({
    super.key,
    required this.bloodGroup,
    required this.dateOfRequirement,
    required this.state,
    required this.district,
    required this.city,
    required this.patientName,
    required this.hospitalName,
    required this.contactNumber,
  });

  @override
  State<MatchedDonorsScreen> createState() => _MatchedDonorsScreenState();
}

class _MatchedDonorsScreenState extends State<MatchedDonorsScreen> {
  late Future<List<dynamic>> _donors;

  Future<List<dynamic>> fetchMatchedDonors() async {
    final url = Uri.parse('http://localhost:3000/match-donors');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "bloodGroup": widget.bloodGroup,
        "dateOfRequirement": widget.dateOfRequirement,
        "patientName": widget.patientName,
        "hospitalName": widget.hospitalName,
        "contactNumber": widget.contactNumber,
        "location": {
          "state": widget.state,
          "district": widget.district,
          "city": widget.city
        }
      }),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      return result['matchedDonors'];
    } else {
      throw Exception('Failed to fetch donors');
    }
  }

  @override
  void initState() {
    super.initState();
    _donors = fetchMatchedDonors();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Matched Donors'), centerTitle: true),
      body: FutureBuilder<List<dynamic>>(
        future: _donors,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: \${snapshot.error}'));
          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(child: Text('No matched donors found.'));
          }

          final donors = snapshot.data!;
          return ListView.builder(
            itemCount: donors.length,
            itemBuilder: (context, index) {
              final donor = donors[index];
              final loc = donor['location'];
              return Card(
                margin: const EdgeInsets.all(12),
                child: ListTile(
                  title: Text("🩸 ${donor['bloodGroup']} - ${donor['username']}"),
                  subtitle: Text(
                    '${loc['area']}, ${loc['city']}, ${loc['district']}, ${loc['state']}',
                  ),
                  trailing: Text(
                    donor['availableDateTime'].toString().substring(0, 10),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
