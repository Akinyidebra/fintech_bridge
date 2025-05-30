import 'package:fintech_bridge/models/transaction_model.dart' as tm;
import 'package:fintech_bridge/services/payment_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fintech_bridge/utils/constants.dart';

class ProviderPaymentScheduleSection extends StatelessWidget {
  final String loanId;

  const ProviderPaymentScheduleSection({super.key, required this.loanId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: Provider.of<PaymentService>(context, listen: false)
          .getLoanTransactions(loanId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (!snapshot.hasData || !snapshot.data!['success']) {
          return _buildEmptyPaymentSchedule();
        }

        final payments = snapshot.data!['data'] as List<tm.Transaction>;
        if (payments.isEmpty) {
          return _buildEmptyPaymentSchedule();
        }

        // Calculate payment statistics
        final completedPayments = payments
            .where((p) =>
                p.status.toUpperCase() == 'COMPLETED' ||
                p.status.toUpperCase() == 'SUCCESS')
            .toList();

        final totalPaid = completedPayments.fold<double>(
            0.0, (sum, payment) => sum + payment.amount);

        return Column(
          children: [
            _buildPaymentSummary(
                payments.length, completedPayments.length, totalPaid),
            const SizedBox(height: 16),
            _buildPaymentsList(payments),
          ],
        );
      },
    );
  }

  Widget _buildPaymentSummary(
      int totalTransactions, int completedPayments, double totalPaid) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Summary',
            style: AppConstants.titleMedium,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Total Payments',
                  totalTransactions.toString(),
                  Icons.receipt_long,
                  AppConstants.primaryColor,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Completed',
                  completedPayments.toString(),
                  Icons.check_circle,
                  AppConstants.successColor,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Amount Paid',
                  '\KES ${NumberFormat('#,##0').format(totalPaid)}',
                  Icons.account_balance_wallet,
                  AppConstants.accentColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: AppConstants.bodySmall.copyWith(
            color: AppConstants.textSecondaryColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPaymentsList(List<tm.Transaction> payments) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Transaction History',
              style: AppConstants.titleMedium,
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: payments.length,
            separatorBuilder: (context, index) => _divider(),
            itemBuilder: (context, index) {
              final payment = payments[index];
              return _buildPaymentItem(payment);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(32),
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
      child: const Center(
        child: Column(
          children: [
            CircularProgressIndicator(
              strokeWidth: 2,
              valueColor:
                  AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
            ),
            SizedBox(height: 16),
            Text(
              'Loading payment history...',
              style: AppConstants.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyPaymentSchedule() {
    return Container(
      padding: const EdgeInsets.all(32),
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
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppConstants.backgroundSecondaryColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              size: 32,
              color: AppConstants.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Payment History',
            style: AppConstants.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'No payment transactions have been made for this loan yet.',
            textAlign: TextAlign.center,
            style: AppConstants.bodyMedium.copyWith(
              color: AppConstants.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentItem(tm.Transaction payment) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        children: [
          // Payment Status Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _getStatusColor(payment.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getStatusIcon(payment.status),
              color: _getStatusColor(payment.status),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Payment Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Payment Transaction',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                    Text(
                      '\KES ${NumberFormat('#,##0.00').format(payment.amount)}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: payment.type == 'CREDIT'
                            ? AppConstants.successColor
                            : AppConstants.errorColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('dd MMM yyyy, HH:mm')
                          .format(payment.createdAt),
                      style: AppConstants.bodyMedium.copyWith(
                        color: AppConstants.textSecondaryColor,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(payment.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getStatusLabel(payment.status),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(payment.status),
                        ),
                      ),
                    ),
                  ],
                ),
                if (payment.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    payment.description,
                    style: AppConstants.bodySmall.copyWith(
                      color: AppConstants.textSecondaryColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (payment.id.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Ref: ${payment.id}',
                    style: AppConstants.bodySmall.copyWith(
                      color: AppConstants.textSecondaryColor,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 1,
      color: AppConstants.backgroundSecondaryColor,
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
      case 'SUCCESS':
        return AppConstants.successColor;
      case 'PENDING':
        return Colors.amber;
      case 'FAILED':
      case 'REJECTED':
        return AppConstants.errorColor;
      case 'PROCESSING':
        return AppConstants.primaryColor;
      default:
        return AppConstants.textSecondaryColor;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
      case 'SUCCESS':
        return Icons.check_circle_rounded;
      case 'PENDING':
        return Icons.schedule_rounded;
      case 'FAILED':
      case 'REJECTED':
        return Icons.cancel_rounded;
      case 'PROCESSING':
        return Icons.sync_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return 'Completed';
      case 'SUCCESS':
        return 'Success';
      case 'PENDING':
        return 'Pending';
      case 'FAILED':
        return 'Failed';
      case 'REJECTED':
        return 'Rejected';
      case 'PROCESSING':
        return 'Processing';
      default:
        return status;
    }
  }
}
