import 'package:fintech_bridge/models/transaction_model.dart' as tm;
import 'package:fintech_bridge/services/payment_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fintech_bridge/utils/constants.dart';

class PaymentScheduleSection extends StatelessWidget {
  final String loanId;

  const PaymentScheduleSection({super.key, required this.loanId});

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
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: payments.length,
            separatorBuilder: (context, index) => _divider(),
            itemBuilder: (context, index) {
              final payment = payments[index];
              return _buildPaymentItem(payment);
            },
          ),
        );
      },
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
              valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
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
            'Your payment transactions will appear here once you make payments.',
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
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Payment Status Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getStatusColor(payment.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getStatusIcon(payment.status),
              color: _getStatusColor(payment.status),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          
          // Payment Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Payment',
                      style: TextStyle(
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
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: payment.type == 'CREDIT' 
                            ? AppConstants.successColor 
                            : AppConstants.errorColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('dd MMM yyyy, HH:mm').format(payment.createdAt),
                      style: AppConstants.bodySmall.copyWith(
                        color: AppConstants.textSecondaryColor,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getStatusColor(payment.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _getStatusLabel(payment.status),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(payment.status),
                        ),
                      ),
                    ),
                  ],
                ),
                if (payment.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    payment.description,
                    style: AppConstants.bodySmall.copyWith(
                      color: AppConstants.textSecondaryColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
      default:
        return status;
    }
  }
}