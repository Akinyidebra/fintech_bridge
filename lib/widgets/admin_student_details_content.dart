import 'package:fintech_bridge/models/student_model.dart';
import 'package:fintech_bridge/screens/loading_screen.dart';
import 'package:fintech_bridge/widgets/admin_academic_info_section.dart';
import 'package:fintech_bridge/widgets/admin_student_action_buttons.dart';
import 'package:fintech_bridge/widgets/admin_student_detail_section.dart';
import 'package:fintech_bridge/widgets/admin_student_header_card_widget.dart';
import 'package:fintech_bridge/widgets/admin_student_summary_card.dart';
import 'package:fintech_bridge/widgets/admin_student_verification_modal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fintech_bridge/services/database_service.dart';
import 'package:fintech_bridge/utils/constants.dart';

class AdminStudentDetailsContent extends StatefulWidget {
  final String studentId;

  const AdminStudentDetailsContent({super.key, required this.studentId});

  @override
  State<AdminStudentDetailsContent> createState() => _AdminStudentDetailsContentState();
}

class _AdminStudentDetailsContentState extends State<AdminStudentDetailsContent> {
  bool _isLoading = true;
  String? _errorMessage;
  Student? _student;

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dbService = Provider.of<DatabaseService>(context, listen: false);
      final result = await dbService.getStudentById(widget.studentId);

      if (result['success']) {
        setState(() {
          _student = result['data'] as Student;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Student not found';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading student: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadStudentData();
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen while data is being fetched
    if (_isLoading) {
      return const LoadingScreen(
        message: 'Loading student details...',
        isFullScreen: false,
      );
    }

    // Show error state with retry option
    if (_errorMessage != null || _student == null) {
      return _buildErrorState();
    }

    final registrationDays = DateTime.now().difference(_student!.createdAt).inDays;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminStudentsHeaderCardWidget(student: _student!,),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AdminStudentSummaryCard(student: _student!, registrationDays: registrationDays,),
                const SizedBox(height: 24),
                AdminStudentDetailSection(student: _student!),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 16),
                  child: Text(
                    'Academic Information',
                    style: AppConstants.headlineSmall,
                  ),
                ),
                AdminAcademicInfoSection(student: _student!),
                const SizedBox(height: 24),
                AdminStudentActionButtons(
                  student: _student!,
                  onVerifyStudent: () => _showVerificationModal(context),
                  onEditStudent: () => _editStudent(),
                  onRefresh: _refreshData,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppConstants.backgroundSecondaryColor.withOpacity(0.8),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.error_outline,
                size: 56,
                color: AppConstants.errorColor,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Something went wrong',
              style: AppConstants.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Student not found',
              style: AppConstants.bodyMedium.copyWith(
                color: AppConstants.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _refreshData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Try Again',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppConstants.primaryColor,
                    side: const BorderSide(color: AppConstants.primaryColor),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Back to Students',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showVerificationModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AdminStudentVerificationModal(
        student: _student!,
        onVerificationSuccess: () {
          _refreshData();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_student!.verified 
                ? 'Student unverified successfully!' 
                : 'Student verified successfully!'),
              backgroundColor: AppConstants.successColor,
            ),
          );
        },
        onVerificationError: (message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: AppConstants.errorColor,
            ),
          );
        },
      ),
    );
  }

  void _editStudent() {
    // Implement edit student logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Student editing will be available soon'),
        backgroundColor: AppConstants.primaryColor,
      ),
    );
  }
}