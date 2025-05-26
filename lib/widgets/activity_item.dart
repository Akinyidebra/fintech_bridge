import 'package:fintech_bridge/utils/constants.dart';
import 'package:flutter/material.dart';

class ActivityItemWidget extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String date;
  final String? amount;
  final bool showArrow;
  final Color? backgroundColor;
  final String? loanId;
  final VoidCallback? onTap;

  const ActivityItemWidget({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.date,
    this.amount,
    this.showArrow = false,
    this.backgroundColor,
    this.loanId,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.black.withOpacity(0.03),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: AppConstants.textSecondaryColor,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (amount != null)
              Text(
                amount!,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            if (showArrow)
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppConstants.textSecondaryColor,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}