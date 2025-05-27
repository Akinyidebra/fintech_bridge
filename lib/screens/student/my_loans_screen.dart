import 'package:fintech_bridge/screens/student/profile_screen.dart';
import 'package:fintech_bridge/widgets/dashboard_content.dart';
import 'package:fintech_bridge/widgets/loan_application_content.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fintech_bridge/services/database_service.dart';
import 'package:fintech_bridge/utils/constants.dart';
import 'package:fintech_bridge/widgets/app_header.dart';
import 'package:fintech_bridge/widgets/bottom_nav_bar.dart';
import 'package:fintech_bridge/widgets/my_loans_content.dart';

class MyLoansScreen extends StatefulWidget {
  final bool showNavigation;

  const MyLoansScreen({
    super.key,
    this.showNavigation = true,
  });

  @override
  State<MyLoansScreen> createState() => _MyLoansScreenState();
}

class _MyLoansScreenState extends State<MyLoansScreen> {
  int _currentIndex = 2; // Start at Loans tab
  late List<Widget> _screens;

  // Bottom navigation items for student dashboard
  final List<BottomNavItem> _navItems = [
    const BottomNavItem(
      icon: Icons.home_rounded,
      label: 'Home',
    ),
    const BottomNavItem(
      icon: Icons.add_box_rounded,
      label: 'Apply',
    ),
    const BottomNavItem(
      icon: Icons.account_balance_rounded,
      label: 'Loans',
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
      const DashboardContent(),
      const LoanApplicationContent(loanType: ''),
      const MyLoansContent(),
      const ProfileScreen(),
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
            // Custom App Header
            AppHeader(
              userProfileFuture: dbService.getCurrentUserProfile(),
              showLogo: true,
              showProfile: true,
              onProfileTap: () {
                setState(() => _currentIndex = 3); // Navigate to profile tab
              },
            ),
            // Main content
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