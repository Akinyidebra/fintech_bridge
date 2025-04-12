import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fintech_bridge/screens/authentication/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fintech_bridge/services/auth_service.dart';
import 'package:fintech_bridge/utils/constants.dart';
import 'package:fintech_bridge/models/student_model.dart';
import 'package:fintech_bridge/services/database_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final databaseService = Provider.of<DatabaseService>(context);

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                future: databaseService.getCurrentUserProfile(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingState();
                  }

                  if (!snapshot.hasData ||
                      snapshot.data == null ||
                      !snapshot.data!['success']) {
                    return _buildErrorState('Failed to load profile');
                  }

                  final userData = snapshot.data!['data'];
                  if (userData == null) return _buildEmptyProfileState();

                  // Convert map to Student model using the correct method
                  final Student student = _convertToStudent(userData);
                  return _buildProfileContent(student, authService);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to convert map data to Student object
  Student _convertToStudent(Map<String, dynamic> data) {
    // If data is coming from Firestore document snapshot
    if (data['id'] != null) {
      return Student(
        id: data['id'],
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
    } else {
      // Default values for missing data
      return Student(
        id: 'unknown',
        fullName: 'No Name',
        universityEmail: 'No Email',
        studentId: 'No ID',
        phone: 'No Phone',
        course: 'No Course',
        yearOfStudy: 1,
        verified: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  Widget _buildProfileContent(Student student, AuthService authService) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildProfileHeader(student),
          const SizedBox(height: 20),
          _buildPersonalInfoSection(student),
          const SizedBox(height: 20),
          _buildAcademicInfoSection(student),
          const SizedBox(height: 24),
          _buildActionButtons(context, authService),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Logo
              SizedBox(
                height: 32,
                child: Image.asset(
                  'assets/icons/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 12),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Fin',
                      style: AppConstants.titleLarge.copyWith(
                        color: AppConstants.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: 'Tech Bridge',
                      style: AppConstants.titleLarge.copyWith(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppConstants.primaryColor,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  child: CircleAvatar(
                    radius: 14,
                    backgroundImage:
                        NetworkImage('https://i.pravatar.cc/150?img=5'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(Student student) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppConstants.cardGradient,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                ),
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: student.profileImage != null &&
                          student.profileImage!.isNotEmpty
                      ? NetworkImage(student.profileImage!)
                      : const AssetImage('assets/images/default_avatar.png')
                          as ImageProvider,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            student.fullName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Student',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${student.studentId}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Course',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        student.course,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: Colors.white.withOpacity(0.3),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Verification',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            student.verified
                                ? Icons.verified_rounded
                                : Icons.pending_rounded,
                            color:
                                student.verified ? Colors.white : Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            student.verified ? 'Verified' : 'Pending',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ],
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.person_rounded,
                color: AppConstants.primaryColor,
                size: 22,
              ),
              SizedBox(width: 12),
              Text(
                'Personal Information',
                style: AppConstants.headlineSmall,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.email_rounded,
            'Email',
            student.universityEmail,
            AppConstants.primaryColor.withOpacity(0.1),
            AppConstants.primaryColor,
          ),
          const Divider(height: 24),
          _buildInfoRow(
            Icons.phone_rounded,
            'Phone',
            student.phone,
            AppConstants.accentColor.withOpacity(0.1),
            AppConstants.accentColor,
          ),
          const Divider(height: 24),
          _buildInfoRow(
            Icons.verified_user_rounded,
            'Verification Status',
            student.verified ? 'Verified' : 'Pending Verification',
            (student.verified
                    ? AppConstants.successColor
                    : AppConstants.warningColor)
                .withOpacity(0.1),
            student.verified
                ? AppConstants.successColor
                : AppConstants.warningColor,
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicInfoSection(Student student) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.school_rounded,
                color: AppConstants.secondaryColor,
                size: 22,
              ),
              SizedBox(width: 12),
              Text(
                'Academic Information',
                style: AppConstants.headlineSmall,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.school_rounded,
            'Course',
            student.course,
            AppConstants.secondaryColor.withOpacity(0.1),
            AppConstants.secondaryColor,
          ),
          const Divider(height: 24),
          _buildInfoRow(
            Icons.calendar_today_rounded,
            'Year of Study',
            'Year ${student.yearOfStudy}',
            AppConstants.accentColor.withOpacity(0.1),
            AppConstants.accentColor,
          ),
          const Divider(height: 24),
          _buildInfoRow(
            Icons.credit_score_rounded,
            'Student Loans',
            '2 Active Loans',
            AppConstants.primaryColor.withOpacity(0.1),
            AppConstants.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: AppConstants.primaryColor),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text(message, style: AppConstants.bodyMedium),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => setState(() {}),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyProfileState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_off_rounded, size: 60, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Profile information not found',
              style: AppConstants.bodyMedium),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _navigateToEditProfile(),
            child: const Text('Complete Profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String? value,
    Color bgColor,
    Color iconColor,
  ) {
    final valueText = value ?? 'Not provided';

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppConstants.bodyMediumSecondary),
              const SizedBox(height: 4),
              Text(
                valueText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.textColor,
                  fontFamily: 'Poppins',
                ),
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
        // Edit Profile Button with gradient
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: AppConstants.accentGradient,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppConstants.accentColor.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () => _navigateToEditProfile(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.edit_rounded, size: 20),
                SizedBox(width: 10),
                Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Change Password Button
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppConstants.primaryColor.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextButton.icon(
            icon: const Icon(
              Icons.password_rounded,
              color: AppConstants.primaryColor,
              size: 20,
            ),
            label: const Text(
              'Change Password',
              style: TextStyle(
                color: AppConstants.primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {},
          ),
        ),
        const SizedBox(height: 16),
        // Logout Button
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: OutlinedButton.icon(
            icon: const Icon(
              Icons.logout_rounded,
              size: 20,
            ),
            label: const Text(
              'Log Out',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppConstants.errorColor,
              side: const BorderSide(color: AppConstants.errorColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => _handleLogout(context, authService),
          ),
        ),
      ],
    );
  }

  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text(
              'Edit Profile',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: AppConstants.primaryColor),
          ),
          body: const Center(child: Text('Edit Profile Screen')),
        ),
      ),
    );
  }

  void _handleSaveProfile(Map<String, dynamic> updatedData) async {
    final databaseService =
        Provider.of<DatabaseService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);

    // Ensure user is authenticated
    if (authService.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Authentication error. Please login again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final result = await databaseService.updateStudentProfile(
      authService.currentUser!.uid,
      updatedData,
    );

    if (result['success']) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {});
    } else {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Update failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleLogout(BuildContext context, AuthService authService) async {
    final result = await authService.signOut();
    if (result['success']) {
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } else {
      // Show error message if logout fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Logout failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
