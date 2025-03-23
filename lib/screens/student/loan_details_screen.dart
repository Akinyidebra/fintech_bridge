import 'package:fintech_bridge/services/payment_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fintech_bridge/services/loan_service.dart';
import 'package:fintech_bridge/utils/constants.dart';

class LoanDetailsScreen extends StatelessWidget {
  final String loanId;

  const LoanDetailsScreen({super.key, required this.loanId});

  @override
  Widget build(BuildContext context) {
    final loanService = Provider.of<LoanService>(context);

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Loan Details'),
      ),
      body: FutureBuilder(
        future: loanService.getLoanById(loanId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!['success']) {
            return const Center(child: Text('Loan not found'));
          }

          final loan = snapshot.data!['data'];

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildDetailItem('Loan Amount', '\$${loan.amount}'),
                _buildDetailItem('Status', loan.status),
                _buildDetailItem(
                    'Due Date', DateFormat('dd MMM yyyy').format(loan.dueDate)),
                _buildDetailItem('Purpose', loan.purpose),
                const SizedBox(height: 30),
                if (loan.status == 'APPROVED')
                  AppConstants.gradientButton(
                    text: 'Make Payment',
                    onPressed: () => _makePayment(context),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: AppConstants.cardDecoration,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppConstants.bodyMediumSecondary),
          Text(value, style: AppConstants.bodyMedium),
        ],
      ),
    );
  }

  void _makePayment(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('Enter Payment Amount'),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: AppConstants.inputDecoration(
                labelText: 'Amount',
                prefixIcon: Icons.payment_rounded,
              ),
            ),
            const SizedBox(height: 20),
            AppConstants.gradientButton(
              text: 'Confirm Payment',
              onPressed: () => _processPayment(context),
            ),
          ],
        ),
      ),
    );
  }

  void _processPayment(BuildContext context) async {
    final paymentService = Provider.of<PaymentService>(context, listen: false);
    // Implement payment processing
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment processed successfully')),
    );
  }
}
