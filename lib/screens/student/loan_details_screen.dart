import 'package:fintech_bridge/widgets/custom_app_bar_widget.dart';
import 'package:fintech_bridge/widgets/loan_details_content_widget.dart';
import 'package:flutter/material.dart';
import 'package:fintech_bridge/utils/constants.dart';

class LoanDetailsScreen extends StatelessWidget {
  final String loanId;

  const LoanDetailsScreen({super.key, required this.loanId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: CustomAppBar(
        title: 'Loan Details',
        showHelp: true,
        onHelpPressed: () {
          // Show help information
          _showHelpDialog(context);
        },
      ),
      body: LoanDetailsContent(loanId: loanId),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Loan Details Help',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            'Here you can view your loan information, payment history, and make payments. Use the "Make Payment" button to pay towards your loan balance.',
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