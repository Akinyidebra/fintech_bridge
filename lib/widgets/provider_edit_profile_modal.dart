import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:fintech_bridge/services/auth_service.dart';
import 'package:fintech_bridge/services/database_service.dart';
import 'package:fintech_bridge/utils/constants.dart';
import 'package:fintech_bridge/models/provider_model.dart' as provider_model;

class ProviderEditProfileModal extends StatefulWidget {
  final provider_model.Provider? provider;

  const ProviderEditProfileModal({
    super.key,
    required this.provider,
  });

  @override
  State<ProviderEditProfileModal> createState() =>
      _ProviderEditProfileModalState();
}

class _ProviderEditProfileModalState extends State<ProviderEditProfileModal>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Form controllers for provider information
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _businessNameController;
  late TextEditingController _businessEmailController;
  late TextEditingController _phoneController;
  late TextEditingController _businessTypeController;
  late TextEditingController _websiteController;
  late TextEditingController _descriptionController;
  late TextEditingController _interestRateController;

  // Selected loan types
  List<String> _selectedLoanTypes = [];
  // Updated loan types list with comprehensive university student options
  final List<String> _availableLoanTypes = [
    'Student Loan',
    'Tuition Fee Loan',
    'Accommodation Loan',
    'Textbook & Supplies Loan',
    'Study Abroad Loan',
    'Research Project Loan',
    'Graduation Loan',
    'Laptop & Equipment Loan',
    'Transport & Commute Loan',
    'Exam Fee Loan',
    'Internship Support Loan',
    'Thesis & Project Loan',
    'Student Housing Loan',
    'Campus Meal Plan Loan',
    'University Event Loan',
    'Field Trip Loan',
    'Student Organization Loan',
    'Postgraduate Study Loan',
    'Professional Course Loan',
    'Certification Exam Loan',
    'Library & Study Materials',
    'Laboratory Equipment Loan',
    'Student Conference Loan',
    'Academic Workshop Loan',
    'Online Course Loan',
    'Language Course Loan',
    'Skills Development Loan',
    'Career Training Loan',
    'Interview Preparation Loan',
    'Job Search Support Loan',
    'Professional Networking Loan',
    'Student Entrepreneurship Loan',
    'Co-curricular Activities Loan',
    'Sports Equipment Loan',
    'Art & Creative Supplies Loan',
    'Music Instrument Loan',
    'Photography Equipment Loan',
    'Technology Upgrade Loan',
    'Software License Loan',
    'Student Mental Health Support',
  ];

  // Password form controllers
  final _passwordFormKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Image files
  File? _profileImage;
  File? _businessLicenseFront;
  File? _businessLicenseBack;
  File? _taxCertificate;
  File? _bankStatement;

  // Loading states
  bool _isUpdatingProfile = false;
  bool _isChangingPassword = false;
  bool _isUploadingImages = false;

  // Password visibility
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  // Add loading state variable
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeControllers();
  }

  void _initializeControllers() {
    // Initialize controllers with empty values first
    _businessNameController = TextEditingController();
    _businessEmailController = TextEditingController();
    _phoneController = TextEditingController();
    _businessTypeController = TextEditingController();
    _websiteController = TextEditingController();
    _descriptionController = TextEditingController();
    _interestRateController = TextEditingController();
    _selectedLoanTypes = <String>[];

    // Wait for provider data to be available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProviderData();
    });
  }

  void _loadProviderData() {
    if (widget.provider != null) {
      setState(() {
        // Update controllers with provider data
        _businessNameController.text = widget.provider!.businessName;
        _businessEmailController.text = widget.provider!.businessEmail;
        _phoneController.text = widget.provider!.phone;
        _businessTypeController.text = widget.provider!.businessType;
        _websiteController.text = widget.provider!.website ?? '';
        _descriptionController.text = widget.provider!.description ?? '';
        _interestRateController.text = widget.provider!.interestRate.toString();

        // Initialize selected loan types with proper null safety
        _selectedLoanTypes = <String>[];
        if (widget.provider!.loanTypes.isNotEmpty) {
          try {
            // Ensure we're working with a proper list
            final loanTypesList = widget.provider!.loanTypes;
            _selectedLoanTypes = loanTypesList.cast<String>().toList();
          } catch (e) {
            print('Error initializing loan types: $e');
            _selectedLoanTypes = <String>[];
          }
        }

        _isLoading = false;
      });
    } else {
      // If provider is null, still set loading to false after a brief delay
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _businessNameController.dispose();
    _businessEmailController.dispose();
    _phoneController.dispose();
    _businessTypeController.dispose();
    _websiteController.dispose();
    _descriptionController.dispose();
    _interestRateController.dispose();
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
                    'Loading business profile...',
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
                      _buildDocumentsTab(),
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
            'Edit Business Profile',
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
          Tab(text: 'Business Profile'),
          Tab(text: 'Password'),
          Tab(text: 'Documents'),
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

            // Business Information
            _buildSectionTitle('Business Information'),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _businessNameController,
              label: 'Business Name',
              icon: Icons.business,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Business name is required';
                return null;
              },
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _businessEmailController,
              label: 'Business Email',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Business email is required';
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
              label: 'Phone Number',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Phone number is required';
                return null;
              },
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _businessTypeController,
              label: 'Business Type',
              icon: Icons.category,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Business type is required';
                return null;
              },
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _websiteController,
              label: 'Website (Optional)',
              icon: Icons.web,
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _interestRateController,
              label: 'Interest Rate (%)',
              icon: Icons.percent,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Interest rate is required';
                final rate = double.tryParse(value!);
                if (rate == null || rate < 0 || rate > 100) {
                  return 'Enter a valid interest rate (0-100)';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _descriptionController,
              label: 'Business Description (Optional)',
              icon: Icons.description,
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Loan Types Section
            _buildSectionTitle('Loan Types Offered'),
            const SizedBox(height: 16),
            _buildLoanTypesSelection(),
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
                    : (widget.provider?.profileImage != null &&
                            widget.provider!.profileImage!.isNotEmpty)
                        ? Image.memory(
                            base64Decode(widget.provider!.profileImage!
                                    .contains(',')
                                ? widget.provider!.profileImage!.split(',')[1]
                                : widget.provider!.profileImage!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color:
                                    AppConstants.primaryColor.withOpacity(0.1),
                                child: const Icon(
                                  Icons.business,
                                  size: 40,
                                  color: AppConstants.primaryColor,
                                ),
                              );
                            },
                          )
                        : Container(
                            color: AppConstants.primaryColor.withOpacity(0.1),
                            child: const Icon(
                              Icons.business,
                              size: 40,
                              color: AppConstants.primaryColor,
                            ),
                          ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tap to change business logo',
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

  Widget _buildLoanTypesSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableLoanTypes.map((loanType) {
            final isSelected = _selectedLoanTypes.contains(loanType);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedLoanTypes.remove(loanType);
                  } else {
                    _selectedLoanTypes.add(loanType);
                  }
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppConstants.primaryColor
                      : AppConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppConstants.primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  loanType,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color:
                        isSelected ? Colors.white : AppConstants.primaryColor,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (_selectedLoanTypes.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Please select at least one loan type',
              style: TextStyle(
                fontSize: 12,
                color: AppConstants.errorColor,
                fontFamily: 'Poppins',
              ),
            ),
          ),
      ],
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

  Widget _buildDocumentsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Business Documents'),
          const SizedBox(height: 16),
          _buildDocumentUploadCard(
            'Business License (Front)',
            _businessLicenseFront,
            'business_license_front',
            Icons.document_scanner,
          ),
          const SizedBox(height: 16),
          _buildDocumentUploadCard(
            'Business License (Back)',
            _businessLicenseBack,
            'business_license_back',
            Icons.document_scanner,
          ),
          const SizedBox(height: 16),
          _buildDocumentUploadCard(
            'Tax Certificate',
            _taxCertificate,
            'tax_certificate',
            Icons.receipt_long,
          ),
          const SizedBox(height: 16),
          _buildDocumentUploadCard(
            'Bank Statement',
            _bankStatement,
            'bank_statement',
            Icons.account_balance,
          ),
          const SizedBox(height: 32),
          _buildUploadDocumentsButton(),
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
      maxLines: maxLines,
      validator: validator,
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

  Widget _buildDocumentUploadCard(
      String title, File? file, String imageType, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppConstants.primaryColor.withOpacity(0.3)),
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
          Icon(icon, color: AppConstants.primaryColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
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
                if (file != null)
                  const Text(
                    'Image selected',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppConstants.successColor,
                      fontFamily: 'Poppins',
                    ),
                  ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _pickImage(imageType),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(
              file != null ? 'Change' : 'Select',
              style: const TextStyle(fontFamily: 'Poppins'),
            ),
          ),
        ],
      ),
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
                'Update Business Profile',
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

  Widget _buildUploadDocumentsButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isUploadingImages ? null : _uploadDocuments,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isUploadingImages
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Upload Documents',
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

  Future<void> _pickImage(String imageType) async {
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
          switch (imageType) {
            case 'business_license_front':
              _businessLicenseFront = File(image.path);
              break;
            case 'business_license_back':
              _businessLicenseBack = File(image.path);
              break;
            case 'tax_certificate':
              _taxCertificate = File(image.path);
              break;
            case 'bank_statement':
              _bankStatement = File(image.path);
              break;
          }
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: ${e.toString()}');
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedLoanTypes.isEmpty) {
      _showErrorSnackBar('Please select at least one loan type');
      return;
    }

    setState(() {
      _isUpdatingProfile = true;
    });

    try {
      final dbService = Provider.of<DatabaseService>(context, listen: false);

      // Get current user ID (provider ID)
      final currentUser = dbService.currentUser;
      if (currentUser == null) {
        _showErrorSnackBar('No user signed in');
        return;
      }

      final providerId = currentUser.uid;

      // Parse interest rate safely
      double interestRate = 0.0;
      try {
        interestRate = double.parse(_interestRateController.text.trim());
      } catch (e) {
        _showErrorSnackBar('Please enter a valid interest rate');
        return;
      }

      final updateData = {
        'businessName': _businessNameController.text.trim(),
        'businessEmail': _businessEmailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'businessType': _businessTypeController.text.trim(),
        'website': _websiteController.text.trim().isNotEmpty
            ? _websiteController.text.trim()
            : null,
        'description': _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        'interestRate': interestRate,
        'loanTypes': List<String>.from(
            _selectedLoanTypes), // Ensure proper list conversion
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
          await dbService.updateProviderProfile(providerId, updateData);

      if (result['success']) {
        _showSuccessSnackBar('Business profile updated successfully');
        Navigator.of(context).pop(true);
      } else {
        _showErrorSnackBar(
            result['message'] ?? 'Failed to update business profile');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to update business profile: ${e.toString()}');
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

  Future<void> _uploadDocuments() async {
    if (_businessLicenseFront == null ||
        _businessLicenseBack == null ||
        _taxCertificate == null ||
        _bankStatement == null) {
      _showErrorSnackBar('Please select all required documents');
      return;
    }

    setState(() {
      _isUploadingImages = true;
    });

    try {
      final dbService = Provider.of<DatabaseService>(context, listen: false);

      final result = await dbService.uploadProviderIdentificationImages(
        businessLicenseFront: _businessLicenseFront!,
        businessLicenseBack: _businessLicenseBack!,
        taxCertificate: _taxCertificate!,
        bankStatement: _bankStatement!,
      );

      if (result['success']) {
        _showSuccessSnackBar('Business documents uploaded successfully');
        setState(() {
          _businessLicenseFront = null;
          _businessLicenseBack = null;
          _taxCertificate = null;
          _bankStatement = null;
        });
        Navigator.of(context).pop(true);
      } else {
        _showErrorSnackBar(result['message'] ?? 'Failed to upload documents');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to upload documents: ${e.toString()}');
    } finally {
      setState(() {
        _isUploadingImages = false;
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
