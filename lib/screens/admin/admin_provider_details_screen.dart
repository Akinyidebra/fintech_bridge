import 'package:fintech_bridge/widgets/admin_provider_details_content.dart';
import 'package:fintech_bridge/widgets/custom_app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:fintech_bridge/utils/constants.dart';

class AdminProviderDetailsScreen extends StatelessWidget {
  final String providerId;

  const AdminProviderDetailsScreen({super.key, required this.providerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: CustomAppBar(
        title: 'Provider Details',
        showHelp: true,
        onHelpPressed: () {
          // Show help information
          _showHelpDialog(context);
        },
      ),
      body: AdminProviderDetailsContent(providerId: providerId),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Provider Details Help',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            'Here you can view loan provider information, manage verification status, and review their business details. Use the action buttons to verify providers, check their documentation, or update their status.',
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Got it',
                style: TextStyle(
                  color: AppConstants.primaryColor,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
