import 'package:fintech_bridge/screens/loading_screen.dart';
import 'package:fintech_bridge/widgets/provider_profile_action_buttons_widget.dart';
import 'package:fintech_bridge/widgets/provider_profile_header_card_widget.dart';
import 'package:fintech_bridge/widgets/provider_profile_identification_widget.dart';
import 'package:fintech_bridge/widgets/provider_profile_info_section_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fintech_bridge/services/auth_service.dart';
import 'package:fintech_bridge/services/database_service.dart';
import 'package:fintech_bridge/utils/constants.dart';
import 'package:fintech_bridge/models/provider_model.dart' as provider_model;

// Data class for profile info items - moved to top level for better organization
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

class ProviderProfileContent extends StatefulWidget {
  final provider_model.Provider? provider;

  const ProviderProfileContent({super.key, this.provider});

  @override
  State<ProviderProfileContent> createState() => _ProviderProfileContentState();
}

class _ProviderProfileContentState extends State<ProviderProfileContent> {
  // Data storage - modified to store provider data properly
  provider_model.Provider? _providerProfile;

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

      // If provider is passed as parameter, use it directly
      if (widget.provider != null) {
        _providerProfile = widget.provider;
      } else {
        // Otherwise, fetch current user profile
        final result = await dbService.getCurrentUserProfile();

        if (!mounted) return;

        if (result['success']) {
          // Check if the current user is a provider
          if (result['role'] == 'provider') {
            _providerProfile = result['data'] as provider_model.Provider;
          } else {
            _errorMessage = 'Access denied. This page is for providers only.';
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
        message: 'Loading provider profile...',
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
    // Check if provider profile data exists
    if (_providerProfile == null) {
      return _buildEmptyProfileState(context);
    }

    final provider = _providerProfile!;
    final authService = Provider.of<AuthService>(context);

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Header Card
          ProviderProfileHeaderCard(provider: provider),

          const SizedBox(height: 20),

          // Business Information Section
          ProviderProfileInfoSection(
            title: 'Business Information',
            icon: Icons.business_rounded,
            iconColor: AppConstants.primaryColor,
            items: [
              ProfileInfoItem(
                icon: Icons.business_rounded,
                label: 'Business Name',
                value: provider.businessName,
                backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                iconColor: AppConstants.primaryColor,
              ),
              ProfileInfoItem(
                icon: Icons.email_rounded,
                label: 'Business Email',
                value: provider.businessEmail,
                backgroundColor: AppConstants.accentColor.withOpacity(0.1),
                iconColor: AppConstants.accentColor,
              ),
              ProfileInfoItem(
                icon: Icons.phone_rounded,
                label: 'Phone',
                value: provider.phone,
                backgroundColor: AppConstants.secondaryColor.withOpacity(0.1),
                iconColor: AppConstants.secondaryColor,
              ),
              ProfileInfoItem(
                icon: Icons.category_rounded,
                label: 'Business Type',
                value: provider.businessType,
                backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                iconColor: AppConstants.primaryColor,
              ),
              if (provider.website != null && provider.website!.isNotEmpty)
                ProfileInfoItem(
                  icon: Icons.language_rounded,
                  label: 'Website',
                  value: provider.website!,
                  backgroundColor: AppConstants.accentColor.withOpacity(0.1),
                  iconColor: AppConstants.accentColor,
                ),
            ],
          ),

          const SizedBox(height: 20),

          // Identification Documents Section
          ProviderProfileIdentificationSection(
            identificationImages: provider.identificationImages,
          ),

          const SizedBox(height: 20),

          // Services Information Section
          ProviderProfileInfoSection(
            title: 'Services & Rates',
            icon: Icons.account_balance_wallet_rounded,
            iconColor: AppConstants.secondaryColor,
            items: [
              ProfileInfoItem(
                icon: Icons.percent_rounded,
                label: 'Interest Rate',
                value: '${provider.interestRate.toStringAsFixed(1)}% per annum',
                backgroundColor: AppConstants.secondaryColor.withOpacity(0.1),
                iconColor: AppConstants.secondaryColor,
              ),
              ProfileInfoItem(
                icon: Icons.list_alt_rounded,
                label: 'Loan Types',
                value: provider.loanTypes.join(', '),
                backgroundColor: AppConstants.accentColor.withOpacity(0.1),
                iconColor: AppConstants.accentColor,
              ),
              if (provider.description != null &&
                  provider.description!.isNotEmpty)
                ProfileInfoItem(
                  icon: Icons.description_rounded,
                  label: 'Description',
                  value: provider.description!,
                  backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                  iconColor: AppConstants.primaryColor,
                ),
            ],
          ),

          const SizedBox(height: 20),

          // Status Information Section
          ProviderProfileInfoSection(
            title: 'Account Status',
            icon: Icons.verified_user_rounded,
            iconColor: AppConstants.accentColor,
            items: [
              ProfileInfoItem(
                icon: Icons.verified_user_rounded,
                label: 'Verification Status',
                value: provider.verified ? 'Verified' : 'Pending Verification',
                backgroundColor: (provider.verified
                        ? AppConstants.successColor
                        : AppConstants.warningColor)
                    .withOpacity(0.1),
                iconColor: provider.verified
                    ? AppConstants.successColor
                    : AppConstants.warningColor,
              ),
              if (provider.verifiedAt != null)
                ProfileInfoItem(
                  icon: Icons.calendar_today_rounded,
                  label: 'Verified Date',
                  value:
                      '${provider.verifiedAt?.day}/${provider.verifiedAt?.month}/${provider.verifiedAt?.year}',
                  backgroundColor: AppConstants.successColor.withOpacity(0.1),
                  iconColor: AppConstants.successColor,
                ),
              ProfileInfoItem(
                icon: Icons.approval_rounded,
                label: 'Approval Status',
                value: provider.approved ? 'Approved' : 'Pending Approval',
                backgroundColor: (provider.approved
                        ? AppConstants.successColor
                        : AppConstants.warningColor)
                    .withOpacity(0.1),
                iconColor: provider.approved
                    ? AppConstants.successColor
                    : AppConstants.warningColor,
              ),
              ProfileInfoItem(
                icon: Icons.schedule_rounded,
                label: 'Member Since',
                value:
                    '${provider.createdAt.day}/${provider.createdAt.month}/${provider.createdAt.year}',
                backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                iconColor: AppConstants.primaryColor,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Action Buttons
          ProviderProfileActionButtons(
            authService: authService,
            provider: provider,
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
            Icons.business_center_rounded,
            size: 60,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Business profile information not found',
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
              'Complete Business Profile',
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
    Navigator.of(context).pushNamed('/edit-provider-profile');
  }
}
