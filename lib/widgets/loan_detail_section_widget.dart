import 'package:fintech_bridge/models/loan_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fintech_bridge/utils/constants.dart';

class LoanDetailSection extends StatelessWidget {
  final Loan loan;

  const LoanDetailSection({super.key, required this.loan});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'Loan Details',
            style: AppConstants.headlineSmall,
          ),
        ),
        Container(
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
              _buildDetailItem(
                'Loan ID',
                loan.id,
                Icons.tag_rounded,
                AppConstants.primaryColor,
              ),
              _divider(),
              _buildDetailItem(
                'Student ID',
                loan.studentId,
                Icons.person_rounded,
                AppConstants.accentColor,
              ),
              _divider(),
              _buildDetailItem(
                'Provider ID',
                loan.providerId,
                Icons.account_balance_rounded,
                AppConstants.secondaryColor,
              ),
              _divider(),
              _buildDetailItem(
                'Created At',
                DateFormat('dd MMM yyyy, hh:mm a').format(loan.createdAt),
                Icons.access_time_rounded,
                AppConstants.textSecondaryColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(
      String label, String value, IconData icon, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
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
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 16,
      color: Colors.grey.withOpacity(0.1),
    );
  }
}