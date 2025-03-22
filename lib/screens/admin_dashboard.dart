import 'package:fintech_bridge/services/auth_service.dart';
import 'package:fintech_bridge/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A2980), Color(0xFF26D0CE)],
          ),
        ),
        child: Column(
          children: [
            AppBar(
              title: const Text('Admin Dashboard'),
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    await Provider.of<AuthService>(context, listen: false)
                        .signOut();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Text(
                    'Welcome, Admin!',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    children: [
                      _buildDashboardCard(
                        icon: Icons.people,
                        title: 'Users',
                        value: '256',
                        color: Colors.blueAccent,
                      ),
                      _buildDashboardCard(
                        icon: Icons.business,
                        title: 'Providers',
                        value: '42',
                        color: Colors.greenAccent,
                      ),
                      _buildDashboardCard(
                        icon: Icons.verified_user,
                        title: 'Verified',
                        value: '89%',
                        color: Colors.orangeAccent,
                      ),
                      _buildDashboardCard(
                        icon: Icons.request_page,
                        title: 'Requests',
                        value: '15',
                        color: Colors.purpleAccent,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(value,
                style: TextStyle(
                    fontSize: 24, color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
