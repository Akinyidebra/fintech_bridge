import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:fintech_bridge/utils/constants.dart';

class ProfileTab extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController phoneController;
  final TextEditingController mpesaPhoneController;
  final TextEditingController courseController;
  final TextEditingController yearController;
  final TextEditingController institutionController;

  // Guarantor 1 controllers
  final TextEditingController guarantor1NameController;
  final TextEditingController guarantor1PhoneController;
  final TextEditingController guarantor1RelationshipController;
  final TextEditingController guarantor1EmailController;
  final TextEditingController guarantor1IdNumberController;
  final TextEditingController guarantor1OccupationController;
  final TextEditingController guarantor1AddressController;

  // Guarantor 2 controllers
  final TextEditingController guarantor2NameController;
  final TextEditingController guarantor2PhoneController;
  final TextEditingController guarantor2RelationshipController;
  final TextEditingController guarantor2EmailController;
  final TextEditingController guarantor2IdNumberController;
  final TextEditingController guarantor2OccupationController;
  final TextEditingController guarantor2AddressController;

  final bool isUpdatingProfile;
  final VoidCallback onUpdateProfile;
  final VoidCallback onPickProfileImage;
  final File? profileImage;
  final String? currentProfileImageBase64;

  const ProfileTab({
    super.key,
    required this.formKey,
    required this.phoneController,
    required this.mpesaPhoneController,
    required this.courseController,
    required this.yearController,
    required this.institutionController,
    required this.guarantor1NameController,
    required this.guarantor1PhoneController,
    required this.guarantor1RelationshipController,
    required this.guarantor1EmailController,
    required this.guarantor1IdNumberController,
    required this.guarantor1OccupationController,
    required this.guarantor1AddressController,
    required this.guarantor2NameController,
    required this.guarantor2PhoneController,
    required this.guarantor2RelationshipController,
    required this.guarantor2EmailController,
    required this.guarantor2IdNumberController,
    required this.guarantor2OccupationController,
    required this.guarantor2AddressController,
    required this.isUpdatingProfile,
    required this.onUpdateProfile,
    required this.onPickProfileImage,
    required this.profileImage,
    required this.currentProfileImageBase64,
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
            _buildProfileImageSection(),
            const SizedBox(height: 32),
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
                final year = double.tryParse(value!);
                if (year == null || year < 1.0 || year > 6.1) {
                  return 'Invalid year';
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
            _buildGuarantorsSection(),
            const SizedBox(height: 32),
            _buildUpdateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Profile Picture'),
        const SizedBox(height: 16),
        Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: onPickProfileImage,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppConstants.primaryColor.withOpacity(0.3),
                        width: 2,
                      ),
                      color: Colors.white,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: _buildProfileImageWidget(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Tap to change profile picture',
                  style: TextStyle(
                    color: AppConstants.textColor.withOpacity(0.7),
                    fontSize: 14,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImageWidget() {
    // If a new image is selected
    if (profileImage != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.file(
            profileImage!,
            fit: BoxFit.cover,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      );
    }

    // If there's a current profile image (base64)
    if (currentProfileImageBase64 != null &&
        currentProfileImageBase64!.isNotEmpty) {
      try {
        String base64Data = currentProfileImageBase64!;
        if (base64Data.contains('base64,')) {
          base64Data = base64Data.split(',').last;
        }
        final bytes = base64Decode(base64Data);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
        );
      } catch (e) {
        // If decoding fails, show default
      }
    }

    // Default placeholder
    return Container(
      color: Colors.grey[200],
      child: Icon(
        Icons.person_add_rounded,
        size: 40,
        color: AppConstants.primaryColor.withOpacity(0.7),
      ),
    );
  }

  Widget _buildGuarantorsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Guarantor Information'),
        const SizedBox(height: 8),
        Text(
          'Please provide two guarantors who can vouch for you',
          style: TextStyle(
            color: AppConstants.textColor.withOpacity(0.6),
            fontSize: 14,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 16),

        // Guarantor 1
        _buildGuarantorCard(
          title: 'Guarantor 1',
          nameController: guarantor1NameController,
          phoneController: guarantor1PhoneController,
          relationshipController: guarantor1RelationshipController,
          emailController: guarantor1EmailController,
          idNumberController: guarantor1IdNumberController,
          occupationController: guarantor1OccupationController,
          addressController: guarantor1AddressController,
        ),

        const SizedBox(height: 20),

        // Guarantor 2
        _buildGuarantorCard(
          title: 'Guarantor 2',
          nameController: guarantor2NameController,
          phoneController: guarantor2PhoneController,
          relationshipController: guarantor2RelationshipController,
          emailController: guarantor2EmailController,
          idNumberController: guarantor2IdNumberController,
          occupationController: guarantor2OccupationController,
          addressController: guarantor2AddressController,
        ),
      ],
    );
  }

  Widget _buildGuarantorCard({
    required String title,
    required TextEditingController nameController,
    required TextEditingController phoneController,
    required TextEditingController relationshipController,
    required TextEditingController emailController,
    required TextEditingController idNumberController,
    required TextEditingController occupationController,
    required TextEditingController addressController,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppConstants.textColor,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),

          // Full Name - Required
          _buildTextField(
            controller: nameController,
            label: 'Full Name',
            icon: Icons.person_rounded,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Guarantor name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Phone Number - Required
          _buildTextField(
            controller: phoneController,
            label: 'Phone Number',
            icon: Icons.phone_rounded,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Guarantor phone number is required';
              }
              if (value!.length < 10) {
                return 'Please enter a valid phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Relationship - Required
          _buildTextField(
            controller: relationshipController,
            label: 'Relationship',
            icon: Icons.family_restroom_rounded,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Relationship is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Email - Optional
          _buildTextField(
            controller: emailController,
            label: 'Email (Optional)',
            icon: Icons.email_rounded,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                if (!emailRegex.hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // ID Number - Optional
          _buildTextField(
            controller: idNumberController,
            label: 'ID/Passport Number (Optional)',
            icon: Icons.badge_rounded,
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 12),

          // Occupation - Optional
          _buildTextField(
            controller: occupationController,
            label: 'Occupation (Optional)',
            icon: Icons.work_rounded,
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 12),

          // Physical Address - Optional
          _buildTextField(
            controller: addressController,
            label: 'Physical Address (Optional)',
            icon: Icons.location_on_rounded,
            keyboardType: TextInputType.multiline,
            maxLines: 2,
          ),
        ],
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
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
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
        alignLabelWithHint: maxLines > 1,
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
