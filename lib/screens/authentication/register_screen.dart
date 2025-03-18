import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  static String routeName = '/register';
  static String routePath = '/register';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controllers for text fields
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

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

    super.dispose();
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      // Registration logic would go here
      print('Registration form is valid. Proceeding with registration...');
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!value.contains('@')) {
      return 'Enter a valid email address';
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
        body: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create Account',
                    style: AppConstants.displaySmall,
                  ),
                  Text(
                    'Join thousands of students managing their education finances with ease',
                    style: AppConstants.bodyLargeSecondary,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: AppConstants.containerDecoration,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          TextFormField(
                            controller: _fullNameController,
                            focusNode: _fullNameFocusNode,
                            decoration: AppConstants.inputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: Icons.person_outline,
                            ),
                            style: AppConstants.bodyLarge,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Full name is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
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
                          TextFormField(
                            controller: _studentIdController,
                            focusNode: _studentIdFocusNode,
                            decoration: AppConstants.inputDecoration(
                              labelText: 'Student ID',
                              prefixIcon: Icons.badge,
                            ),
                            style: AppConstants.bodyLarge,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Student ID is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _phoneController,
                            focusNode: _phoneFocusNode,
                            decoration: AppConstants.inputDecoration(
                              labelText: 'Phone Number',
                              prefixIcon: Icons.phone,
                            ),
                            style: AppConstants.bodyLarge,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Phone number is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
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
                                ),
                                onPressed: () {
                                  setState(() {
                                    _confirmPasswordVisible = !_confirmPasswordVisible;
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
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: AppConstants.containerDecoration,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            'Account Verification',
                            style: AppConstants.headlineSmall,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Your account requires verification with valid university credentials. This helps us ensure secure access to student loan services.',
                            style: AppConstants.bodyMediumSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
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
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'I agree to the Terms & Conditions and Privacy Policy',
                          style: AppConstants.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _agreedToTerms ? _register : null,
                    style: AppConstants.primaryButtonStyle,
                    child: const Text('Register'),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: AppConstants.bodyMediumSecondary,
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          // Navigate to login screen
                          print('Navigate to login screen');
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
    );
  }
}
