import 'package:fintech_bridge/utils/constants.dart';
import 'package:flutter/material.dart';

class ProviderActivityItem extends StatelessWidget {
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

  const ProviderActivityItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.date,
    this.amount,
    this.showArrow = true,
    this.backgroundColor,
    this.loanId,
    this.studentName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Icon container - Fixed size
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              
              // Main content - Flexible and constrained
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title with proper overflow handling
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppConstants.textColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // Date and loan ID in a flexible row
                    Row(
                      children: [
                        // Date - takes available space
                        Flexible(
                          child: Text(
                            date,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: AppConstants.textSecondaryColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        
                        // Loan ID - only if present and space allows
                        if (loanId != null) ...[
                          const SizedBox(width: 8),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppConstants.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'ID: $loanId',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: AppConstants.primaryColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    
                    // Student name on separate line if present
                    if (studentName != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Student: $studentName',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: AppConstants.textSecondaryColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              
              // Right side content - Fixed width and constrained
              if (amount != null || showArrow)
                Container(
                  width: 80,
                  padding: const EdgeInsets.only(left: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (amount != null)
                        Text(
                          amount!,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppConstants.textColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                        ),
                      if (showArrow) ...[
                        if (amount != null) const SizedBox(height: 4),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: AppConstants.textSecondaryColor,
                          size: 16,
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}