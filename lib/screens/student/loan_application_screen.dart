// ignore_for_file: null_check_always_fails

import 'package:fintech_bridge/models/provider_model.dart' as provider_model;
import 'package:fintech_bridge/screens/student/my_loans_screen.dart';
import 'package:fintech_bridge/screens/student/profile_screen.dart';
import 'package:fintech_bridge/widgets/dashboard_content.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fintech_bridge/services/database_service.dart';
import 'package:fintech_bridge/utils/constants.dart';
import 'package:fintech_bridge/widgets/app_header.dart';
import 'package:fintech_bridge/widgets/bottom_nav_bar.dart';
import 'package:fintech_bridge/widgets/loan_application_content.dart';

class LoanApplicationScreen extends StatefulWidget {
  final String loanType;
  final provider_model.Provider? provider;
  final bool showNavigation;

  const LoanApplicationScreen({
    super.key,
    required this.loanType,
    this.provider,
    this.showNavigation = false,
  });

  @override
  State<LoanApplicationScreen> createState() => _LoanApplicationScreenState();
}

class _LoanApplicationScreenState extends State<LoanApplicationScreen> {
  int _currentIndex = 1;
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
      const MyLoansScreen(),
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
            // Loan Application content
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