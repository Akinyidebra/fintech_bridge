import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:fintech_bridge/services/auth_service.dart';
import 'package:fintech_bridge/services/database_service.dart';
import 'package:fintech_bridge/utils/constants.dart';
import 'package:fintech_bridge/models/student_model.dart';
import 'package:fintech_bridge/widgets/profile_tab.dart';
import 'package:fintech_bridge/widgets/password_tab.dart';
import 'package:fintech_bridge/widgets/documents_tab.dart';

class EditProfileModal extends StatefulWidget {
  final Student student;

  const EditProfileModal({
    super.key,
    required this.student,
  });

  @override
  State<EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends State<EditProfileModal>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _phoneController;
  late TextEditingController _mpesaPhoneController;
  late TextEditingController _courseController;
  late TextEditingController _yearController;
  late TextEditingController _institutionController;

  // Password form controllers
  final _passwordFormKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Guarantor form controllers - Guarantor 1
  final _guarantor1NameController = TextEditingController();
  final _guarantor1PhoneController = TextEditingController();
  final _guarantor1RelationshipController = TextEditingController();
  final _guarantor1EmailController = TextEditingController();
  final _guarantor1IdNumberController = TextEditingController();
  final _guarantor1OccupationController = TextEditingController();
  final _guarantor1AddressController = TextEditingController();

  // Guarantor form controllers - Guarantor 2
  final _guarantor2NameController = TextEditingController();
  final _guarantor2PhoneController = TextEditingController();
  final _guarantor2RelationshipController = TextEditingController();
  final _guarantor2EmailController = TextEditingController();
  final _guarantor2IdNumberController = TextEditingController();
  final _guarantor2OccupationController = TextEditingController();
  final _guarantor2AddressController = TextEditingController();

  // Image files
  File? _profileImage;
  File? _nationalIdFront;
  File? _nationalIdBack;
  File? _studentIdFront;
  File? _studentIdBack;

  // Loading states
  bool _isUpdatingProfile = false;
  bool _isChangingPassword = false;
  bool _isUploadingImages = false;

  // Password visibility
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Initialize controllers with current data
    _phoneController = TextEditingController(text: widget.student.phone);
    _mpesaPhoneController =
        TextEditingController(text: widget.student.mpesaPhone);
    _courseController = TextEditingController(text: widget.student.course);
    _yearController =
        TextEditingController(text: widget.student.yearOfStudy.toString());
    _institutionController =
        TextEditingController(text: widget.student.institutionName);

    // Initialize guarantor controllers with existing data
    _initializeGuarantorData();
  }

  void _initializeGuarantorData() {
    // Load Guarantor 1 data if exists
    if (widget.student.guarantor1Details != null) {
      final g1 = widget.student.guarantor1Details!;
      _guarantor1NameController.text = g1['fullName'] ?? '';
      _guarantor1PhoneController.text = g1['phoneNumber'] ?? '';
      _guarantor1RelationshipController.text = g1['relationship'] ?? '';
      _guarantor1EmailController.text = g1['email'] ?? '';
      _guarantor1IdNumberController.text = g1['idNumber'] ?? '';
      _guarantor1OccupationController.text = g1['occupation'] ?? '';
      _guarantor1AddressController.text = g1['physicalAddress'] ?? '';
    }

    // Load Guarantor 2 data if exists
    if (widget.student.guarantor2Details != null) {
      final g2 = widget.student.guarantor2Details!;
      _guarantor2NameController.text = g2['fullName'] ?? '';
      _guarantor2PhoneController.text = g2['phoneNumber'] ?? '';
      _guarantor2RelationshipController.text = g2['relationship'] ?? '';
      _guarantor2EmailController.text = g2['email'] ?? '';
      _guarantor2IdNumberController.text = g2['idNumber'] ?? '';
      _guarantor2OccupationController.text = g2['occupation'] ?? '';
      _guarantor2AddressController.text = g2['physicalAddress'] ?? '';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _phoneController.dispose();
    _mpesaPhoneController.dispose();
    _courseController.dispose();
    _yearController.dispose();
    _institutionController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    
    // Dispose guarantor controllers
    _guarantor1NameController.dispose();
    _guarantor1PhoneController.dispose();
    _guarantor1RelationshipController.dispose();
    _guarantor1EmailController.dispose();
    _guarantor1IdNumberController.dispose();
    _guarantor1OccupationController.dispose();
    _guarantor1AddressController.dispose();
    
    _guarantor2NameController.dispose();
    _guarantor2PhoneController.dispose();
    _guarantor2RelationshipController.dispose();
    _guarantor2EmailController.dispose();
    _guarantor2IdNumberController.dispose();
    _guarantor2OccupationController.dispose();
    _guarantor2AddressController.dispose();
    
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
      child: Column(
        children: [
          _buildModalHeader(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                ProfileTab(
                  formKey: _formKey,
                  phoneController: _phoneController,
                  mpesaPhoneController: _mpesaPhoneController,
                  courseController: _courseController,
                  yearController: _yearController,
                  institutionController: _institutionController,
                  isUpdatingProfile: _isUpdatingProfile,
                  onUpdateProfile: _updateProfile,
                  // Guarantor 1 controllers
                  guarantor1NameController: _guarantor1NameController,
                  guarantor1PhoneController: _guarantor1PhoneController,
                  guarantor1RelationshipController: _guarantor1RelationshipController,
                  guarantor1EmailController: _guarantor1EmailController,
                  guarantor1IdNumberController: _guarantor1IdNumberController,
                  guarantor1OccupationController: _guarantor1OccupationController,
                  guarantor1AddressController: _guarantor1AddressController,
                  // Guarantor 2 controllers
                  guarantor2NameController: _guarantor2NameController,
                  guarantor2PhoneController: _guarantor2PhoneController,
                  guarantor2RelationshipController: _guarantor2RelationshipController,
                  guarantor2EmailController: _guarantor2EmailController,
                  guarantor2IdNumberController: _guarantor2IdNumberController,
                  guarantor2OccupationController: _guarantor2OccupationController,
                  guarantor2AddressController: _guarantor2AddressController,
                  onPickProfileImage: _pickProfileImage,
                  profileImage: _profileImage,
                  currentProfileImageBase64: widget.student.profileImage,
                ),
                PasswordTab(
                  passwordFormKey: _passwordFormKey,
                  currentPasswordController: _currentPasswordController,
                  newPasswordController: _newPasswordController,
                  confirmPasswordController: _confirmPasswordController,
                  showCurrentPassword: _showCurrentPassword,
                  showNewPassword: _showNewPassword,
                  showConfirmPassword: _showConfirmPassword,
                  isChangingPassword: _isChangingPassword,
                  onToggleCurrentPassword: () {
                    setState(() {
                      _showCurrentPassword = !_showCurrentPassword;
                    });
                  },
                  onToggleNewPassword: () {
                    setState(() {
                      _showNewPassword = !_showNewPassword;
                    });
                  },
                  onToggleConfirmPassword: () {
                    setState(() {
                      _showConfirmPassword = !_showConfirmPassword;
                    });
                  },
                  onChangePassword: _changePassword,
                ),
                DocumentsTab(
                  nationalIdFront: _nationalIdFront,
                  nationalIdBack: _nationalIdBack,
                  studentIdFront: _studentIdFront,
                  studentIdBack: _studentIdBack,
                  isUploadingImages: _isUploadingImages,
                  onPickImage: _pickImage,
                  onUploadDocuments: _uploadDocuments,
                ),
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
            'Edit Profile',
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
          Tab(text: 'Profile'),
          Tab(text: 'Password'),
          Tab(text: 'Documents'),
        ],
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
            case 'national_id_front':
              _nationalIdFront = File(image.path);
              break;
            case 'national_id_back':
              _nationalIdBack = File(image.path);
              break;
            case 'student_id_front':
              _studentIdFront = File(image.path);
              break;
            case 'student_id_back':
              _studentIdBack = File(image.path);
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

    setState(() {
      _isUpdatingProfile = true;
    });

    try {
      final dbService = Provider.of<DatabaseService>(context, listen: false);

      // Prepare structured guarantor details
      Map<String, dynamic>? guarantorDetails;
      
      // Build guarantor 1 data if any field is filled
      Map<String, dynamic>? guarantor1Data;
      if (_guarantor1NameController.text.trim().isNotEmpty ||
          _guarantor1PhoneController.text.trim().isNotEmpty) {
        guarantor1Data = {
          'fullName': _guarantor1NameController.text.trim(),
          'phoneNumber': _guarantor1PhoneController.text.trim(),
          'relationship': _guarantor1RelationshipController.text.trim(),
          'email': _guarantor1EmailController.text.trim(),
          'idNumber': _guarantor1IdNumberController.text.trim(),
          'occupation': _guarantor1OccupationController.text.trim(),
          'physicalAddress': _guarantor1AddressController.text.trim(),
          'addedAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        };
      }
      
      // Build guarantor 2 data if any field is filled
      Map<String, dynamic>? guarantor2Data;
      if (_guarantor2NameController.text.trim().isNotEmpty ||
          _guarantor2PhoneController.text.trim().isNotEmpty) {
        guarantor2Data = {
          'fullName': _guarantor2NameController.text.trim(),
          'phoneNumber': _guarantor2PhoneController.text.trim(),
          'relationship': _guarantor2RelationshipController.text.trim(),
          'email': _guarantor2EmailController.text.trim(),
          'idNumber': _guarantor2IdNumberController.text.trim(),
          'occupation': _guarantor2OccupationController.text.trim(),
          'physicalAddress': _guarantor2AddressController.text.trim(),
          'addedAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        };
      }

      // Create guarantorDetails object if we have any guarantor data
      if (guarantor1Data != null || guarantor2Data != null) {
        guarantorDetails = {};
        if (guarantor1Data != null) {
          guarantorDetails['guarantor1'] = guarantor1Data;
        }
        if (guarantor2Data != null) {
          guarantorDetails['guarantor2'] = guarantor2Data;
        }
      }

      final updateData = {
        'phone': _phoneController.text.trim(),
        'mpesaPhone': _mpesaPhoneController.text.trim(),
        'course': _courseController.text.trim(),
        'yearOfStudy': double.parse(_yearController.text.trim()),
        'institutionName': _institutionController.text.trim(),
        'guarantorDetails': guarantorDetails,
        'updatedAt': DateTime.now(),
      };

      // Handle profile image upload if a new image is selected
      if (_profileImage != null) {
        try {
          // Convert image to base64
          final bytes = await _profileImage!.readAsBytes();
          final base64String = base64Encode(bytes);
          updateData['profileImage'] = 'data:image/jpeg;base64,$base64String';
        } catch (e) {
          _showErrorSnackBar('Failed to process profile image: ${e.toString()}');
          return;
        }
      }

      final result = await dbService.updateUserProfile(updateData);

      if (result['success']) {
        _showSuccessSnackBar('Profile updated successfully');
        Navigator.of(context).pop(true);
      } else {
        _showErrorSnackBar(result['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to update profile: ${e.toString()}');
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
        // Clear the form fields
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        // Close the modal and return to profile screen
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
    if (_nationalIdFront == null ||
        _nationalIdBack == null ||
        _studentIdFront == null ||
        _studentIdBack == null) {
      _showErrorSnackBar('Please select all required documents');
      return;
    }

    setState(() {
      _isUploadingImages = true;
    });

    try {
      final dbService = Provider.of<DatabaseService>(context, listen: false);

      final result = await dbService.uploadIdentificationImages(
        nationalIdFront: _nationalIdFront!,
        nationalIdBack: _nationalIdBack!,
        studentIdFront: _studentIdFront!,
        studentIdBack: _studentIdBack!,
      );

      if (result['success']) {
        _showSuccessSnackBar('Documents uploaded successfully');
        // Clear the selected images after successful upload
        setState(() {
          _nationalIdFront = null;
          _nationalIdBack = null;
          _studentIdFront = null;
          _studentIdBack = null;
        });
        // Close the modal and return to profile screen
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