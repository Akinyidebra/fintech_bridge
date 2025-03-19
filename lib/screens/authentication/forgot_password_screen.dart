import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fintech_bridge/services/auth_service.dart';
import 'package:fintech_bridge/utils/constants.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);
    final success = await authService.sendPasswordResetEmail(_emailController.text);

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset link sent to your email')),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              const Text('Forgot Password?', style: AppConstants.displaySmall),
              const SizedBox(height: 16),
              const Text('Enter your email to receive a reset link',
                  style: AppConstants.bodyLargeSecondary),
              const SizedBox(height: 32),
              TextFormField(
                controller: _emailController,
                decoration: AppConstants.inputDecoration(
                  labelText: 'University Email',
                  prefixIcon: Icons.email_outlined,
                ),
                style: AppConstants.bodyLarge,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Email is required';
                  if (!value!.contains('@')) return 'Enter valid email';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _sendResetLink,
                style: AppConstants.primaryButtonStyle,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Send Reset Link'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Back to Login',
                    style: AppConstants.bodyMedium.copyWith(
                      color: AppConstants.primaryColor,
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}