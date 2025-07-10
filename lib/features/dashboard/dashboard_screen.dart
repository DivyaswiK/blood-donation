import 'package:flutter/material.dart';
import '../../routes/routes.dart';
import '../donate/donate_blood_screen.dart';
import '../history/donation_history_screen.dart';
import '../request/request_blood_screen.dart'; // 👈 Add this
import '../notifications/notifications_screen.dart';


class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Object? args = ModalRoute.of(context)?.settings.arguments;
    final String username = args is String ? args : 'User';

    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F5),
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Blood Donor Dashboard',
          style: TextStyle(color: Colors.white),
        ),
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
            Text(
              'Welcome, $username!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildDashboardTile(
                    context,
                    icon: Icons.volunteer_activism,
                    label: 'Donate Blood',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DonateBloodScreen(username: username),
                        ),
                      );
                    },
                  ),
                  _buildDashboardTile(
                    context,
                    icon: Icons.bloodtype,
                    label: 'Request Blood',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RequestBloodScreen(username: username),
                        ),
                      );
                    },

                  ),
                  _buildDashboardTile(
                    context,
                    icon: Icons.history,
                    label: 'Donation History',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DonationHistoryScreen(username: username),
                        ),
                      );
                    },
                  ),
                  _buildDashboardTile(
                    context,
                    icon: Icons.account_circle,
                    label: 'My Profile',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('My Profile clicked')),
                      );
                    },
                  ),
                  _buildDashboardTile(
  context,
  icon: Icons.notifications,
  label: 'Notifications',
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NotificationsScreen(username: username),
      ),
    );
  },
),

                  _buildDashboardTile(
                    context,
                    icon: Icons.support_agent,
                    label: 'Contact Support',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Contact Support clicked')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardTile(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
