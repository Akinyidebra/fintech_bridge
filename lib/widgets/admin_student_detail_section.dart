import 'package:flutter/material.dart';
import 'package:fintech_bridge/models/student_model.dart';
import 'package:fintech_bridge/utils/constants.dart';
import 'package:intl/intl.dart';

class AdminStudentDetailSection extends StatelessWidget {
  final Student student;

  const AdminStudentDetailSection({
    super.key,
    required this.student,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Personal Information Section
        _buildSection(
          title: 'Personal Information',
          children: [
            _buildDetailRow(
              icon: Icons.person_outline,
              label: 'Full Name',
              value: student.fullName,
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              icon: Icons.email_outlined,
              label: 'University Email',
              value: student.universityEmail,
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              icon: Icons.phone_outlined,
              label: 'Phone Number',
              value: student.phone,
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              icon: Icons.payment_outlined,
              label: 'M-Pesa Phone',
              value: student.mpesaPhone,
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Academic Information Section
        _buildSection(
          title: 'Academic Information',
          children: [
            _buildDetailRow(
              icon: Icons.school_outlined,
              label: 'Institution',
              value: student.institutionName,
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              icon: Icons.badge_outlined,
              label: 'Student ID',
              value: student.studentId,
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              icon: Icons.book_outlined,
              label: 'Course',
              value: student.course,
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              icon: Icons.timeline_outlined,
              label: 'Year of Study',
              value: 'Year ${student.yearOfStudy.toInt()}',
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Verification Status Section
        _buildSection(
          title: 'Verification Status',
          borderColor: student.verified ? Colors.green.shade200 : Colors.orange.shade200,
          children: [
            _buildDetailRow(
              icon: student.verified ? Icons.verified_outlined : Icons.pending_outlined,
              label: 'Verification Status',
              value: student.verified ? 'Verified' : 'Pending Verification',
              iconColor: student.verified ? Colors.green.shade600 : Colors.orange.shade600,
              valueColor: student.verified ? Colors.green.shade700 : Colors.orange.shade700,
            ),
            if (student.verified && student.verifiedAt != null) ...[
              const SizedBox(height: 16),
              _buildDetailRow(
                icon: Icons.calendar_today_outlined,
                label: 'Verified At',
                value: DateFormat('MMM dd, yyyy - hh:mm a').format(student.verifiedAt!),
                iconColor: Colors.green.shade600,
              ),
            ],
            const SizedBox(height: 16),
            _buildDetailRow(
              icon: Icons.image_outlined,
              label: 'ID Documents',
              value: '${student.identificationImagesCount} document(s) uploaded',
              iconColor: student.hasIdentificationImages ? Colors.blue.shade600 : Colors.grey.shade500,
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Loan Status Section
        _buildSection(
          title: 'Loan Status',
          borderColor: student.hasActiveLoan ? Colors.red.shade200 : Colors.green.shade200,
          children: [
            _buildDetailRow(
              icon: student.hasActiveLoan ? Icons.warning_outlined : Icons.check_circle_outlined,
              label: 'Active Loan',
              value: student.hasActiveLoan ? 'Yes - Has Active Loan' : 'No Active Loan',
              iconColor: student.hasActiveLoan ? Colors.red.shade600 : Colors.green.shade600,
              valueColor: student.hasActiveLoan ? Colors.red.shade700 : Colors.green.shade700,
            ),
          ],
        ),

        // Guarantor Information Section
        if (student.hasGuarantors) ...[
          const SizedBox(height: 24),
          _buildGuarantorSection(),
        ],

        const SizedBox(height: 24),

        // Account Information Section
        _buildSection(
          title: 'Account Information',
          children: [
            _buildDetailRow(
              icon: Icons.calendar_today_outlined,
              label: 'Account Created',
              value: DateFormat('MMM dd, yyyy - hh:mm a').format(student.createdAt),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              icon: Icons.update_outlined,
              label: 'Last Updated',
              value: DateFormat('MMM dd, yyyy - hh:mm a').format(student.updatedAt),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
    Color? borderColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            title,
            style: AppConstants.headlineSmall,
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: borderColor != null
                ? Border.all(color: borderColor, width: 1)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildGuarantorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Row(
            children: [
              const Text(
                'Guarantor Information',
                style: AppConstants.headlineSmall,
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${student.guarantorCount} Guarantor(s)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Guarantor 1
        if (student.guarantor1Name != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.shade200, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      color: Colors.blue.shade600,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Primary Guarantor',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  icon: Icons.person_outline,
                  label: 'Full Name',
                  value: student.guarantor1Name!,
                  iconColor: Colors.blue.shade600,
                ),
                if (student.guarantor1Phone != null) ...[
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    icon: Icons.phone_outlined,
                    label: 'Phone Number',
                    value: student.guarantor1Phone!,
                    iconColor: Colors.blue.shade600,
                  ),
                ],
                if (student.guarantor1Relationship != null) ...[
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    icon: Icons.family_restroom_outlined,
                    label: 'Relationship',
                    value: student.guarantor1Relationship!,
                    iconColor: Colors.blue.shade600,
                  ),
                ],
                if (student.guarantor1Email != null) ...[
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: student.guarantor1Email!,
                    iconColor: Colors.blue.shade600,
                  ),
                ],
                if (student.guarantor1IdNumber != null) ...[
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    icon: Icons.badge_outlined,
                    label: 'ID Number',
                    value: student.guarantor1IdNumber!,
                    iconColor: Colors.blue.shade600,
                  ),
                ],
                if (student.guarantor1Occupation != null) ...[
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    icon: Icons.work_outline,
                    label: 'Occupation',
                    value: student.guarantor1Occupation!,
                    iconColor: Colors.blue.shade600,
                  ),
                ],
                if (student.guarantor1Address != null) ...[
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    icon: Icons.location_on_outlined,
                    label: 'Physical Address',
                    value: student.guarantor1Address!,
                    iconColor: Colors.blue.shade600,
                  ),
                ],
                if (student.guarantor1AddedAt != null) ...[
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Added On',
                    value: DateFormat('MMM dd, yyyy').format(student.guarantor1AddedAt!),
                    iconColor: Colors.blue.shade600,
                  ),
                ],
              ],
            ),
          ),
        ],

        // Guarantor 2
        if (student.guarantor2Name != null) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.shade200, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      color: Colors.green.shade600,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Secondary Guarantor',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  icon: Icons.person_outline,
                  label: 'Full Name',
                  value: student.guarantor2Name!,
                  iconColor: Colors.green.shade600,
                ),
                if (student.guarantor2Phone != null) ...[
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    icon: Icons.phone_outlined,
                    label: 'Phone Number',
                    value: student.guarantor2Phone!,
                    iconColor: Colors.green.shade600,
                  ),
                ],
                if (student.guarantor2Relationship != null) ...[
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    icon: Icons.family_restroom_outlined,
                    label: 'Relationship',
                    value: student.guarantor2Relationship!,
                    iconColor: Colors.green.shade600,
                  ),
                ],
                if (student.guarantor2Email != null) ...[
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: student.guarantor2Email!,
                    iconColor: Colors.green.shade600,
                  ),
                ],
                if (student.guarantor2IdNumber != null) ...[
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    icon: Icons.badge_outlined,
                    label: 'ID Number',
                    value: student.guarantor2IdNumber!,
                    iconColor: Colors.green.shade600,
                  ),
                ],
                if (student.guarantor2Occupation != null) ...[
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    icon: Icons.work_outline,
                    label: 'Occupation',
                    value: student.guarantor2Occupation!,
                    iconColor: Colors.green.shade600,
                  ),
                ],
                if (student.guarantor2Address != null) ...[
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    icon: Icons.location_on_outlined,
                    label: 'Physical Address',
                    value: student.guarantor2Address!,
                    iconColor: Colors.green.shade600,
                  ),
                ],
                if (student.guarantor2AddedAt != null) ...[
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Added On',
                    value: DateFormat('MMM dd, yyyy').format(student.guarantor2AddedAt!),
                    iconColor: Colors.green.shade600,
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? iconColor,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (iconColor ?? AppConstants.primaryColor).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: iconColor ?? AppConstants.primaryColor,
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
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                  color: AppConstants.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  color: valueColor ?? AppConstants.textColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}