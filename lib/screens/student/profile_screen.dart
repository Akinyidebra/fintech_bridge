import 'package:fintech_bridge/screens/authentication/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fintech_bridge/services/auth_service.dart';
import 'package:fintech_bridge/utils/constants.dart';
import 'package:fintech_bridge/models/student_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: FutureBuilder(
            future: authService.getUserData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!['user'] == null) {
                return const Center(child: Text('Failed to load profile'));
              }

              final student = snapshot.data!['user'] as Student;

              return Column(
                children: [
                  _buildProfileHeader(student),
                  const SizedBox(height: 24),
                  _buildPersonalInfoSection(student),
                  const SizedBox(height: 24),
                  _buildAcademicInfoSection(student),
                  const SizedBox(height: 24),
                  _buildActionButtons(context, authService),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(Student student) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppConstants.gradientCardDecoration,
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundImage: student.profileImage != null
                ? NetworkImage(student.profileImage!)
                : const AssetImage('assets/images/default_avatar.png')
            as ImageProvider,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.fullName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  student.studentId,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection(Student student) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppConstants.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Information',
            style: AppConstants.headlineSmall,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.email_rounded, 'Email', student.universityEmail),
          const Divider(height: 24),
          _buildInfoRow(Icons.phone_rounded, 'Phone', student.phone),
          const Divider(height: 24),
          _buildInfoRow(Icons.verified_user_rounded, 'Verification Status',
              student.verified ? 'Verified' : 'Pending Verification',
              statusColor: student.verified
                  ? AppConstants.successColor
                  : AppConstants.warningColor),
        ],
      ),
    );
  }

  Widget _buildAcademicInfoSection(Student student) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppConstants.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Academic Information',
            style: AppConstants.headlineSmall,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.school_rounded, 'Course', student.course),
          const Divider(height: 24),
          _buildInfoRow(Icons.calendar_today_rounded, 'Year of Study',
              'Year ${student.yearOfStudy}'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value,
      {Color? statusColor}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppConstants.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppConstants.primaryColor, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppConstants.bodyMediumSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: statusColor != null
                    ? AppConstants.bodyMedium.copyWith(color: statusColor)
                    : AppConstants.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, AuthService authService) {
    return Column(
      children: [
        AppConstants.gradientButton(
          text: 'Edit Profile',
          onPressed: () => _navigateToEditProfile(context),
          gradientColors: AppConstants.accentGradient,
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Log Out'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppConstants.errorColor,
            side: const BorderSide(color: AppConstants.errorColor),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => _handleLogout(context, authService),
        ),
      ],
    );
  }

  void _navigateToEditProfile(BuildContext context) {
    // Implement edit profile navigation
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Edit Profile')),
          body: const Center(child: Text('Edit Profile Screen')),
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context, AuthService authService) async {
    final result = await authService.signOut();
    if (result['success']) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );
    }
  }
}