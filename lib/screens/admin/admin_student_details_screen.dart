import 'package:fintech_bridge/widgets/admin_student_details_content.dart';
import 'package:fintech_bridge/widgets/custom_app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:fintech_bridge/utils/constants.dart';

class AdminStudentDetailsScreen extends StatelessWidget {
  final String studentId;

  const AdminStudentDetailsScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: CustomAppBar(
        title: 'Student Details',
        showHelp: true,
        onHelpPressed: () {
          // Show help information
          _showHelpDialog(context);
        },
      ),
      body: AdminStudentDetailsContent(studentId: studentId),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Student Details Help',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            'Here you can view student information, manage verification status, and track their academic progress. Use the action buttons to verify students or update their information.',
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Got it',
                style: TextStyle(
                  color: AppConstants.primaryColor,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
