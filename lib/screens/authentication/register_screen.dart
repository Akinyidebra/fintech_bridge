import 'dart:convert';

import 'package:fintech_bridge/services/auth_service.dart';
import 'package:fintech_bridge/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fintech_bridge/screens/loading_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  // Controllers for text fields
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Focus nodes for text fields
  final FocusNode _fullNameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _studentIdFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Password visibility state
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  // Terms and conditions checkbox
  bool _agreedToTerms = true;

  // User type selection
  String _selectedRole = 'student'; // Default role is student
  String? _profileImageBase64;
  bool _isLoading = false;

  // Animation controller for fade-in effect
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // List of valid university email domains
  final List<String> _validUniversityDomains = [
    'kabarak.ac.ke',
    'strathmore.edu',
    'uonbi.ac.ke',
    'ku.ac.ke',
    'tukenya.ac.ke',
    'jkuat.ac.ke',
    'usiu.ac.ke',
    'mku.ac.ke',
    'egerton.ac.ke',
    // Add more university domains as needed
    'gmail.com',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    // Dispose controllers
    _fullNameController.dispose();
    _emailController.dispose();
    _studentIdController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    // Dispose focus nodes
    _fullNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _studentIdFocusNode.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();

    // Dispose animation controller
    _animationController.dispose();

    super.dispose();
  }

  // Validate if the email is a university email
  bool _isUniversityEmail(String email) {
    if (email.isEmpty) return false;

    // Extract domain from email
    final domainMatch = RegExp(r'^[^@]+@([^@]+)$').firstMatch(email);
    if (domainMatch == null) return false;

    final domain = domainMatch.group(1)?.toLowerCase();
    return domain != null && _validUniversityDomains.contains(domain);
  }

  // Add image picker method
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _profileImageBase64 = base64Encode(bytes);
      });
    }
  }

  void _register() async {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must agree to the terms')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      // Show loading overlay
      LoadingOverlay.show(context, message: 'Registering...');
      setState(() => _isLoading = true);

      final authService = Provider.of<AuthService>(context, listen: false);

      try {
        final user = await authService.registerWithEmailAndPassword(
          fullName: _fullNameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          studentId: _studentIdController.text,
          phone: _phoneController.text,
          role: _selectedRole,
          profileImageBase64: _profileImageBase64,
          emailValidator: _isUniversityEmail,
        );

        // Hide loading overlay
        LoadingOverlay.hide();

        if (user != null && mounted) {
          Navigator.pushReplacementNamed(context, '/verify-email');
        }
      } catch (e) {
        // Hide loading overlay
        LoadingOverlay.hide();
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration failed: ${e.toString()}')));
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleGoogleSignIn() async {
    // Show loading overlay
    LoadingOverlay.show(context, message: 'Signing in with Google...');

    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      final user = await authService.signInWithGoogle(
        selectedRole: _selectedRole,
        emailValidator: _isUniversityEmail,
      );

      // Hide loading overlay
      LoadingOverlay.hide();

      if (user != null && mounted) {
        // If this is a new user or additional info is required, navigate to complete profile
        if (user.studentId.isEmpty || user.phone.isEmpty) {
          Navigator.pushReplacementNamed(context, '/complete-profile');
        } else {
          // Otherwise, go to home or verification based on verification status
          if (user.isVerified) {
            Navigator.pushReplacementNamed(context, '/home');
          } else {
            Navigator.pushReplacementNamed(context, '/verify-email');
          }
        }
      }
    } catch (e) {
      // Hide loading overlay
      LoadingOverlay.hide();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google sign-in failed: ${e.toString()}')));
    }
  }

  String? _validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Full name is required';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    if (!_isUniversityEmail(value)) {
      return 'Please use a university email';
    }
    return null;
  }

  String? _validateStudentId(String? value) {
    if (value == null || value.isEmpty) {
      return 'Student ID is required';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirm password is required';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Unfocus when tapping outside inputs
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: AppConstants.backgroundColor,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFF9FAFC),
                Color(0xFFEEF1F7),
              ],
            ),
          ),
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // App logo
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 20,
                                spreadRadius: 1,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/icons/logo.png',
                              width: 50,
                              height: 50,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Header
                        Text(
                          'Create Account',
                          style: AppConstants.displaySmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppConstants.textColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppConstants.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Join thousands of students managing their education finances',
                            textAlign: TextAlign.center,
                            style: AppConstants.bodyMedium.copyWith(
                              color: AppConstants.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Profile image picker
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(
                                color:
                                    AppConstants.primaryColor.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: _profileImageBase64 != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(60),
                                    child: Image.memory(
                                      base64Decode(_profileImageBase64!),
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Icon(
                                    Icons.add_a_photo,
                                    size: 40,
                                    color: AppConstants.primaryColor
                                        .withOpacity(0.7),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add profile photo',
                          style: AppConstants.bodyMedium.copyWith(
                            color: AppConstants.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // User Type Selection
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                spreadRadius: 0,
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              const Text(
                                'Account Type',
                                style: AppConstants.headlineSmall,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Select your account type',
                                style: AppConstants.bodyMediumSecondary,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedRole = 'student';
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        decoration: BoxDecoration(
                                          color: _selectedRole == 'student'
                                              ? AppConstants.primaryColor
                                              : Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          border: Border.all(
                                            color: _selectedRole == 'student'
                                                ? AppConstants.primaryColor
                                                : Colors.grey.withOpacity(0.3),
                                            width: 1,
                                          ),
                                          boxShadow: _selectedRole == 'student'
                                              ? [
                                                  BoxShadow(
                                                    color: AppConstants
                                                        .primaryColor
                                                        .withOpacity(0.3),
                                                    blurRadius: 8,
                                                    spreadRadius: 0,
                                                    offset: const Offset(0, 3),
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.school,
                                              size: 28,
                                              color: _selectedRole == 'student'
                                                  ? Colors.white
                                                  : AppConstants
                                                      .textSecondaryColor,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Student',
                                              style: AppConstants.bodyMedium
                                                  .copyWith(
                                                color: _selectedRole ==
                                                        'student'
                                                    ? Colors.white
                                                    : AppConstants.textColor,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedRole = 'provider';
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        decoration: BoxDecoration(
                                          color: _selectedRole == 'provider'
                                              ? AppConstants.primaryColor
                                              : Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          border: Border.all(
                                            color: _selectedRole == 'provider'
                                                ? AppConstants.primaryColor
                                                : Colors.grey.withOpacity(0.3),
                                            width: 1,
                                          ),
                                          boxShadow: _selectedRole == 'provider'
                                              ? [
                                                  BoxShadow(
                                                    color: AppConstants
                                                        .primaryColor
                                                        .withOpacity(0.3),
                                                    blurRadius: 8,
                                                    spreadRadius: 0,
                                                    offset: const Offset(0, 3),
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.business_center,
                                              size: 28,
                                              color: _selectedRole == 'provider'
                                                  ? Colors.white
                                                  : AppConstants
                                                      .textSecondaryColor,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Provider',
                                              style: AppConstants.bodyMedium
                                                  .copyWith(
                                                color: _selectedRole ==
                                                        'provider'
                                                    ? Colors.white
                                                    : AppConstants.textColor,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _selectedRole == 'student'
                                    ? 'Student accounts can apply for loans and access educational financial services.'
                                    : 'Provider accounts can offer loan services and financial products to students.',
                                style: AppConstants.bodySmall.copyWith(
                                  color: AppConstants.textSecondaryColor,
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Personal Information
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                spreadRadius: 0,
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              const Text(
                                'Personal Information',
                                style: AppConstants.headlineSmall,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              // Full Name
                              TextFormField(
                                controller: _fullNameController,
                                focusNode: _fullNameFocusNode,
                                decoration: AppConstants.inputDecoration(
                                  labelText: 'Full Name',
                                  prefixIcon: Icons.person_outline,
                                ),
                                style: AppConstants.bodyLarge,
                                validator: _validateFullName,
                              ),
                              const SizedBox(height: 20),
                              // Email
                              TextFormField(
                                controller: _emailController,
                                focusNode: _emailFocusNode,
                                decoration: AppConstants.inputDecoration(
                                  labelText: 'University Email',
                                  prefixIcon: Icons.mail_outline,
                                ),
                                style: AppConstants.bodyLarge,
                                keyboardType: TextInputType.emailAddress,
                                validator: _validateEmail,
                              ),
                              const SizedBox(height: 20),
                              // Student ID
                              TextFormField(
                                controller: _studentIdController,
                                focusNode: _studentIdFocusNode,
                                decoration: AppConstants.inputDecoration(
                                  labelText: _selectedRole == 'student'
                                      ? 'Student ID'
                                      : 'Provider ID',
                                  prefixIcon: Icons.badge,
                                ),
                                style: AppConstants.bodyLarge,
                                keyboardType: TextInputType.text,
                                validator: _validateStudentId,
                              ),
                              const SizedBox(height: 20),
                              // Phone Number
                              TextFormField(
                                controller: _phoneController,
                                focusNode: _phoneFocusNode,
                                decoration: AppConstants.inputDecoration(
                                  labelText: 'Phone Number',
                                  prefixIcon: Icons.phone,
                                ),
                                style: AppConstants.bodyLarge,
                                keyboardType: TextInputType.phone,
                                validator: _validatePhone,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Security
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                spreadRadius: 0,
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              const Text(
                                'Security',
                                style: AppConstants.headlineSmall,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              // Password
                              TextFormField(
                                controller: _passwordController,
                                focusNode: _passwordFocusNode,
                                obscureText: !_passwordVisible,
                                decoration: AppConstants.inputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: Icons.lock_outline,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _passwordVisible
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      size: 22,
                                      color: AppConstants.textSecondaryColor,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _passwordVisible = !_passwordVisible;
                                      });
                                    },
                                  ),
                                ),
                                style: AppConstants.bodyLarge,
                                validator: _validatePassword,
                              ),
                              const SizedBox(height: 20),
                              // Confirm Password
                              TextFormField(
                                controller: _confirmPasswordController,
                                focusNode: _confirmPasswordFocusNode,
                                obscureText: !_confirmPasswordVisible,
                                decoration: AppConstants.inputDecoration(
                                  labelText: 'Confirm Password',
                                  prefixIcon: Icons.lock_outline,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _confirmPasswordVisible
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      size: 22,
                                      color: AppConstants.textSecondaryColor,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _confirmPasswordVisible =
                                            !_confirmPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                                style: AppConstants.bodyLarge,
                                validator: _validateConfirmPassword,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Verification info
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                spreadRadius: 0,
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(
                                  'Account Verification',
                                  style: AppConstants.headlineSmall,
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Your account requires verification with valid university credentials. This helps us ensure secure access to student loan services.',
                                  style: AppConstants.bodyMediumSecondary,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Terms and conditions
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Checkbox(
                              value: _agreedToTerms,
                              onChanged: (newValue) {
                                setState(() {
                                  _agreedToTerms = newValue!;
                                });
                              },
                              activeColor: AppConstants.primaryColor,
                            ),
                            Expanded(
                              child: Text(
                                'I agree to the Terms & Conditions and Privacy Policy',
                                style: AppConstants.bodyMedium.copyWith(
                                    color: AppConstants.textSecondaryColor),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Register button
                        AppConstants.gradientButton(
                          text: 'Register',
                          onPressed: _agreedToTerms
                              ? _register
                              : () {}, // Empty function instead of null
                          isLoading: _isLoading,
                        ),
                        const SizedBox(height: 20),

                        // Divider
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 1,
                                color: Colors.grey.withOpacity(0.3),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'OR',
                                style: AppConstants.bodyMedium.copyWith(
                                  color: AppConstants.textSecondaryColor,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 1,
                                color: Colors.grey.withOpacity(0.3),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Google sign-in
                        ElevatedButton.icon(
                          icon: const FaIcon(
                            FontAwesomeIcons.google,
                            color: Colors.red,
                            size: 18,
                          ),
                          label: Text(
                            'Continue with Google',
                            style: AppConstants.bodyMedium.copyWith(
                              color: AppConstants.textColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppConstants.textColor,
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                              side: BorderSide(
                                color: Colors.grey.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 24,
                            ),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          onPressed: _handleGoogleSignIn,
                        ),
                        const SizedBox(height: 24),

                        // Login link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: AppConstants.bodyMedium.copyWith(
                                color: AppConstants.textSecondaryColor,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                    context, '/login');
                              },
                              child: Text(
                                'Login',
                                style: AppConstants.bodyMedium.copyWith(
                                  color: AppConstants.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Add some bottom padding for scrolling
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
