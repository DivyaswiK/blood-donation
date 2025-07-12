// import 'package:flutter/material.dart';
// import '../../routes/routes.dart';
// import '../donate/donate_blood_screen.dart';
// import '../history/donation_history_screen.dart';
// import '../request/request_blood_screen.dart'; // 👈 Add this
// import '../notifications/notifications_screen.dart';


// class DashboardScreen extends StatelessWidget {
//   const DashboardScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final Object? args = ModalRoute.of(context)?.settings.arguments;
//     final String username = args is String ? args : 'User';

//     return Scaffold(
//       backgroundColor: const Color(0xFFFDF6F5),
//       appBar: AppBar(
//         elevation: 0,
//         title: const Text(
//           'Blood Donor Dashboard',
//           style: TextStyle(color: Colors.white),
//         ),
//         backgroundColor: Theme.of(context).colorScheme.primary,
//         actions: [
//           PopupMenuButton<String>(
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//             onSelected: (value) {
//               if (value == 'logout') {
//                 Navigator.pushReplacementNamed(context, Routes.login);
//               }
//             },
//             icon: CircleAvatar(
//               backgroundColor: Colors.white,
//               child: Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
//             ),
//             itemBuilder: (context) => [
//               PopupMenuItem(
//                 value: 'username',
//                 child: ListTile(
//                   leading: const Icon(Icons.person),
//                   title: Text(username),
//                 ),
//               ),
//               const PopupMenuDivider(),
//               const PopupMenuItem(
//                 value: 'logout',
//                 child: ListTile(
//                   leading: Icon(Icons.logout),
//                   title: Text('Logout'),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(width: 12),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Welcome, $username!',
//               style: Theme.of(context).textTheme.headlineSmall,
//             ),
//             const SizedBox(height: 20),
//             Expanded(
//               child: GridView.count(
//                 crossAxisCount: 2,
//                 crossAxisSpacing: 16,
//                 mainAxisSpacing: 16,
//                 children: [
//                   _buildDashboardTile(
//                     context,
//                     icon: Icons.volunteer_activism,
//                     label: 'Donate Blood',
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => DonateBloodScreen(username: username),
//                         ),
//                       );
//                     },
//                   ),
//                   _buildDashboardTile(
//                     context,
//                     icon: Icons.bloodtype,
//                     label: 'Request Blood',
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => RequestBloodScreen(username: username),
//                         ),
//                       );
//                     },

//                   ),
//                   _buildDashboardTile(
//                     context,
//                     icon: Icons.history,
//                     label: 'Donation History',
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => DonationHistoryScreen(username: username),
//                         ),
//                       );
//                     },
//                   ),
//                   _buildDashboardTile(
//                     context,
//                     icon: Icons.account_circle,
//                     label: 'My Profile',
//                     onTap: () {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text('My Profile clicked')),
//                       );
//                     },
//                   ),
//                   _buildDashboardTile(
//   context,
//   icon: Icons.notifications,
//   label: 'Notifications',
//   onTap: () {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => NotificationsScreen(username: username),
//       ),
//     );
//   },
// ),

//                   _buildDashboardTile(
//                     context,
//                     icon: Icons.support_agent,
//                     label: 'Contact Support',
//                     onTap: () {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text('Contact Support clicked')),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDashboardTile(BuildContext context,
//       {required IconData icon,
//       required String label,
//       required VoidCallback onTap}) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Card(
//         elevation: 2,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         child: Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(icon, size: 36, color: Theme.of(context).colorScheme.primary),
//               const SizedBox(height: 8),
//               Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../routes/routes.dart';
import '../donate/donate_blood_screen.dart';
import '../history/donation_history_screen.dart';
import '../request/request_blood_screen.dart';
import '../notifications/notifications_screen.dart';
import '../profile/my_profile_screen.dart';
import '../support/contact_support_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late String username;
  int unreadCount = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Object? args = ModalRoute.of(context)?.settings.arguments;
    username = args is String ? args : 'User';
    _fetchUnreadCount();
  }

  Future<void> _fetchUnreadCount() async {
    try {
      final url = Uri.parse('http://localhost:3000/notifications?username=$username');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final all = data['notifications'] ?? [];
        final unread = all.where((n) => n['read'] == false).toList();
        setState(() => unreadCount = unread.length);
      }
    } catch (e) {
      debugPrint('🔴 Error fetching notification count: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F5),
      appBar: AppBar(
        elevation: 0,
        title: const Text('Blood Donor Dashboard', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          PopupMenuButton<String>(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            onSelected: (value) {
              if (value == 'logout') {
                Navigator.pushReplacementNamed(context, Routes.login);
              }
            },
            icon: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'username',
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(username),
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Logout'),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome, $username!', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildTile(Icons.volunteer_activism, 'Donate Blood', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DonateBloodScreen(username: username)),
                    );
                  }),
                  _buildTile(Icons.bloodtype, 'Request Blood', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => RequestBloodScreen(username: username)),
                    );
                  }),
                  _buildTile(Icons.history, 'Donation History', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DonationHistoryScreen(username: username)),
                    );
                  }),
                  _buildTile(Icons.account_circle, 'My Profile', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => MyProfileScreen(username: username)),
                      );
                    }),
                  _buildTile(Icons.notifications, 'Notifications', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NotificationsScreen(username: username,),
                      ),
                    ).then((_) => _fetchUnreadCount());
                  }, badge: unreadCount),
                  _buildTile(Icons.support_agent, 'Contact Support', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ContactSupportScreen()),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(IconData icon, String label, VoidCallback onTap, {int badge = 0}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 36, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 8),
                  Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            if (badge > 0)
              Positioned(
                top: 10,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$badge',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
