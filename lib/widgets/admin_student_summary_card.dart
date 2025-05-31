import 'package:flutter/material.dart';
import 'package:fintech_bridge/models/student_model.dart';
import 'package:fintech_bridge/utils/constants.dart';
import 'package:intl/intl.dart';

class AdminStudentSummaryCard extends StatelessWidget {
  final Student student;
  final int registrationDays;

  const AdminStudentSummaryCard({
    super.key,
    required this.student,
    required this.registrationDays,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
              const Text(
                'Quick Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  color: AppConstants.textColor,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: student.verified 
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: student.verified 
                        ? Colors.green.withOpacity(0.3)
                        : Colors.orange.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      student.verified 
                          ? Icons.verified_outlined 
                          : Icons.pending_outlined,
                      size: 14,
                      color: student.verified ? Colors.green.shade600 : Colors.orange.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      student.verified ? 'Verified' : 'Pending',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: student.verified ? Colors.green.shade700 : Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // First row - Registration and Academic Info
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.calendar_today_outlined,
                  label: 'Registered',
                  value: '$registrationDays days ago',
                  color: AppConstants.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.school_outlined,
                  label: 'Year of Study',
                  value: 'Year ${student.yearOfStudy.toInt()}',
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Second row - Institution and Course
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.business_outlined,
                  label: 'Institution',
                  value: student.institutionName,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.book_outlined,
                  label: 'Course',
                  value: student.course,
                  color: Colors.indigo,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Third row - Loan Status and Documents
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  icon: student.hasActiveLoan 
                      ? Icons.warning_outlined 
                      : Icons.check_circle_outlined,
                  label: 'Loan Status',
                  value: student.hasActiveLoan ? 'Active Loan' : 'No Active Loan',
                  color: student.hasActiveLoan ? Colors.red : Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.image_outlined,
                  label: 'Documents',
                  value: '${student.identificationImagesCount} uploaded',
                  color: student.hasIdentificationImages ? Colors.teal : Colors.grey,
                ),
              ),
            ],
          ),
          
          // Fourth row - Guarantor Information (if available)
          if (student.hasGuarantors) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    icon: Icons.people_outline,
                    label: 'Guarantors',
                    value: '${student.guarantorCount} added',
                    color: Colors.cyan,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryItem(
                    icon: Icons.contact_phone_outlined,
                    label: 'Emergency Contacts',
                    value: '${student.guarantorContacts.length} available',
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ],
          
          // Payment Information
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.payment_outlined,
                  label: 'M-Pesa Phone',
                  value: student.mpesaPhone,
                  color: Colors.green.shade600,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.phone_outlined,
                  label: 'Primary Phone',
                  value: student.phone,
                  color: Colors.blueGrey,
                ),
              ),
            ],
          ),

          // Last Updated Information
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey.shade200,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.update_outlined,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  'Last updated: ${DateFormat('MMM dd, yyyy - hh:mm a').format(student.updatedAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              color: AppConstants.textColor,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}