import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fintech_bridge/widgets/profile_action_buttons_widget.dart';
import 'package:fintech_bridge/widgets/profile_header_card_widget.dart';
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
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _profileData;

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
      final databaseService =
          Provider.of<DatabaseService>(context, listen: false);
      final result = await databaseService.getCurrentUserProfile();

      if (!mounted) return;

      if (result['success'] && result['data'] != null) {
        setState(() {
          _profileData = result;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load profile data';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading profile: ${e.toString()}';
          _isLoading = false;
        });
      }
      print('Profile loading error: $e');
    }
  }

  Future<void> _refreshProfile() async {
    await _loadProfileData();
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen while data is being fetched
    if (_isLoading) {
      return const LoadingScreen(
        message: 'Loading your profile...',
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
    final userData = _profileData!['data'];
    
    if (userData == null) {
      return _buildEmptyProfileState(context);
    }

    // Convert map to Student model
    final Student student = _convertToStudent(userData);
    final authService = Provider.of<AuthService>(context);

    return RefreshIndicator(
      onRefresh: () async => _refreshProfile(),
      color: AppConstants.primaryColor,
      child: SingleChildScrollView(
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
                    value: '${student.verifiedAt?.day}/${student.verifiedAt?.month}/${student.verifiedAt?.year}',
                    backgroundColor: AppConstants.successColor.withOpacity(0.1),
                    iconColor: AppConstants.successColor,
                  ),
              ],
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
                  value: student.hasActiveLoan ? 'Active Loan' : 'No Active Loans',
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
            ProfileActionButtons(authService: authService),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Convert map data to Student object
  Student _convertToStudent(Map<String, dynamic> data) {
    return Student(
      id: data['id'] ?? 'unknown',
      fullName: data['fullName'] ?? 'No Name',
      universityEmail: data['universityEmail'] ?? 'No Email',
      studentId: data['studentId'] ?? 'No ID',
      phone: data['phone'] ?? 'No Phone',
      course: data['course'] ?? 'No Course',
      yearOfStudy: data['yearOfStudy'] ?? 1,
      profileImage: data['profileImage'],
      verified: data['verified'] ?? false,
      verifiedAt: data['verifiedAt'] != null
          ? data['verifiedAt'] is DateTime
              ? data['verifiedAt']
              : (data['verifiedAt'] as Timestamp).toDate()
          : null,
      identificationImages: data['identificationImages'] != null
          ? List<String>.from(data['identificationImages'])
          : null,
      mpesaPhone: data['mpesaPhone'] ?? data['phone'] ?? 'No Phone',
      institutionName: data['institutionName'] ?? 'Not provided',
      hasActiveLoan: data['hasActiveLoan'] ?? false,
      guarantorContacts: data['guarantorContacts'] != null
          ? List<String>.from(data['guarantorContacts'])
          : [],
      createdAt: data['createdAt'] != null
          ? data['createdAt'] is DateTime
              ? data['createdAt']
              : (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? data['updatedAt'] is DateTime
              ? data['updatedAt']
              : (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
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