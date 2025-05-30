import 'package:fintech_bridge/models/loan_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fintech_bridge/utils/constants.dart';

class ProviderLoanDetailSection extends StatelessWidget {
  final Loan loan;

  const ProviderLoanDetailSection({super.key, required this.loan});

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
              // Basic Loan Information
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
                'Institution',
                loan.institutionName,
                Icons.school_rounded,
                AppConstants.secondaryColor,
              ),
              _divider(),
              _buildDetailItem(
                'Loan Type',
                loan.loanType,
                Icons.category_rounded,
                Colors.purple,
              ),
              _divider(),

              // Financial Information
              _buildDetailItem(
                'Amount',
                'KES ${NumberFormat('#,##0.00').format(loan.amount)}',
                Icons.monetization_on_rounded,
                AppConstants.successColor,
              ),
              _divider(),
              _buildDetailItem(
                'Interest Rate',
                '${loan.interestRate.toStringAsFixed(1)}%',
                Icons.percent_rounded,
                Colors.orange,
              ),
              _divider(),
              _buildDetailItem(
                'Monthly Payment',
                'KES ${NumberFormat('#,##0.00').format(loan.monthlyPayment)}',
                Icons.calendar_month_rounded,
                AppConstants.primaryColor,
              ),
              _divider(),
              _buildDetailItem(
                'Remaining Balance',
                'KES ${NumberFormat('#,##0.00').format(loan.remainingBalance)}',
                Icons.account_balance_wallet_rounded,
                AppConstants.errorColor,
              ),
              _divider(),

              // Term and Dates
              _buildDetailItem(
                'Term',
                '${loan.termMonths} months',
                Icons.schedule_rounded,
                Colors.indigo,
              ),
              _divider(),
              _buildDetailItem(
                'Due Date',
                DateFormat('dd MMM yyyy').format(loan.dueDate),
                Icons.event_rounded,
                AppConstants.errorColor,
              ),
              _divider(),
              _buildDetailItem(
                'Next Due Date',
                DateFormat('dd MMM yyyy').format(loan.nextDueDate),
                Icons.event_available_rounded,
                Colors.amber.shade700,
              ),
              _divider(),
              _buildDetailItem(
                'Repayment Start',
                DateFormat('dd MMM yyyy').format(loan.repaymentStartDate),
                Icons.play_circle_rounded,
                AppConstants.accentColor,
              ),
              _divider(),

              // Contact and Payment Information
              _buildDetailItem(
                'M-Pesa Phone',
                loan.mpesaPhone,
                Icons.phone_android_rounded,
                Colors.green,
              ),
              _divider(),
              _buildDetailItem(
                'Repayment Method',
                loan.repaymentMethod,
                Icons.payment_rounded,
                AppConstants.secondaryColor,
              ),
              _divider(),
              _buildDetailItem(
                'M-Pesa Transaction Code',
                loan.mpesaTransactionCode.isNotEmpty
                    ? loan.mpesaTransactionCode
                    : 'Not Available',
                Icons.receipt_rounded,
                Colors.teal,
              ),
              _divider(),
              _buildDetailItem(
                'Late Payment Penalty',
                '${loan.latePaymentPenaltyRate.toStringAsFixed(1)}%',
                Icons.warning_rounded,
                AppConstants.errorColor,
              ),
              _divider(),

              // Timestamps
              _buildDetailItem(
                'Created At',
                DateFormat('dd MMM yyyy, hh:mm a').format(loan.createdAt),
                Icons.access_time_rounded,
                AppConstants.textSecondaryColor,
              ),
              _divider(),
              _buildDetailItem(
                'Last Updated',
                DateFormat('dd MMM yyyy, hh:mm a').format(loan.updatedAt),
                Icons.update_rounded,
                AppConstants.textSecondaryColor,
              ),
            ],
          ),
        ),

        // Purpose Section (separate card for better visibility)
        const SizedBox(height: 16),
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.description_rounded,
                        color: AppConstants.primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Loan Purpose',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  loan.purpose.isNotEmpty
                      ? loan.purpose
                      : 'No purpose specified',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: AppConstants.primaryColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
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
