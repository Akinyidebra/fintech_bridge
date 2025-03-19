import 'package:fintech_bridge/services/auth_service.dart';
import 'package:fintech_bridge/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fintech_bridge/screens/loading_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _passwordVisibility = false;
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
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
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

  void _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    // Check if it's a university email
    if (!_isUniversityEmail(_emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please use a valid university email')));
      return;
    }

    // Show loading overlay
    LoadingOverlay.show(context, message: 'Logging in...');

    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      final user = await authService.loginWithEmailAndPassword(
        _emailController.text,
        _passwordController.text,
      );

      // Hide loading overlay
      LoadingOverlay.hide();

      if (user != null && mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      // Hide loading overlay
      LoadingOverlay.hide();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${e.toString()}')));
    }
  }

  void _handleGoogleSignIn() async {
    // Show loading overlay
    LoadingOverlay.show(context, message: 'Signing in with Google...');

    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      // Use the loginWithGoogle method instead of signInWithGoogle
      final user = await authService.loginWithGoogle(
        emailValidator: _isUniversityEmail,
      );

      // Hide loading overlay
      LoadingOverlay.hide();

      if (user != null && mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      // Hide loading overlay
      LoadingOverlay.hide();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google sign-in failed: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get device size to ensure proper fitting
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppConstants.backgroundColor,
        // Use SafeArea to respect device dimensions
        body: Container(
          height: size.height,
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
              // Use SingleChildScrollView to ensure scrollability on small devices
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        // Logo with shadow
                        Container(
                          width: 100,
                          height: 100,
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
                              width: 60,
                              height: 60,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Welcome text
                        Text(
                          'Welcome Back',
                          style: AppConstants.displaySmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppConstants.textColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Subtitle
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
                            'Sign in to access your student loans',
                            style: AppConstants.bodyMedium.copyWith(
                              color: AppConstants.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Login form
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
                              // Email field
                              TextFormField(
                                controller: _emailController,
                                focusNode: _emailFocusNode,
                                autofocus: false,
                                obscureText: false,
                                style: AppConstants.bodyLarge,
                                decoration: AppConstants.inputDecoration(
                                  labelText: 'University Email',
                                  prefixIcon: Icons.email_outlined,
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!RegExp(
                                          r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
                                      .hasMatch(value)) {
                                    return 'Please enter a valid email';
                                  }
                                  if (!_isUniversityEmail(value)) {
                                    return 'Please use a university email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              // Password field
                              TextFormField(
                                controller: _passwordController,
                                focusNode: _passwordFocusNode,
                                autofocus: false,
                                obscureText: !_passwordVisibility,
                                style: AppConstants.bodyLarge,
                                decoration: AppConstants.inputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: Icons.lock_outlined,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _passwordVisibility
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: AppConstants.textSecondaryColor,
                                      size: 22,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _passwordVisibility =
                                            !_passwordVisibility;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              // Forgot password
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () => Navigator.pushNamed(
                                      context, '/forgot-password'),
                                  child: Text(
                                    'Forgot Password?',
                                    style: AppConstants.bodyMedium.copyWith(
                                      color: AppConstants.primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Login button
                              AppConstants.gradientButton(
                                text: 'Log In',
                                onPressed: _handleLogin,
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
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
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
                              // Google sign in button
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
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Register option
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Don\'t have an account? ',
                              style: AppConstants.bodyMedium.copyWith(
                                color: AppConstants.textSecondaryColor,
                              ),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/register'),
                              child: Text(
                                'Register',
                                style: AppConstants.bodyMedium.copyWith(
                                  color: AppConstants.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
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
