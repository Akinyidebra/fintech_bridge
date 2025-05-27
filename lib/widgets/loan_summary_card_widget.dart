import 'package:fintech_bridge/models/loan_model.dart';
import 'package:fintech_bridge/services/payment_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fintech_bridge/utils/constants.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class LoanSummaryCard extends StatelessWidget {
  final Loan loan;
  final int daysLeft;

  const LoanSummaryCard({
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
        // Default to 0% if we don't have data yet
        double progressPercent = 0.0;

        if (snapshot.hasData && snapshot.data!['success']) {
          final balanceData = snapshot.data!['data'];
          final totalRepaid = balanceData['totalRepaid'] as double;
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
          child: Row(
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
                      'Paid',
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
                      'Next Payment',
                      '\$${(loan.amount * 0.1).toStringAsFixed(2)}',
                      AppConstants.accentColor,
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryItem(
                      'Days Remaining',
                      '$daysLeft days',
                      AppConstants.primaryColor,
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
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: AppConstants.textSecondaryColor,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}