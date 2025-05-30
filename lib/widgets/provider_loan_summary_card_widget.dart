import 'package:fintech_bridge/models/loan_model.dart';
import 'package:fintech_bridge/services/payment_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fintech_bridge/utils/constants.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:intl/intl.dart';

class ProviderLoanSummaryCard extends StatelessWidget {
  final Loan loan;
  final int daysLeft;

  const ProviderLoanSummaryCard({
    super.key,
    required this.loan,
    required this.daysLeft,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: Provider.of<PaymentService>(context, listen: false)
          .getRemainingBalance(loan.id),
      builder: (context, snapshot) {
        // Default values
        double progressPercent = 0.0;
        double totalRepaid = 0.0;
        double remainingBalance = loan.amount;

        if (snapshot.hasData && snapshot.data!['success']) {
          final balanceData = snapshot.data!['data'];
          totalRepaid = balanceData['totalRepaid'] as double;
          remainingBalance = balanceData['remainingBalance'] as double;
          progressPercent = (totalRepaid / loan.amount).clamp(0.0, 1.0);
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Progress Circle and Main Info
              Row(
                children: [
                  CircularPercentIndicator(
                    radius: 50,
                    lineWidth: 10.0,
                    percent: progressPercent,
                    center: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${(progressPercent * 100).toInt()}%',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const Text(
                          'Repaid',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: AppConstants.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                    progressColor: AppConstants.successColor,
                    backgroundColor: AppConstants.backgroundSecondaryColor,
                    circularStrokeCap: CircularStrokeCap.round,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummaryItem(
                          'Total Repaid',
                          'KES ${NumberFormat('#,##0.00').format(totalRepaid)}',
                          AppConstants.successColor,
                        ),
                        const SizedBox(height: 12),
                        _buildSummaryItem(
                          'Remaining Balance',
                          'KES ${NumberFormat('#,##0.00').format(remainingBalance)}',
                          AppConstants.errorColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Additional Summary Information
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppConstants.backgroundSecondaryColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryItem(
                            'Monthly Payment',
                            'KES ${NumberFormat('#,##0.00').format(loan.monthlyPayment)}',
                            AppConstants.primaryColor,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: AppConstants.borderColor,
                        ),
                        Expanded(
                          child: _buildSummaryItem(
                            'Interest Rate',
                            '${loan.interestRate.toStringAsFixed(1)}%',
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryItem(
                            'Term Duration',
                            '${loan.termMonths} months',
                            AppConstants.accentColor,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: AppConstants.borderColor,
                        ),
                        Expanded(
                          child: _buildSummaryItem(
                            daysLeft >= 0 ? 'Days Remaining' : 'Days Overdue',
                            '${daysLeft.abs()} days',
                            daysLeft >= 0
                                ? AppConstants.primaryColor
                                : AppConstants.errorColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Loan Status Summary
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getStatusColor(loan.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getStatusColor(loan.status).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getStatusIcon(loan.status),
                      color: _getStatusColor(loan.status),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Status: ${_getStatusLabel(loan.status)}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(loan.status),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
            color: AppConstants.textSecondaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.amber;
      case 'APPROVED':
        return AppConstants.successColor;
      case 'REJECTED':
        return AppConstants.errorColor;
      case 'PAID':
        return AppConstants.accentColor;
      default:
        return AppConstants.textSecondaryColor;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Icons.schedule_rounded;
      case 'APPROVED':
        return Icons.check_circle_rounded;
      case 'REJECTED':
        return Icons.cancel_rounded;
      case 'PAID':
        return Icons.verified_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Awaiting Review';
      case 'APPROVED':
        return 'Approved & Active';
      case 'REJECTED':
        return 'Rejected';
      case 'PAID':
        return 'Fully Paid';
      default:
        return status;
    }
  }
}
