import 'package:flutter/material.dart';
import 'package:fintech_bridge/utils/constants.dart';

class ProfileTab extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController phoneController;
  final TextEditingController mpesaPhoneController;
  final TextEditingController courseController;
  final TextEditingController yearController;
  final TextEditingController institutionController;
  final bool isUpdatingProfile;
  final VoidCallback onUpdateProfile;

  const ProfileTab({
    super.key,
    required this.formKey,
    required this.phoneController,
    required this.mpesaPhoneController,
    required this.courseController,
    required this.yearController,
    required this.institutionController,
    required this.isUpdatingProfile,
    required this.onUpdateProfile,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Contact Information'),
            const SizedBox(height: 16),
            
            _buildTextField(
              controller: phoneController,
              label: 'Phone Number',
              icon: Icons.phone_rounded,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Phone number is required';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            _buildTextField(
              controller: mpesaPhoneController,
              label: 'M-Pesa Phone Number',
              icon: Icons.phone_android_rounded,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'M-Pesa phone number is required';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 32),
            
            _buildSectionTitle('Academic Information'),
            const SizedBox(height: 16),
            
            _buildTextField(
              controller: courseController,
              label: 'Course',
              icon: Icons.school_rounded,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Course is required';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            _buildTextField(
              controller: yearController,
              label: 'Year of Study',
              icon: Icons.calendar_today_rounded,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Year of study is required';
                }
                final year = int.tryParse(value!);
                if (year == null || year < 1 || year > 6) {
                  return 'Please enter a valid year (1-6)';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            _buildTextField(
              controller: institutionController,
              label: 'Institution',
              icon: Icons.account_balance_rounded,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Institution is required';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 32),
            
            _buildUpdateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppConstants.textColor,
        fontFamily: 'Poppins',
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppConstants.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppConstants.primaryColor),
        ),
        labelStyle: TextStyle(
          color: AppConstants.textColor.withOpacity(0.7),
          fontFamily: 'Poppins',
        ),
      ),
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isUpdatingProfile ? null : onUpdateProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isUpdatingProfile
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Update Profile',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
      ),
    );
  }
}