// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class NotificationsScreen extends StatefulWidget {
//   final String username;
//   const NotificationsScreen({super.key, required this.username});

//   @override
//   State<NotificationsScreen> createState() => _NotificationsScreenState();
// }

// class _NotificationsScreenState extends State<NotificationsScreen> {
//   late Future<List<dynamic>> _notifications;

//   Future<List<dynamic>> fetchNotifications() async {
//     final url = Uri.parse('http://localhost:3000/notifications?username=${widget.username}');
//     final response = await http.get(url);

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       return data['notifications'] ?? [];
//     } else {
//       throw Exception('Failed to load notifications');
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     _notifications = fetchNotifications();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('My Notifications')),
//       body: FutureBuilder<List<dynamic>>(
//         future: _notifications,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text('No notifications found.'));
//           }

//           final notifications = snapshot.data!;
//           return ListView.builder(
//             itemCount: notifications.length,
//             itemBuilder: (context, index) {
//               final note = notifications[index];
//               return Card(
//                 margin: const EdgeInsets.all(12),
//                 child: Padding(
//                     padding: const EdgeInsets.all(12.0),
//                     child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                         Text(note['message'],
//                             style: const TextStyle(fontSize: 16),
//                             softWrap: true,
//                             maxLines: null,
//                             textAlign: TextAlign.start),
//                     ],
//                     ),
//                 ),
//                 );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsScreen extends StatefulWidget {
  final String username;
  const NotificationsScreen({super.key, required this.username});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<List<dynamic>> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = fetchNotifications();
    markAllAsRead();
  }

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

  Future<void> deleteNotification(String id) async {
    final url = Uri.parse('http://localhost:3000/notifications/$id');
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      setState(() => _notifications = fetchNotifications());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete notification')),
      );
    }
  }

  Future<bool?> confirmDelete(BuildContext context, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Notification"),
        content: const Text("Are you sure you want to delete this notification?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) await deleteNotification(id);
    return confirmed;
  }

  Future<void> markAllAsRead() async {
    final url = Uri.parse(
        'http://localhost:3000/notifications/mark-read?username=${widget.username}');
    await http.post(url);
  }

  Future<void> acceptRequest(Map<String, dynamic> notification) async {
    final url = Uri.parse('http://localhost:3000/notifications/accept-request');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "donor": widget.username,
        "notificationId": notification['_id'],
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Request accepted and requester notified")),
      );
      setState(() => _notifications = fetchNotifications());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to accept the request")),
      );
    }
  }

  Widget _buildNotificationTile(Map<String, dynamic> note, bool showAcceptButton) {
    final createdAt = DateTime.tryParse(note['createdAt']) ?? DateTime.now();

    return Dismissible(
      key: Key(note['_id']),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => confirmDelete(context, note['_id']),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(note['message'], style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 6),
              Text(timeago.format(createdAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              if (showAcceptButton)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: ElevatedButton.icon(
                    onPressed: () => acceptRequest(note),
                    icon: const Icon(Icons.check_circle),
                    label: const Text("Accept"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
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
          final requestsReceived = notifications
              .where((note) => note['message'].toString().contains("Blood Needed"))
              .toList();
          final requestsAccepted = notifications
              .where((note) => note['message'].toString().contains("accepted by"))
              .toList();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (requestsReceived.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.fromLTRB(12, 16, 12, 8),
                    child: Text("🩸 Requests Received",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  ...requestsReceived
                      .map((note) => _buildNotificationTile(note, true))
                      .toList(),
                ],
                if (requestsAccepted.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.fromLTRB(12, 24, 12, 8),
                    child: Text("✅ Requests Accepted",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  ...requestsAccepted
                      .map((note) => _buildNotificationTile(note, false))
                      .toList(),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
