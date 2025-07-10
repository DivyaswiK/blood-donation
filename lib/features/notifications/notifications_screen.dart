import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationsScreen extends StatefulWidget {
  final String username;
  const NotificationsScreen({super.key, required this.username});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<List<dynamic>> _notifications;

  Future<List<dynamic>> fetchNotifications() async {
    final url = Uri.parse('http://localhost:3000/notifications?username=${widget.username}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['notifications'] ?? [];
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  @override
  void initState() {
    super.initState();
    _notifications = fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Notifications')),
      body: FutureBuilder<List<dynamic>>(
        future: _notifications,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No notifications found.'));
          }

          final notifications = snapshot.data!;
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final note = notifications[index];
              return Card(
                margin: const EdgeInsets.all(12),
                child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Text(note['message'].toString().replaceAll(r'\n', '\n'),
                            style: const TextStyle(fontSize: 16),
                            softWrap: true,
                            maxLines: null,
                            textAlign: TextAlign.start),
                    ],
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
