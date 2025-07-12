import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'edit_request_screen.dart'; // 👈 Make sure this file exists

class MyRequestsScreen extends StatefulWidget {
  final String username;
  const MyRequestsScreen({super.key, required this.username});

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  late Future<List<dynamic>> _requests;

  Future<List<dynamic>> fetchRequests() async {
    final url = Uri.parse('http://localhost:3000/requests?username=${widget.username}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['requests'] ?? [];
    } else {
      throw Exception('Failed to load requests');
    }
  }

  @override
  void initState() {
    super.initState();
    _requests = fetchRequests();
  }

  String formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day}-${dt.month}-${dt.year}';
    } catch (_) {
      return 'Invalid Date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Blood Requests')),
      body: FutureBuilder<List<dynamic>>(
        future: _requests,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No blood requests found.'));
          }

          final requests = snapshot.data!;
          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final req = requests[index];
              final loc = req['location'] ?? {};

              return Card(
                margin: const EdgeInsets.all(12),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: ListTile(
                        title: Text('${req['patientName']} (${req['bloodGroup']})'),
                        subtitle: Text(
                          '${loc['area'] ?? ''}, ${loc['city'] ?? ''}, ${loc['district'] ?? ''}, ${loc['state'] ?? ''}\n'
                          'Hospital: ${req['hospitalName']}',
                        ),
                        trailing: Text(formatDate(req['dateOfRequirement'] ?? '')),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.red),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditRequestScreen(
                                username: widget.username,
                                request: req,
                                index: index,
                              ),
                            ),
                          ).then((_) {
                            // Refresh list after editing
                            setState(() {
                              _requests = fetchRequests();
                            });
                          });
                        },
                      ),
                    )
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
