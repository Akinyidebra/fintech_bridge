import 'package:fintech_bridge/widgets/profile_action_buttons_widget.dart';
import 'package:fintech_bridge/widgets/profile_header_card_widget.dart';
import 'package:fintech_bridge/widgets/profile_identification_widget.dart';
import 'package:fintech_bridge/widgets/profile_info_section_widget.dart';
import 'package:fintech_bridge/screens/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fintech_bridge/services/auth_service.dart';
import 'package:fintech_bridge/services/database_service.dart';
import 'package:fintech_bridge/utils/constants.dart';
import 'package:fintech_bridge/models/student_model.dart';

class ProfileContent extends StatefulWidget {
  const ProfileContent({super.key});

  @override
  State<ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<ProfileContent> {
  // Data storage - same structure as dashboard
  Map<String, dynamic>? _userProfile;

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

      // Fetch user profile data - same as dashboard
      final result = await dbService.getCurrentUserProfile();

      if (!mounted) return;

      // Process user profile - same as dashboard
      if (result['success']) {
        _userProfile = result;
      } else {
        _errorMessage = result['message'] ?? 'Failed to load profile data';
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
    // Show loading screen while data is being fetched - same as dashboard
    if (_isLoading) {
      return const LoadingScreen(
        message: 'Loading your profile...',
        isFullScreen: false,
      );
    }

    // Show error state with retry option - same as dashboard
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
    // Check if profile data exists - same structure as dashboard
    if (_userProfile == null || _userProfile!['success'] != true) {
      return _buildEmptyProfileState(context);
    }

    // Get user data directly from the profile result
    final Student student = _userProfile!['data'] as Student;

    final authService = Provider.of<AuthService>(context);

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Header Card
          ProfileHeaderCard(student: student),

          const SizedBox(height: 20),

          // Personal Information Section
          ProfileInfoSection(
            title: 'Personal Information',
            icon: Icons.person_rounded,
            iconColor: AppConstants.primaryColor,
            items: [
              ProfileInfoItem(
                icon: Icons.email_rounded,
                label: 'University Email',
                value: student.universityEmail,
                backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                iconColor: AppConstants.primaryColor,
              ),
              ProfileInfoItem(
                icon: Icons.phone_rounded,
                label: 'Phone',
                value: student.phone,
                backgroundColor: AppConstants.accentColor.withOpacity(0.1),
                iconColor: AppConstants.accentColor,
              ),
              ProfileInfoItem(
                icon: Icons.phone_android_rounded,
                label: 'M-Pesa Phone',
                value: student.mpesaPhone,
                backgroundColor: AppConstants.secondaryColor.withOpacity(0.1),
                iconColor: AppConstants.secondaryColor,
              ),
              ProfileInfoItem(
                icon: Icons.verified_user_rounded,
                label: 'Verification Status',
                value: student.verified ? 'Verified' : 'Pending Verification',
                backgroundColor: (student.verified
                        ? AppConstants.successColor
                        : AppConstants.warningColor)
                    .withOpacity(0.1),
                iconColor: student.verified
                    ? AppConstants.successColor
                    : AppConstants.warningColor,
              ),
              if (student.verifiedAt != null)
                ProfileInfoItem(
                  icon: Icons.calendar_today_rounded,
                  label: 'Verified Date',
                  value:
                      '${student.verifiedAt?.day}/${student.verifiedAt?.month}/${student.verifiedAt?.year}',
                  backgroundColor: AppConstants.successColor.withOpacity(0.1),
                  iconColor: AppConstants.successColor,
                ),
            ],
          ),

          const SizedBox(height: 20),

          // Identification Documents Section
          ProfileIdentificationSection(
  identificationImages: student.identificationImages,
),

          const SizedBox(height: 20),

          // Academic Information Section
          ProfileInfoSection(
            title: 'Academic Information',
            icon: Icons.school_rounded,
            iconColor: AppConstants.secondaryColor,
            items: [
              ProfileInfoItem(
                icon: Icons.school_rounded,
                label: 'Course',
                value: student.course,
                backgroundColor: AppConstants.secondaryColor.withOpacity(0.1),
                iconColor: AppConstants.secondaryColor,
              ),
              ProfileInfoItem(
                icon: Icons.calendar_today_rounded,
                label: 'Year of Study',
                value: 'Year ${student.yearOfStudy}',
                backgroundColor: AppConstants.accentColor.withOpacity(0.1),
                iconColor: AppConstants.accentColor,
              ),
              ProfileInfoItem(
                icon: Icons.account_balance_rounded,
                label: 'Institution',
                value: student.institutionName,
                backgroundColor: AppConstants.secondaryColor.withOpacity(0.1),
                iconColor: AppConstants.secondaryColor,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Financial Information Section
          ProfileInfoSection(
            title: 'Financial Information',
            icon: Icons.account_balance_wallet_rounded,
            iconColor: AppConstants.accentColor,
            items: [
              ProfileInfoItem(
                icon: Icons.credit_score_rounded,
                label: 'Loan Status',
                value:
                    student.hasActiveLoan ? 'Active Loan' : 'No Active Loans',
                backgroundColor: student.hasActiveLoan
                    ? AppConstants.successColor.withOpacity(0.1)
                    : AppConstants.primaryColor.withOpacity(0.1),
                iconColor: student.hasActiveLoan
                    ? AppConstants.successColor
                    : AppConstants.primaryColor,
              ),
              ProfileInfoItem(
                icon: Icons.people_alt_rounded,
                label: 'Guarantors',
                value: student.guarantorContacts.isNotEmpty
                    ? '${student.guarantorContacts.length} Guarantor(s)'
                    : 'No Guarantors',
                backgroundColor: AppConstants.accentColor.withOpacity(0.1),
                iconColor: AppConstants.accentColor,
                additionalContent: student.guarantorContacts.isNotEmpty
                    ? _buildGuarantorsList(student.guarantorContacts)
                    : null,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Action Buttons
          ProfileActionButtons(
            authService: authService,
            student: student,
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildGuarantorsList(List<String> guarantors) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...guarantors.map((contact) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    const Icon(
                      Icons.person_rounded,
                      size: 18,
                      color: AppConstants.accentColor,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      contact,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppConstants.textColor,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              )),
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
            Icons.person_off_rounded,
            size: 60,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Profile information not found',
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
              'Complete Profile',
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
    Navigator.of(context).pushNamed('/edit-profile');
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
