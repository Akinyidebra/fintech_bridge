import 'package:fintech_bridge/utils/constants.dart';
import 'package:fintech_bridge/widgets/provider_app_header.dart';
import 'package:fintech_bridge/widgets/provider_dashboard_content.dart';
import 'package:fintech_bridge/widgets/bottom_nav_bar.dart';
import 'package:fintech_bridge/services/database_service.dart';
import 'package:fintech_bridge/widgets/provider_loans_content.dart';
import 'package:fintech_bridge/widgets/provider_profile_content_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProviderDashboard extends StatefulWidget {
  const ProviderDashboard({super.key});

  @override
  State<ProviderDashboard> createState() => _ProviderDashboardState();
}

class _ProviderDashboardState extends State<ProviderDashboard> {
  int _currentIndex = 0;
  late List<Widget> _screens;

  // Bottom navigation items for provider dashboard
  final List<BottomNavItem> _navItems = [
    const BottomNavItem(
      icon: Icons.home_rounded,
      label: 'Home',
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
      const ProviderDashboardContent(),
      const ProviderLoansContent(),
      const ProviderProfileContent(),
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
            // Provider App Header
            ProviderAppHeader(
              userProfileFuture: dbService.getCurrentUserProfile(),
              showLogo: true,
              showProfile: true,
              onProfileTap: () {
                setState(() => _currentIndex = 2);
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
