import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fintech_bridge/models/loan_model.dart';
import 'package:fintech_bridge/utils/constants.dart';

class LoanItemCard extends StatelessWidget {
  final Loan loan;
  final VoidCallback onTap;

  const LoanItemCard({
    super.key,
    required this.loan,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(symbol: 'KES. ', decimalDigits: 0);
    final formattedAmount = currencyFormatter.format(loan.amount);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              spreadRadius: 0,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Main content section with fixed overflow
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Top row - Icon, Title, Amount, Status
                  Row(
                    children: [
                      // Loan Icon
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              _getLoanIconColor(loan.purpose),
                              _getLoanIconColor(loan.purpose).withOpacity(0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: _getLoanIconColor(loan.purpose)
                                  .withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          _getLoanIcon(loan.purpose),
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Title and ID - Flexible to prevent overflow
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getLoanPurposeTitle(loan.purpose),
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppConstants.textColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppConstants.backgroundSecondaryColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'ID: ${loan.id.length > 8 ? loan.id.substring(0, 8) : loan.id}...',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  color: AppConstants.textSecondaryColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Amount and Status - Fixed width to prevent overflow
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                formattedAmount,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: AppConstants.textColor,
                                ),
                                maxLines: 1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: _getStatusColor(loan.status)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _getStatusColor(loan.status)
                                      .withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 5,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(loan.status),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Flexible(
                                    child: Text(
                                      _getStatusText(loan.status),
                                      style: TextStyle(
                                        color: _getStatusColor(loan.status),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Poppins',
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Bottom row - Date and Interest Rate
                  Row(
                    children: [
                      // Creation Date
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 14,
                              color: AppConstants.textSecondaryColor
                                  .withOpacity(0.7),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Applied: ${DateFormat('MMM dd, yyyy').format(loan.createdAt)}',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: AppConstants.textSecondaryColor
                                      .withOpacity(0.8),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Interest Rate
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppConstants.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.percent_rounded,
                              size: 11,
                              color: AppConstants.primaryColor,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${loan.interestRate.toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 10,
                                color: AppConstants.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods for loan styling
  Color _getLoanIconColor(String purpose) {
    switch (purpose.toLowerCase()) {
      case 'tuition':
      case 'education':
        return AppConstants.primaryColor;
      case 'emergency':
        return AppConstants.errorColor;
      case 'book allowance':
      case 'books':
        return AppConstants.accentColor;
      case 'project funding':
        return AppConstants.secondaryColor;
      case 'medical expenses':
        return const Color(0xFF10B981);
      default:
        return AppConstants.primaryColor;
    }
  }

  IconData _getLoanIcon(String purpose) {
    switch (purpose.toLowerCase()) {
      case 'tuition':
      case 'education':
        return Icons.school_rounded;
      case 'emergency':
        return Icons.emergency_rounded;
      case 'book allowance':
      case 'books':
        return Icons.menu_book_rounded;
      case 'project funding':
        return Icons.work_rounded;
      case 'medical expenses':
        return Icons.local_hospital_rounded;
      default:
        return Icons.account_balance_wallet_rounded;
    }
  }

  String _getLoanPurposeTitle(String purpose) {
    switch (purpose.toLowerCase()) {
      case 'tuition':
        return 'Tuition Fee Loan';
      case 'emergency':
        return 'Emergency Loan';
      case 'book allowance':
      case 'books':
        return 'Book Allowance';
      case 'project funding':
        return 'Project Funding';
      case 'education':
        return 'Education Loan';
      case 'medical expenses':
        return 'Medical Expenses';
      default:
        return purpose
            .split(' ')
            .map((word) => word.isEmpty
                ? word
                : word[0].toUpperCase() + word.substring(1).toLowerCase())
            .join(' ');
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
      case 'ACTIVE':
        return AppConstants.successColor;
      case 'PENDING':
        return AppConstants.warningColor;
      case 'REJECTED':
      case 'DECLINED':
        return AppConstants.errorColor;
      case 'COMPLETED':
      case 'PAID':
        return AppConstants.primaryColor;
      default:
        return AppConstants.textSecondaryColor;
    }
  }

  String _getStatusText(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return 'Active';
      case 'PENDING':
        return 'Pending';
      case 'REJECTED':
      case 'DECLINED':
        return 'Rejected';
      case 'COMPLETED':
      case 'PAID':
        return 'Completed';
      default:
        return status;
    }
  }
}
