import 'package:fintech_bridge/screens/loading_screen.dart';
import 'package:fintech_bridge/widgets/admin_profile_action_buttons_widget.dart';
import 'package:fintech_bridge/widgets/admin_profile_header_card_widget.dart';
import 'package:fintech_bridge/widgets/admin_profile_info_section_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fintech_bridge/services/auth_service.dart';
import 'package:fintech_bridge/services/database_service.dart';
import 'package:fintech_bridge/utils/constants.dart';
import 'package:fintech_bridge/models/admin_model.dart';

class AdminProfileContent extends StatefulWidget {
  final Admin? admin;

  const AdminProfileContent({super.key, this.admin});

  @override
  State<AdminProfileContent> createState() => _AdminProfileContentState();
}

class _AdminProfileContentState extends State<AdminProfileContent> {
  // Data storage - modified to store admin data properly
  Admin? _adminProfile;

  // Loading and error states
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dbService = Provider.of<DatabaseService>(context, listen: false);

      // If admin is passed as parameter, use it directly
      if (widget.admin != null) {
        _adminProfile = widget.admin;
      } else {
        // Otherwise, fetch current user profile
        final result = await dbService.getCurrentUserProfile();

        if (!mounted) return;

        if (result['success']) {
          // Check if the current user is an admin
          if (result['role'] == 'admin') {
            _adminProfile = result['data'] as Admin;
          } else {
            _errorMessage = 'Access denied. This page is for administrators only.';
          }
        } else {
          _errorMessage = result['message'] ?? 'Failed to load profile data';
        }
      }
    } catch (e) {
      _errorMessage = 'Failed to load profile data: ${e.toString()}';
      print('Profile loading error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Refresh data
  Future<void> _refreshProfile() async {
    await _loadProfileData();
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen while data is being fetched
    if (_isLoading) {
      return const LoadingScreen(
        message: 'Loading admin profile...',
        isFullScreen: false,
      );
    }

    // Show error state with retry option
    if (_errorMessage != null) {
      return _buildErrorState();
    }

    // Show profile content
    return _buildProfileContent();
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppConstants.errorColor,
            ),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: AppConstants.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: AppConstants.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _refreshProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent() {
    // Check if admin profile data exists
    if (_adminProfile == null) {
      return _buildEmptyProfileState(context);
    }

    final admin = _adminProfile!;
    final authService = Provider.of<AuthService>(context);

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Header Card
          AdminProfileHeaderCard(admin: admin),

          const SizedBox(height: 20),

          // Personal Information Section
          AdminProfileInfoSection(
            title: 'Personal Information',
            icon: Icons.person_rounded,
            iconColor: AppConstants.primaryColor,
            items: [
              ProfileInfoItem(
                icon: Icons.person_rounded,
                label: 'Full Name',
                value: admin.fullName,
                backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                iconColor: AppConstants.primaryColor,
              ),
              ProfileInfoItem(
                icon: Icons.email_rounded,
                label: 'Email Address',
                value: admin.adminEmail,
                backgroundColor: AppConstants.accentColor.withOpacity(0.1),
                iconColor: AppConstants.accentColor,
              ),
              if (admin.phone != null && admin.phone!.isNotEmpty)
                ProfileInfoItem(
                  icon: Icons.phone_rounded,
                  label: 'Phone Number',
                  value: admin.phone!,
                  backgroundColor: AppConstants.secondaryColor.withOpacity(0.1),
                  iconColor: AppConstants.secondaryColor,
                ),
            ],
          ),

          const SizedBox(height: 20),

          // Role & Permissions Section
          AdminProfileInfoSection(
            title: 'Role & Permissions',
            icon: Icons.admin_panel_settings_rounded,
            iconColor: AppConstants.secondaryColor,
            items: [
              ProfileInfoItem(
                icon: Icons.badge_rounded,
                label: 'Role',
                value: _formatRole(admin.role),
                backgroundColor: AppConstants.secondaryColor.withOpacity(0.1),
                iconColor: AppConstants.secondaryColor,
              ),
              ProfileInfoItem(
                icon: Icons.security_rounded,
                label: 'Access Level',
                value: _getAccessLevel(admin.role),
                backgroundColor: AppConstants.accentColor.withOpacity(0.1),
                iconColor: AppConstants.accentColor,
              ),
              ProfileInfoItem(
                icon: Icons.verified_user_rounded,
                label: 'Admin Status',
                value: 'Active Administrator',
                backgroundColor: AppConstants.successColor.withOpacity(0.1),
                iconColor: AppConstants.successColor,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Account Information Section
          AdminProfileInfoSection(
            title: 'Account Information',
            icon: Icons.info_rounded,
            iconColor: AppConstants.accentColor,
            items: [
              ProfileInfoItem(
                icon: Icons.calendar_today_rounded,
                label: 'Account Created',
                value: _formatDate(admin.createdAt),
                backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                iconColor: AppConstants.primaryColor,
              ),
              ProfileInfoItem(
                icon: Icons.update_rounded,
                label: 'Last Updated',
                value: _formatDate(admin.updatedAt),
                backgroundColor: AppConstants.secondaryColor.withOpacity(0.1),
                iconColor: AppConstants.secondaryColor,
              ),
              ProfileInfoItem(
                icon: Icons.fingerprint_rounded,
                label: 'Admin ID',
                value: admin.id,
                backgroundColor: AppConstants.accentColor.withOpacity(0.1),
                iconColor: AppConstants.accentColor,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // System Capabilities Section
          AdminProfileInfoSection(
            title: 'System Capabilities',
            icon: Icons.settings_rounded,
            iconColor: AppConstants.primaryColor,
            items: [
              ProfileInfoItem(
                icon: Icons.people_rounded,
                label: 'User Management',
                value: 'Full Access',
                backgroundColor: AppConstants.successColor.withOpacity(0.1),
                iconColor: AppConstants.successColor,
              ),
              ProfileInfoItem(
                icon: Icons.business_rounded,
                label: 'Provider Management',
                value: 'Full Access',
                backgroundColor: AppConstants.successColor.withOpacity(0.1),
                iconColor: AppConstants.successColor,
              ),
              ProfileInfoItem(
                icon: Icons.analytics_rounded,
                label: 'System Analytics',
                value: 'Full Access',
                backgroundColor: AppConstants.successColor.withOpacity(0.1),
                iconColor: AppConstants.successColor,
              ),
              ProfileInfoItem(
                icon: Icons.settings_applications_rounded,
                label: 'System Configuration',
                value: _getSystemAccess(admin.role),
                backgroundColor: _getSystemAccess(admin.role) == 'Full Access' 
                    ? AppConstants.successColor.withOpacity(0.1)
                    : AppConstants.warningColor.withOpacity(0.1),
                iconColor: _getSystemAccess(admin.role) == 'Full Access' 
                    ? AppConstants.successColor
                    : AppConstants.warningColor,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Action Buttons
          AdminProfileActionButtons(
            authService: authService,
            admin: admin,
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildEmptyProfileState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.admin_panel_settings_rounded,
            size: 60,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Admin profile information not found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppConstants.textColor,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _navigateToEditProfile(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.edit_rounded, size: 20),
            label: const Text(
              'Complete Admin Profile',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToEditProfile(BuildContext context) {
    Navigator.of(context).pushNamed('/edit-admin-profile');
  }

  String _formatRole(String role) {
    return role.split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _getAccessLevel(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Super Administrator';
      default:
        return 'Standard Admin';
    }
  }

  String _getSystemAccess(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Full Access';
      default:
        return 'Basic Access';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Data class for profile info items
class ProfileInfoItem {
  final IconData icon;
  final String label;
  final String value;
  final Color backgroundColor;
  final Color iconColor;
  final Widget? additionalContent;

  const ProfileInfoItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.backgroundColor,
    required this.iconColor,
    this.additionalContent,
  });
}