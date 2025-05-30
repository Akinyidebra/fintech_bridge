import 'package:fintech_bridge/widgets/custom_app_bar_widget.dart';
import 'package:fintech_bridge/widgets/provider_loan_details_content_widget.dart';
import 'package:flutter/material.dart';
import 'package:fintech_bridge/utils/constants.dart';

class ProviderLoanDetailsScreen extends StatelessWidget {
  final String loanId;

  const ProviderLoanDetailsScreen({super.key, required this.loanId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: CustomAppBar(
        title: 'Loan Management',
        showHelp: true,
        onHelpPressed: () {
          // Show help information
          _showHelpDialog(context);
        },
      ),
      body: ProviderLoanDetailsContent(loanId: loanId),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Loan Management Help',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            'Here you can view complete loan information including borrower details, loan amount, purpose, and payment history. You can approve, reject, or set loans to pending status. Use the action buttons to manage the loan status.',
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
