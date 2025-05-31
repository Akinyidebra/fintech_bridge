import 'package:flutter/material.dart';
import 'package:fintech_bridge/models/student_model.dart';
import 'package:fintech_bridge/utils/constants.dart';

class AdminAcademicInfoSection extends StatelessWidget {
  final Student student;

  const AdminAcademicInfoSection({
    super.key,
    required this.student,
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
          // Institution
          if (student.institutionName.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildAcademicRow(
              icon: Icons.account_balance_outlined,
              label: 'Institution',
              value: student.institutionName,
              color: Colors.green,
            ),
          ],

          // Course
          if (student.course.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildAcademicRow(
              icon: Icons.book_outlined,
              label: 'Course',
              value: student.course,
              color: Colors.orange,
            ),
          ],

          // Year of Study
          ...[
            const SizedBox(height: 16),
            _buildAcademicRow(
              icon: Icons.timeline_outlined,
              label: 'Year of Study',
              value: _getYearOfStudyText(student.yearOfStudy),
              color: Colors.purple,
            ),
          ],

          // Student ID
          if (student.studentId.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildAcademicRow(
              icon: Icons.badge_outlined,
              label: 'Student ID',
              value: student.studentId,
              color: Colors.indigo,
            ),
          ],

          // Academic Status
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  student.verified
                      ? AppConstants.successColor.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  student.verified
                      ? AppConstants.successColor.withOpacity(0.05)
                      : Colors.orange.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: student.verified
                    ? AppConstants.successColor.withOpacity(0.3)
                    : Colors.orange.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: student.verified
                        ? AppConstants.successColor
                        : Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    student.verified
                        ? Icons.verified_user
                        : Icons.pending_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Academic Verification Status',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                          color: AppConstants.textSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        student.verified
                            ? 'Verified Student'
                            : 'Verification Pending',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          color: student.verified
                              ? AppConstants.successColor
                              : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: color,
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
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  color: AppConstants.textColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getYearOfStudyText(double year) {
    switch (year) {
      case 1:
        return '1st Year';
      case 1.0:
        return '1st Year';
      case 1.1:
        return '1st Year 1st Semester';
      case 1.2:
        return '1st Year 2nd Semester';
      case 2:
        return '2nd Year';
      case 2.0:
        return '2nd Year';
      case 2.1:
        return '2nd Year 1st Semester';
      case 2.2:
        return '2nd Year 2nd Semester';
      case 3:
        return '3rd Year';
      case 3.0:
        return '3rd Year';
      case 3.1:
        return '3rd Year 1st Semester';
      case 3.2:
        return '3rd Year 2nd Semester';
      case 4:
        return '4th Year';
      case 4.0:
        return '4th Year';
      case 4.1:
        return '4th Year 1st Semester';
      case 4.2:
        return '4th Year 2nd Semester';
      case 5:
        return '5th Year';
      case 5.0:
        return '5th Year';
      case 5.1:
        return '5th Year 1st Semester';
      case 5.2:
        return '5th Year 2nd Semester';
      case 6:
        return '6th Year';
      case 6.0:
        return '6th Year';
      case 6.1:
        return '6th Year 1st Semester';
      case 6.2:
        return '6th Year 2nd Semester';
      default:
        return '${year}th Year';
    }
  }
}
