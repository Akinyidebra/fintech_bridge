import 'package:fintech_bridge/models/admin_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:fintech_bridge/services/auth_service.dart';
import 'package:fintech_bridge/services/database_service.dart';
import 'package:fintech_bridge/utils/constants.dart';

class AdminEditProfileModal extends StatefulWidget {
  final Admin admin;

  const AdminEditProfileModal({
    super.key, 
    required this.admin,
  });

  @override
  State<AdminEditProfileModal> createState() =>
      _AdminEditProfileModalState();
}

class _AdminEditProfileModalState extends State<AdminEditProfileModal>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Form controllers for admin information
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _adminEmailController;
  late TextEditingController _phoneController;
  late TextEditingController _roleController;

  // Password form controllers
  final _passwordFormKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Image files
  File? _profileImage;

  // Loading states
  bool _isUpdatingProfile = false;
  bool _isChangingPassword = false;

  // Password visibility
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  // Add loading state variable
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Only 2 tabs for admin
    _initializeControllers();
  }

  void _initializeControllers() {
    // Initialize controllers with admin data
    _fullNameController = TextEditingController(text: widget.admin.fullName);
    _adminEmailController = TextEditingController(text: widget.admin.adminEmail);
    _phoneController = TextEditingController(text: widget.admin.phone ?? '');
    _roleController = TextEditingController(text: widget.admin.role);

    // Set loading to false after initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fullNameController.dispose();
    _adminEmailController.dispose();
    _phoneController.dispose();
    _roleController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: AppConstants.primaryColor,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading admin profile...',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppConstants.textColor,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                _buildModalHeader(),
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildProfileTab(),
                      _buildPasswordTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildModalHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.edit_rounded,
            color: AppConstants.primaryColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          const Text(
            'Edit Admin Profile',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppConstants.textColor,
              fontFamily: 'Poppins',
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
            color: AppConstants.textColor.withOpacity(0.6),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppConstants.primaryColor,
        unselectedLabelColor: AppConstants.textColor.withOpacity(0.6),
        indicatorColor: AppConstants.primaryColor,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
        tabs: const [
          Tab(text: 'Admin Profile'),
          Tab(text: 'Password'),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image Section
            _buildProfileImageSection(),
            const SizedBox(height: 24),

            // Admin Information
            _buildSectionTitle('Admin Information'),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _fullNameController,
              label: 'Full Name',
              icon: Icons.person,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Full name is required';
                return null;
              },
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _adminEmailController,
              label: 'Admin Email',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Admin email is required';
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value!)) {
                  return 'Enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _phoneController,
              label: 'Phone Number (Optional)',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _roleController,
              label: 'Role',
              icon: Icons.admin_panel_settings,
              readOnly: true, // Admin role should not be editable
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Role is required';
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Update Button
            _buildUpdateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImageSection() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickProfileImage,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppConstants.primaryColor.withOpacity(0.3),
                  width: 3,
                ),
              ),
              child: ClipOval(
                child: _profileImage != null
                    ? Image.file(_profileImage!, fit: BoxFit.cover)
                    : (widget.admin.profileImage != null &&
                            widget.admin.profileImage!.isNotEmpty)
                        ? Image.memory(
                            base64Decode(widget.admin.profileImage!
                                    .contains(',')
                                ? widget.admin.profileImage!.split(',')[1]
                                : widget.admin.profileImage!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color:
                                    AppConstants.primaryColor.withOpacity(0.1),
                                child: const Icon(
                                  Icons.admin_panel_settings,
                                  size: 40,
                                  color: AppConstants.primaryColor,
                                ),
                              );
                            },
                          )
                        : Container(
                            color: AppConstants.primaryColor.withOpacity(0.1),
                            child: const Icon(
                              Icons.admin_panel_settings,
                              size: 40,
                              color: AppConstants.primaryColor,
                            ),
                          ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tap to change profile picture',
            style: TextStyle(
              fontSize: 14,
              color: AppConstants.textColor.withOpacity(0.6),
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _passwordFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Change Password'),
            const SizedBox(height: 16),
            _buildPasswordField(
              controller: _currentPasswordController,
              label: 'Current Password',
              isVisible: _showCurrentPassword,
              onToggleVisibility: () {
                setState(() {
                  _showCurrentPassword = !_showCurrentPassword;
                });
              },
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Current password is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildPasswordField(
              controller: _newPasswordController,
              label: 'New Password',
              isVisible: _showNewPassword,
              onToggleVisibility: () {
                setState(() {
                  _showNewPassword = !_showNewPassword;
                });
              },
              validator: (value) {
                if (value?.isEmpty ?? true) return 'New password is required';
                if (value!.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildPasswordField(
              controller: _confirmPasswordController,
              label: 'Confirm New Password',
              isVisible: _showConfirmPassword,
              onToggleVisibility: () {
                setState(() {
                  _showConfirmPassword = !_showConfirmPassword;
                });
              },
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please confirm your password';
                }
                if (value != _newPasswordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            _buildChangePasswordButton(),
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
    int maxLines = 1,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppConstants.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: AppConstants.primaryColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppConstants.primaryColor, width: 2),
        ),
        labelStyle: const TextStyle(fontFamily: 'Poppins'),
        filled: readOnly,
        fillColor: readOnly ? Colors.grey.withOpacity(0.1) : null,
      ),
      style: const TextStyle(fontFamily: 'Poppins'),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock, color: AppConstants.primaryColor),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility : Icons.visibility_off,
            color: AppConstants.primaryColor,
          ),
          onPressed: onToggleVisibility,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: AppConstants.primaryColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppConstants.primaryColor, width: 2),
        ),
        labelStyle: const TextStyle(fontFamily: 'Poppins'),
      ),
      style: const TextStyle(fontFamily: 'Poppins'),
    );
  }

  Widget _buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isUpdatingProfile ? null : _updateProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isUpdatingProfile
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Update Admin Profile',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
      ),
    );
  }

  Widget _buildChangePasswordButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isChangingPassword ? null : _changePassword,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isChangingPassword
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Change Password',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
      ),
    );
  }

  Future<void> _pickProfileImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: ${e.toString()}');
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isUpdatingProfile = true;
    });

    try {
      final dbService = Provider.of<DatabaseService>(context, listen: false);

      // Get current user ID (admin ID)
      final currentUser = dbService.currentUser;
      if (currentUser == null) {
        _showErrorSnackBar('No user signed in');
        return;
      }

      final adminId = widget.admin.id;

      final updateData = {
        'fullName': _fullNameController.text.trim(),
        'adminEmail': _adminEmailController.text.trim(),
        'phone': _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : null,
        'role': _roleController.text.trim(),
        'updatedAt': DateTime.now(),
      };

      // Handle profile image upload if a new image is selected
      if (_profileImage != null) {
        try {
          final bytes = await _profileImage!.readAsBytes();
          final base64String = base64Encode(bytes);
          updateData['profileImage'] = 'data:image/jpeg;base64,$base64String';
        } catch (e) {
          _showErrorSnackBar(
              'Failed to process profile image: ${e.toString()}');
          return;
        }
      }

      // Call the service method with correct parameters
      final result =
          await dbService.updateAdminProfile(adminId, updateData);

      if (result['success']) {
        _showSuccessSnackBar('Admin profile updated successfully');
        Navigator.of(context).pop(true);
      } else {
        _showErrorSnackBar(
            result['message'] ?? 'Failed to update admin profile');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to update admin profile: ${e.toString()}');
    } finally {
      setState(() {
        _isUpdatingProfile = false;
      });
    }
  }

  Future<void> _changePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;

    setState(() {
      _isChangingPassword = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);

      final result = await authService.changePassword(
        _currentPasswordController.text,
        _newPasswordController.text,
      );

      if (result['success']) {
        _showSuccessSnackBar('Password changed successfully');
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        Navigator.of(context).pop(true);
      } else {
        _showErrorSnackBar(result['message'] ?? 'Failed to change password');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to change password: ${e.toString()}');
    } finally {
      setState(() {
        _isChangingPassword = false;
      });
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: AppConstants.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: AppConstants.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}