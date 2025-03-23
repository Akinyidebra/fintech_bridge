import 'package:fintech_bridge/models/loan_model.dart';
import 'package:fintech_bridge/screens/student/loan_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fintech_bridge/services/loan_service.dart';
import 'package:fintech_bridge/utils/constants.dart';

class MyLoansScreen extends StatefulWidget {
  const MyLoansScreen({super.key});

  @override
  State<MyLoansScreen> createState() => _MyLoansScreenState();
}

class _MyLoansScreenState extends State<MyLoansScreen> {
  @override
  Widget build(BuildContext context) {
    final loanService = Provider.of<LoanService>(context);

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('My Loans'),
      ),
      body: FutureBuilder(
        future: loanService.getStudentLoans(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!['data'].isEmpty) {
            return const Center(child: Text('No active loans'));
          }

          final loans = snapshot.data!['data'];

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: loans.length,
            itemBuilder: (context, index) => _buildLoanItem(loans[index]),
          );
        },
      ),
    );
  }

  Widget _buildLoanItem(Loan loan) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoanDetailsScreen(loanId: loan.id),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: AppConstants.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('\$${loan.amount}', style: AppConstants.titleLarge),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  loan.status,
                  style: TextStyle(
                    color: _getStatusColor(loan.status),
                  ),
                ),
                Text(DateFormat('dd MMM yyyy').format(loan.dueDate)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'APPROVED':
        return AppConstants.successColor;
      case 'PENDING':
        return AppConstants.warningColor;
      case 'REJECTED':
        return AppConstants.errorColor;
      default:
        return AppConstants.textColor;
    }
  }
}
