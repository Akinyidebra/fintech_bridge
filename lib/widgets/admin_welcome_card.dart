import 'package:fintech_bridge/models/admin_model.dart';
import 'package:fintech_bridge/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminWelcomeCard extends StatelessWidget {
  final Future<Map<String, dynamic>>? adminProfileFuture;
  final Map<String, dynamic> systemStats;

  const AdminWelcomeCard({
    super.key,
    required this.adminProfileFuture,
    required this.systemStats,
  });

  @override
  Widget build(BuildContext context) {
    // Handle null future case
    if (adminProfileFuture == null) {
      return _buildErrorCard();
    }

    return FutureBuilder<Map<String, dynamic>>(
      future: adminProfileFuture!,
      builder: (context, providerSnapshot) {
        if (providerSnapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard();
        }

        if (!providerSnapshot.hasData ||
            !(providerSnapshot.data?['success'] ?? false) ||
            providerSnapshot.data?['data'] == null) {
          return _buildErrorCard();
        }

        final adminData = providerSnapshot.data!['data'];

        // Handle both direct Admin object and nested data structure
        Admin admin;
        if (adminData is Admin) {
          admin = adminData;
        } else {
          return _buildErrorCard();
        }

        return Container(
          width: double.infinity,
          // Removed fixed height constraints to allow flexible sizing
          padding: const EdgeInsets.all(20), // Reduced padding
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppConstants.primaryColor,
                Color(0xFF4C47CC),
                Color(0xFF3730A3),
              ],
              stops: [0.0, 0.6, 1.0],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppConstants.primaryColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Important: Use minimum space needed
            children: [
              // Header row with admin info
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10), // Slightly reduced
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings_rounded,
                      color: Colors.white,
                      size: 24, // Slightly smaller
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Welcome back,',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 13, // Slightly smaller
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          admin.fullName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18, // Slightly smaller
                            fontFamily: 'Poppins',
                            height: 1.1,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          'System Administrator',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.75),
                            fontSize: 11,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Time indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      DateFormat('MMM dd').format(DateTime.now()),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 10,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16), // Reduced spacing
              
              // Enhanced system overview with your calculated stats
              Container(
                padding: const EdgeInsets.all(12), // Reduced padding
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: IntrinsicHeight( // Ensures all columns have same height
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildEnhancedStat(
                          'Total Users',
                          ((systemStats['totalStudents'] ?? 0) + 
                           (systemStats['totalProviders'] ?? 0)).toString(),
                          Icons.people_rounded,
                          _getRecentActivity(),
                        ),
                      ),
                      Container(
                        width: 1,
                        color: Colors.white.withOpacity(0.2),
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      Expanded(
                        child: _buildEnhancedStat(
                          'Active Loans',
                          (systemStats['activeLoans'] ?? 0).toString(),
                          Icons.account_balance_wallet_rounded,
                          'vs ${systemStats['pendingLoans'] ?? 0} pending',
                        ),
                      ),
                      Container(
                        width: 1,
                        color: Colors.white.withOpacity(0.2),
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      Expanded(
                        child: _buildEnhancedStat(
                          'Unverified',
                          ((systemStats['unverifiedStudents'] ?? 0) + 
                           (systemStats['unverifiedProviders'] ?? 0)).toString(),
                          Icons.pending_actions_rounded,
                          _getVerificationStatus(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEnhancedStat(String title, String value, IconData icon, String subtitle) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.9),
          size: 20, // Reduced size
        ),
        const SizedBox(height: 6), // Reduced spacing
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20, // Slightly smaller
            fontFamily: 'Poppins',
            height: 1.0,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withOpacity(0.85),
            fontSize: 10, // Smaller
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 1),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 8, // Smaller
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // Helper methods to generate dynamic subtitles based on your stats
  String _getRecentActivity() {
    final recentStudents = systemStats['recentStudentSignups'] ?? 0;
    final recentProviders = systemStats['recentProviderSignups'] ?? 0;
    final total = recentStudents + recentProviders;
    
    if (total > 0) {
      return '+$total this week';
    }
    return 'No new signups';
  }

  String _getVerificationStatus() {
    final unverifiedStudents = systemStats['unverifiedStudents'] ?? 0;
    final unverifiedProviders = systemStats['unverifiedProviders'] ?? 0;
    final total = unverifiedStudents + unverifiedProviders;
    
    if (total == 0) {
      return 'All verified ✓';
    } else if (total > 5) {
      return 'Needs attention';
    }
    return 'Pending review';
  }

  Widget _buildLoadingCard() {
    return Container(
      width: double.infinity,
      height: 180, // Reduced height
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppConstants.primaryColor,
            Color(0xFF4C47CC),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      width: double.infinity,
      height: 180, // Reduced height
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.admin_panel_settings_rounded,
            color: Colors.grey[400],
            size: 28,
          ),
          const SizedBox(height: 8),
          const Text(
            'FinTech Bridge Admin',
            style: TextStyle(
              color: AppConstants.textColor,
              fontWeight: FontWeight.w700,
              fontSize: 16,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Unable to load admin profile. Please check your connection and try again.',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 11,
              fontFamily: 'Poppins',
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}