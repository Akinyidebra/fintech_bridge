import 'package:fintech_bridge/models/loan_model.dart';
import 'package:fintech_bridge/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PendingApplicationCard extends StatelessWidget {
  final Loan loan;
  final VoidCallback? onViewPressed;
  final VoidCallback? onApprovePressed;
  final VoidCallback? onRejectPressed;

  const PendingApplicationCard({
    super.key,
    required this.loan,
    this.onViewPressed,
    this.onApprovePressed,
    this.onRejectPressed,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat =
        NumberFormat.currency(symbol: 'KES. ', decimalDigits: 2);
    final dateFormat = DateFormat('MMM dd, yyyy');
    final screenWidth = MediaQuery.of(context).size.width;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: screenWidth - 32, // Account for padding
        maxHeight: 280, // Prevent vertical overflow
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16), // Reduced padding
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.black.withOpacity(0.05),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Prevent vertical expansion
          children: [
            // Header with student info and amount - Fixed overflow
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side - Student info
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 120),
                        child: Text(
                          loan.studentId,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14, // Reduced font size
                            fontWeight: FontWeight.w600,
                            color: AppConstants.textColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Applied ${dateFormat.format(loan.createdAt)}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10, // Reduced font size
                          color: AppConstants.textSecondaryColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Right side - Amount and status
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 100),
                        child: Text(
                          currencyFormat.format(loan.amount),
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14, // Reduced font size
                            fontWeight: FontWeight.bold,
                            color: AppConstants.primaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2), // Reduced padding
                        decoration: BoxDecoration(
                          color: AppConstants.warningColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'PENDING',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 9, // Reduced font size
                            fontWeight: FontWeight.w600,
                            color: AppConstants.warningColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Loan details in flexible layout
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    'Duration',
                    '${loan.termMonths} months',
                    Icons.schedule_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDetailItem(
                    'Interest Rate',
                    '${loan.interestRate}%',
                    Icons.percent_rounded,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Institution - Single line with proper overflow
            _buildDetailItem(
              'Institution',
              loan.institutionName,
              Icons.school_rounded,
            ),

            // Purpose section with proper constraints
            if (loan.purpose.isNotEmpty) ...[
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 32, // Limit height to 2 lines
                  maxWidth: screenWidth - 64,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Purpose: ',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11, // Reduced font size
                        color: AppConstants.textSecondaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        loan.purpose,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11, // Reduced font size
                          color: AppConstants.textSecondaryColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Action buttons with responsive layout
            _buildActionButtons(screenWidth),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(double screenWidth) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: screenWidth - 64,
        maxHeight: 120, // Limit button section height
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // View Details button - full width
          SizedBox(
            width: double.infinity,
            height: 36, // Reduced height
            child: OutlinedButton.icon(
              onPressed: onViewPressed,
              icon: const Icon(
                Icons.visibility_rounded,
                size: 16, // Reduced icon size
              ),
              label: const Text(
                'View Details',
                style: TextStyle(fontSize: 12), // Reduced font size
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppConstants.primaryColor,
                side: const BorderSide(color: AppConstants.primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Approve and Reject buttons row
          Row(
            children: [
              // Approve button - takes most space
              Expanded(
                flex: 4,
                child: SizedBox(
                  height: 36, // Reduced height
                  child: ElevatedButton.icon(
                    onPressed: onApprovePressed,
                    icon: const Icon(
                      Icons.check_rounded,
                      size: 16, // Reduced icon size
                    ),
                    label: const Text(
                      'Approve',
                      style: TextStyle(fontSize: 12), // Reduced font size
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.successColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Reject button - compact
              Container(
                height: 36, // Reduced height
                width: 36, // Reduced width
                decoration: BoxDecoration(
                  color: AppConstants.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  onPressed: onRejectPressed,
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppConstants.errorColor,
                    size: 18, // Reduced icon size
                  ),
                  tooltip: 'Reject',
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 40, // Limit detail item height
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 14, // Reduced icon size
            color: AppConstants.textSecondaryColor,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 9, // Reduced font size
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11, // Reduced font size
                    fontWeight: FontWeight.w600,
                    color: AppConstants.textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}