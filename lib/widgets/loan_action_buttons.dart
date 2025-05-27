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
        // Make Payment Button - Using gradient for primary action
        Container(
          height: 56,
          decoration: loan.status == 'APPROVED' 
              ? AppConstants.gradientContainerDecoration
              : BoxDecoration(
                  color: AppConstants.backgroundSecondaryColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppConstants.borderColor,
                    width: 1,
                  ),
                ),
          child: ElevatedButton(
            onPressed: loan.status == 'APPROVED' ? onMakePayment : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: loan.status == 'APPROVED' 
                  ? Colors.white 
                  : AppConstants.textSecondaryColor,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.payment_rounded, 
                  size: 20,
                  color: loan.status == 'APPROVED' 
                      ? Colors.white 
                      : AppConstants.textSecondaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Make Payment',
                  style: AppConstants.titleLarge.copyWith(
                    color: loan.status == 'APPROVED' 
                        ? Colors.white 
                        : AppConstants.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Action Buttons Row
        Row(
          children: [
            // Download Statement Button - Using secondary color theme
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppConstants.secondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppConstants.secondaryColor,
                    width: 1.5,
                  ),
                ),
                child: ElevatedButton(
                  onPressed: onDownloadStatement,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: AppConstants.secondaryColor,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.download_rounded, 
                        size: 18,
                        color: AppConstants.secondaryColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Statement',
                        style: AppConstants.titleMedium.copyWith(
                          color: AppConstants.secondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Refresh Button - Using accent color theme
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppConstants.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppConstants.accentColor,
                    width: 1.5,
                  ),
                ),
                child: ElevatedButton(
                  onPressed: onRefresh,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: AppConstants.accentColor,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.refresh_rounded, 
                        size: 18,
                        color: AppConstants.accentColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Refresh',
                        style: AppConstants.titleMedium.copyWith(
                          color: AppConstants.accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}