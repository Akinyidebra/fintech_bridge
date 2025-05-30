import 'package:fintech_bridge/models/loan_model.dart';
import 'package:flutter/material.dart';
import 'package:fintech_bridge/utils/constants.dart';

class ProviderLoanActionButtons extends StatelessWidget {
  final Loan loan;
  final VoidCallback onApproveLoan;
  final VoidCallback onRejectLoan;
  final VoidCallback onSetPending;
  final VoidCallback onViewPayments;
  final VoidCallback onDownloadStatement;
  final VoidCallback onRefresh;

  const ProviderLoanActionButtons({
    super.key,
    required this.loan,
    required this.onApproveLoan,
    required this.onRejectLoan,
    required this.onSetPending,
    required this.onViewPayments,
    required this.onDownloadStatement,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Loan Status Management Buttons (only show if loan is not PAID)
        if (loan.status != 'PAID') ...[
          Row(
            children: [
              // Approve Button
              Expanded(
                child: Container(
                  height: 50,
                  decoration: loan.status == 'PENDING'
                      ? BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppConstants.successColor, Color(0xFF4CAF50)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        )
                      : BoxDecoration(
                          color: AppConstants.backgroundSecondaryColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppConstants.borderColor,
                            width: 1,
                          ),
                        ),
                  child: ElevatedButton(
                    onPressed: loan.status == 'PENDING' ? onApproveLoan : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: loan.status == 'PENDING'
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
                          Icons.check_circle_rounded,
                          size: 18,
                          color: loan.status == 'PENDING'
                              ? Colors.white
                              : AppConstants.textSecondaryColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Approve',
                          style: AppConstants.titleMedium.copyWith(
                            color: loan.status == 'PENDING'
                                ? Colors.white
                                : AppConstants.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Reject Button
              Expanded(
                child: Container(
                  height: 50,
                  decoration: loan.status == 'PENDING'
                      ? BoxDecoration(
                          color: AppConstants.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppConstants.errorColor,
                            width: 1.5,
                          ),
                        )
                      : BoxDecoration(
                          color: AppConstants.backgroundSecondaryColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppConstants.borderColor,
                            width: 1,
                          ),
                        ),
                  child: ElevatedButton(
                    onPressed: loan.status == 'PENDING' ? onRejectLoan : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: loan.status == 'PENDING'
                          ? AppConstants.errorColor
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
                          Icons.cancel_rounded,
                          size: 18,
                          color: loan.status == 'PENDING'
                              ? AppConstants.errorColor
                              : AppConstants.textSecondaryColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Reject',
                          style: AppConstants.titleMedium.copyWith(
                            color: loan.status == 'PENDING'
                                ? AppConstants.errorColor
                                : AppConstants.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Set Pending Button (only show if loan is APPROVED or REJECTED)
          if (loan.status == 'APPROVED' || loan.status == 'REJECTED') ...[
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.amber,
                  width: 1.5,
                ),
              ),
              child: ElevatedButton(
                onPressed: onSetPending,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.amber.shade700,
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
                      Icons.schedule_rounded,
                      size: 18,
                      color: Colors.amber.shade700,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Set as Pending',
                      style: AppConstants.titleMedium.copyWith(
                        color: Colors.amber.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ] else ...[
            const SizedBox(height: 16),
          ],
        ],
        
        // Secondary Action Buttons Row
        Row(
          children: [
            // View Payments Button
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppConstants.primaryColor,
                    width: 1.5,
                  ),
                ),
                child: ElevatedButton(
                  onPressed: onViewPayments,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: AppConstants.primaryColor,
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
                        Icons.payment_rounded,
                        size: 18,
                        color: AppConstants.primaryColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Payments',
                        style: AppConstants.titleMedium.copyWith(
                          color: AppConstants.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Download Statement Button
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
            
            // Refresh Button
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