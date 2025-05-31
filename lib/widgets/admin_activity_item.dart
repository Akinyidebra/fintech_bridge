import 'package:fintech_bridge/utils/constants.dart';
import 'package:flutter/material.dart';

class AdminActivityItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String date;
  final String? amount;
  final bool showArrow;
  final Color? backgroundColor;
  final String? loanId;
  final String? studentName;
  final VoidCallback? onTap;
  final String? userType;
  final String? verificationStatus;

  const AdminActivityItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.date,
    this.amount,
    this.showArrow = false,
    this.backgroundColor,
    this.loanId,
    this.studentName,
    this.onTap,
    required String providerName,
    this.userType,
    this.verificationStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
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
      child: Row(
        children: [
          // Icon container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),

          const SizedBox(width: 16),

          // Main content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Verification status badge
                if (verificationStatus != null) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: verificationStatus == 'verified'
                          ? AppConstants.successColor.withOpacity(0.1)
                          : AppConstants.warningColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      verificationStatus == 'verified'
                          ? 'VERIFIED'
                          : 'UNVERIFIED',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: verificationStatus == 'verified'
                            ? AppConstants.successColor
                            : AppConstants.warningColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                ],

                // Title
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppConstants.textColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 6),

                // Date
                Text(
                  date,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: AppConstants.textSecondaryColor,
                  ),
                ),

                // Loan ID if present
                if (loanId != null && loanId!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Loan ID: $loanId',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                  ),
                ],

                // User type if available
                if (userType != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${userType == 'student' ? 'Student' : 'Provider'} Account',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: AppConstants.textSecondaryColor,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Amount on the right
          if (amount != null) ...[
            const SizedBox(width: 12),
            Text(
              amount!,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppConstants.textColor,
              ),
              textAlign: TextAlign.end,
            ),
          ],
        ],
      ),
    );
  }
}
