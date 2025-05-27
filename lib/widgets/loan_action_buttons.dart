import 'package:fintech_bridge/models/loan_model.dart';
import 'package:flutter/material.dart';
import 'package:fintech_bridge/utils/constants.dart';

class LoanActionButtons extends StatelessWidget {
  final Loan loan;
  final VoidCallback onMakePayment;
  final VoidCallback onDownloadStatement;
  final VoidCallback onRefresh;

  const LoanActionButtons({
    super.key,
    required this.loan,
    required this.onMakePayment,
    required this.onDownloadStatement,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Make Payment Button
        ElevatedButton(
          onPressed: loan.status == 'APPROVED' ? onMakePayment : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.payment_rounded, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Make Payment',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        
        // Action Buttons Row
        Row(
          children: [
            // Download Statement Button
            Expanded(
              child: OutlinedButton(
                onPressed: onDownloadStatement,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppConstants.primaryColor,
                  side: const BorderSide(color: AppConstants.primaryColor),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.download_rounded, size: 18),
                    const SizedBox(width: 6),
                    const Text(
                      'Statement',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Refresh Button
            Expanded(
              child: OutlinedButton(
                onPressed: onRefresh,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppConstants.textSecondaryColor,
                  side: const BorderSide(color: AppConstants.textSecondaryColor),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.refresh_rounded, size: 18),
                    const SizedBox(width: 6),
                    const Text(
                      'Refresh',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}