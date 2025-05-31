import 'package:fintech_bridge/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminVerificationCard extends StatelessWidget {
  final String userType; // "student" or "provider"
  final String userName;
  final String userEmail;
  final String phone;
  final DateTime createdAt;
  final VoidCallback? onViewPressed;

  // Student-specific fields
  final String? institution;
  final String? course;
  final int? yearOfStudy;

  // Provider-specific fields
  final String? businessType;
  final List<String>? loanTypes;
  final double? interestRate;
  final String? website;

  const AdminVerificationCard({
    super.key,
    required this.userType,
    required this.userName,
    required this.userEmail,
    required this.phone,
    required this.createdAt,
    this.onViewPressed,
    // Student fields
    this.institution,
    this.course,
    this.yearOfStudy,
    // Provider fields
    this.businessType,
    this.loanTypes,
    this.interestRate,
    this.website,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final isStudent = userType.toLowerCase() == 'student';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with applicant info and status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isStudent
                      ? AppConstants.primaryColor.withOpacity(0.1)
                      : AppConstants.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isStudent ? Icons.school_rounded : Icons.business_rounded,
                  color: isStudent
                      ? AppConstants.primaryColor
                      : AppConstants.accentColor,
                  size: 24,
                ),
              ),

              const SizedBox(width: 12),

              // Applicant details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppConstants.textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      userEmail,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: AppConstants.textSecondaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: AppConstants.textSecondaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Registered ${dateFormat.format(createdAt)}',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: AppConstants.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Status badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppConstants.warningColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'PENDING VERIFICATION',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppConstants.warningColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isStudent
                          ? AppConstants.primaryColor.withOpacity(0.1)
                          : AppConstants.accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isStudent ? 'STUDENT' : 'PROVIDER',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: isStudent
                            ? AppConstants.primaryColor
                            : AppConstants.accentColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Details section
          if (isStudent) ...[
            _buildStudentDetails(),
          ] else ...[
            _buildProviderDetails(),
          ],

          const SizedBox(height: 16),

          // Contact info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.phone_rounded,
                  size: 16,
                  color: AppConstants.textSecondaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  phone,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppConstants.textColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Action button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: onViewPressed,
              icon: const Icon(
                Icons.visibility_rounded,
                size: 18,
              ),
              label: const Text(
                'Review Application',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isStudent
                    ? AppConstants.primaryColor
                    : AppConstants.accentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentDetails() {
    return Column(
      children: [
        if (institution != null) ...[
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  'Institution',
                  institution!,
                  Icons.school_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        if (course != null && yearOfStudy != null) ...[
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  'Course',
                  course!,
                  Icons.menu_book_rounded,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDetailItem(
                  'Year of Study',
                  'Year $yearOfStudy',
                  Icons.calendar_today_rounded,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildProviderDetails() {
    return Column(
      children: [
        if (businessType != null && interestRate != null) ...[
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  'Business Type',
                  businessType!,
                  Icons.category_rounded,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDetailItem(
                  'Interest Rate',
                  '${interestRate!.toStringAsFixed(1)}%',
                  Icons.percent_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        if (loanTypes != null && loanTypes!.isNotEmpty) ...[
          _buildDetailItem(
            'Loan Services',
            loanTypes!.take(2).join(', ') +
                (loanTypes!.length > 2
                    ? ' +${loanTypes!.length - 2} more'
                    : ''),
            Icons.account_balance_rounded,
          ),
        ],
        if (website != null && website!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppConstants.accentColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.language_rounded,
                  size: 16,
                  color: AppConstants.accentColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    website!,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppConstants.accentColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: AppConstants.textSecondaryColor,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: AppConstants.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.textColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
