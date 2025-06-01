import 'package:fintech_bridge/services/database_service.dart';
import 'package:fintech_bridge/utils/constants.dart';
import 'package:fintech_bridge/widgets/admin_app_header.dart';
import 'package:fintech_bridge/widgets/admin_dashboard_content.dart';
import 'package:fintech_bridge/widgets/admin_profile_content_widget.dart';
import 'package:fintech_bridge/widgets/admin_provider_content.dart';
import 'package:fintech_bridge/widgets/admin_student_content.dart';
import 'package:fintech_bridge/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  int _currentIndex = 1;
  late List<Widget> _screens;

  // Bottom navigation items for admin dashboard
  final List<BottomNavItem> _navItems = [
    const BottomNavItem(
      icon: Icons.home_rounded,
      label: 'Home',
    ),
    const BottomNavItem(
      icon: Icons.school_rounded,
      label: 'Students',
    ),
    const BottomNavItem(
      icon: Icons.business_rounded,
      label: 'Providers',
    ),
    const BottomNavItem(
      icon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _screens = [
      const AdminDashboardContent(),
      const AdminStudentContent(),
      const AdminProviderContent(),
      const AdminProfileContent(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final dbService = Provider.of<DatabaseService>(context, listen: false);

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Admin App Header
            AdminAppHeader(
              userProfileFuture: dbService.getCurrentUserProfile(),
              showLogo: true,
              showProfile: true,
              onProfileTap: () {
                setState(() => _currentIndex = 5); // Navigate to profile tab
              },
            ),
            // Screen content
            Expanded(
              child: _screens[_currentIndex],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        items: _navItems,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
