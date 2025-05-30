import 'package:fintech_bridge/models/loan_model.dart';
import 'package:fintech_bridge/models/student_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fintech_bridge/utils/constants.dart';

class ProviderLoanHeaderCardWidget extends StatelessWidget {
  final Loan loan;
  final Student? studentProfile;

  const ProviderLoanHeaderCardWidget({
    super.key,
    required this.loan,
    this.studentProfile, // Make it optional to maintain backwards compatibility
  });

  @override
  Widget build(BuildContext context) {
    // Use student profile data if available, fallback to loan data
    final studentName = studentProfile?.fullName ?? 'N/A';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppConstants.cardGradient,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryColor.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '\KES ${NumberFormat('#,##0.00').format(loan.amount)}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Requested Amount',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _getStatusColor(loan.status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatusLabel(loan.status),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(loan.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildInfoItem(
                'Borrower',
                studentName, // Use the fallback logic here
                Icons.person_rounded,
              ),
              const SizedBox(width: 24),
              _buildInfoItem(
                'Applied On',
                DateFormat('dd MMM yyyy').format(loan.createdAt),
                Icons.event_rounded,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoItem(
                'Purpose',
                loan.purpose,
                Icons.category_rounded,
              ),
              const SizedBox(width: 24),
              _buildInfoItem(
                'Due Date',
                DateFormat('dd MMM yyyy').format(loan.dueDate),
                Icons.schedule_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.amber;
      case 'APPROVED':
        return AppConstants.successColor;
      case 'REJECTED':
        return Colors.red;
      case 'PAID':
      case 'COMPLETED':
        return AppConstants.accentColor;
      default:
        return AppConstants.textSecondaryColor;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Pending Review';
      case 'APPROVED':
        return 'Approved';
      case 'REJECTED':
        return 'Rejected';
      case 'PAID':
        return 'Fully Paid';
      case 'COMPLETED':
        return 'Completed';
      default:
        return status;
    }
  }
}
