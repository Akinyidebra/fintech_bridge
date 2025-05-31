import 'package:fintech_bridge/widgets/admin_provider_header_card.dart';
import 'package:flutter/material.dart';
import 'package:fintech_bridge/utils/constants.dart';

class AdminProvidersTabBar extends StatelessWidget {
  final TabController controller;

  const AdminProvidersTabBar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 24, 20, 0), // Added top spacing
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section with better spacing
          const AdminProvidersHeaderCard(),
          const SizedBox(height: 20),

          // Tab bar container with improved design
          Container(
            decoration: BoxDecoration(
              color: AppConstants.backgroundSecondaryColor.withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.grey.withOpacity(0.1),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(4),
            child: TabBar(
              controller: controller,
              labelColor: Colors.white,
              unselectedLabelColor: AppConstants.textSecondaryColor,
              indicator: BoxDecoration(
                color: AppConstants.primaryColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppConstants.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: EdgeInsets.zero,
              labelStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              unselectedLabelStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              dividerColor: Colors.transparent,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              splashFactory: NoSplash.splashFactory,
              tabs: const [
                Tab(
                  height: 44,
                  child: Text('All'),
                ),
                Tab(
                  height: 44,
                  child: Text('Pending'),
                ),
                Tab(
                  height: 44,
                  child: Text('Verified'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}