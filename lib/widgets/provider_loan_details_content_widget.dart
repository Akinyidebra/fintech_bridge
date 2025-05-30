import 'package:fintech_bridge/models/loan_model.dart';
import 'package:fintech_bridge/models/student_model.dart';
import 'package:fintech_bridge/widgets/provider_loan_header_card_widget.dart';
import 'package:fintech_bridge/widgets/provider_payment_schedule_section_widget.dart';
import 'package:fintech_bridge/screens/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fintech_bridge/services/loan_service.dart';
import 'package:fintech_bridge/services/database_service.dart';
import 'package:fintech_bridge/utils/constants.dart';
import 'package:intl/intl.dart';

class ProviderLoanDetailsContent extends StatefulWidget {
  final String loanId;

  const ProviderLoanDetailsContent({super.key, required this.loanId});

  @override
  State<ProviderLoanDetailsContent> createState() =>
      _ProviderLoanDetailsContentState();
}

class _ProviderLoanDetailsContentState
    extends State<ProviderLoanDetailsContent> {
  bool _isLoading = true;
  bool _isUpdating = false;
  String? _errorMessage;
  Loan? _loan;
  Student? _studentProfile; // Add student profile

  @override
  void initState() {
    super.initState();
    _loadLoanData();
  }

  Future<void> _loadLoanData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final loanService = Provider.of<LoanService>(context, listen: false);
      final dbService = Provider.of<DatabaseService>(context, listen: false);

      final result = await loanService.getLoanById(widget.loanId);

      if (result['success']) {
        _loan = result['data'] as Loan;

        // Load student profile using the same approach as dashboard
        await _loadStudentProfile(dbService, _loan!.studentId);

        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Loan not found';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading loan: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadStudentProfile(
      DatabaseService dbService, String studentId) async {
    try {
      final profileResult = await dbService.getUserProfile(studentId);

      if (profileResult['success'] && profileResult['userType'] == 'student') {
        final studentData = profileResult['data'] as Map<String, dynamic>;

        // Create Student object from the profile data
        _studentProfile = Student(
          id: studentId,
          fullName: studentData['fullName'] ?? 'Unknown',
          universityEmail: studentData['universityEmail'] ?? 'Unknown',
          studentId: studentData['studentId'] ?? 'Unknown',
          phone: studentData['phone'] ?? 'Unknown',
          course: studentData['course'] ?? 'Unknown',
          yearOfStudy: (studentData['yearOfStudy'] ?? 0.0).toDouble(),
          profileImage: studentData['profileImage'],
          verified: studentData['verified'] ?? false,
          verifiedAt: studentData['verifiedAt']?.toDate(),
          identificationImages: studentData['identificationImages'] != null
              ? Map<String, dynamic>.from(studentData['identificationImages'])
              : null,
          mpesaPhone: studentData['mpesaPhone'] ?? 'Unknown',
          institutionName: studentData['institutionName'] ?? 'Unknown',
          hasActiveLoan: studentData['hasActiveLoan'] ?? false,
          guarantorDetails: studentData['guarantorDetails'] != null
              ? Map<String, dynamic>.from(studentData['guarantorDetails'])
              : null,
          createdAt: studentData['createdAt']?.toDate() ?? DateTime.now(),
          updatedAt: studentData['updatedAt']?.toDate() ?? DateTime.now(),
        );
      }
    } catch (e) {
      print('Error loading student profile: $e');
      _studentProfile = null;
    }
  }

  Future<void> _updateLoanStatus(String status) async {
    setState(() {
      _isUpdating = true;
    });

    try {
      final loanService = Provider.of<LoanService>(context, listen: false);
      final result = await loanService.updateLoanStatus(widget.loanId, status);

      if (result['success']) {
        await _loadLoanData();
        _showSnackBar(
          'Loan ${status.toLowerCase()} successfully!',
          AppConstants.successColor,
        );
      } else {
        _showSnackBar(
          result['message'] ?? 'Failed to update loan status',
          AppConstants.errorColor,
        );
      }
    } catch (e) {
      _showSnackBar(
        'Error updating loan: ${e.toString()}',
        AppConstants.errorColor,
      );
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingScreen(
        message: 'Loading loan details...',
        isFullScreen: false,
      );
    }

    if (_errorMessage != null || _loan == null) {
      return _buildErrorState();
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProviderLoanHeaderCardWidget(
              loan: _loan!, studentProfile: _studentProfile),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBorrowerDetailsCard(),
                const SizedBox(height: 24),
                if (_studentProfile?.hasGuarantors == true)
                  _buildGuarantorDetailsCard(),
                if (_studentProfile?.hasGuarantors == true)
                  const SizedBox(height: 24),
                _buildLoanDetailsCard(),
                const SizedBox(height: 24),
                _buildPaymentHistorySection(),
                const SizedBox(height: 24),
                _buildActionButtons(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBorrowerDetailsCard() {
    // Use student profile data if available, fallback to loan data
    final studentName = _studentProfile?.fullName ?? 'N/A';
    final studentEmail = _studentProfile?.universityEmail ?? 'N/A';
    final studentPhone = _studentProfile?.phone ?? 'N/A';
    final studentId = _studentProfile?.studentId ?? 'N/A';
    final institutionName =
        _studentProfile?.institutionName ?? _loan!.institutionName;
    final course = _studentProfile?.course ?? 'N/A';
    final yearOfStudy = _studentProfile?.yearOfStudy.toString() ?? 'N/A';
    final mpesaPhone = _studentProfile?.mpesaPhone ?? 'N/A';
    final isVerified = _studentProfile?.verified ?? false;

    return Container(
      width: double.infinity,
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
          Row(
            children: [
              const Text(
                'Borrower Information',
                style: AppConstants.headlineSmall,
              ),
              const Spacer(),
              if (isVerified)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppConstants.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppConstants.successColor.withOpacity(0.3),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified,
                        size: 16,
                        color: AppConstants.successColor,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Verified',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppConstants.successColor,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Full Name', studentName, Icons.person),
          _buildDetailRow('Email', studentEmail, Icons.email),
          _buildDetailRow('Phone', studentPhone, Icons.phone),
          _buildDetailRow('M-Pesa Phone', mpesaPhone, Icons.phone_android),
          _buildDetailRow('Student ID', studentId, Icons.badge),
          _buildDetailRow('Course', course, Icons.school),
          _buildDetailRow(
              'Year of Study', yearOfStudy, Icons.calendar_view_day),
          if (institutionName.isNotEmpty)
            _buildDetailRow('Institution', institutionName, Icons.location_on),
        ],
      ),
    );
  }

  Widget _buildGuarantorDetailsCard() {
    if (_studentProfile?.hasGuarantors != true) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
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
          Text(
            'Guarantor Information (${_studentProfile!.guarantorCount})',
            style: AppConstants.headlineSmall,
          ),
          const SizedBox(height: 16),

          // Guarantor 1
          if (_studentProfile!.guarantor1Details != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppConstants.backgroundSecondaryColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Guarantor 1',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    'Name',
                    _studentProfile!.guarantor1Name ?? 'N/A',
                    Icons.person_outline,
                    isCompact: true,
                  ),
                  _buildDetailRow(
                    'Phone',
                    _studentProfile!.guarantor1Phone ?? 'N/A',
                    Icons.phone_outlined,
                    isCompact: true,
                  ),
                  _buildDetailRow(
                    'Relationship',
                    _studentProfile!.guarantor1Relationship ?? 'N/A',
                    Icons.family_restroom,
                    isCompact: true,
                  ),
                  if (_studentProfile!.guarantor1Email?.isNotEmpty == true)
                    _buildDetailRow(
                      'Email',
                      _studentProfile!.guarantor1Email!,
                      Icons.email_outlined,
                      isCompact: true,
                    ),
                  if (_studentProfile!.guarantor1Occupation?.isNotEmpty == true)
                    _buildDetailRow(
                      'Occupation',
                      _studentProfile!.guarantor1Occupation!,
                      Icons.work_outline,
                      isCompact: true,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Guarantor 2
          if (_studentProfile!.guarantor2Details != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppConstants.backgroundSecondaryColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Guarantor 2',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    'Name',
                    _studentProfile!.guarantor2Name ?? 'N/A',
                    Icons.person_outline,
                    isCompact: true,
                  ),
                  _buildDetailRow(
                    'Phone',
                    _studentProfile!.guarantor2Phone ?? 'N/A',
                    Icons.phone_outlined,
                    isCompact: true,
                  ),
                  _buildDetailRow(
                    'Relationship',
                    _studentProfile!.guarantor2Relationship ?? 'N/A',
                    Icons.family_restroom,
                    isCompact: true,
                  ),
                  if (_studentProfile!.guarantor2Email?.isNotEmpty == true)
                    _buildDetailRow(
                      'Email',
                      _studentProfile!.guarantor2Email!,
                      Icons.email_outlined,
                      isCompact: true,
                    ),
                  if (_studentProfile!.guarantor2Occupation?.isNotEmpty == true)
                    _buildDetailRow(
                      'Occupation',
                      _studentProfile!.guarantor2Occupation!,
                      Icons.work_outline,
                      isCompact: true,
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoanDetailsCard() {
    final interestAmount = _loan!.amount * (_loan!.interestRate / 100);
    final totalAmount = _loan!.amount + interestAmount;
    final daysLeft = _loan!.dueDate.difference(DateTime.now()).inDays;

    return Container(
      width: double.infinity,
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
            'Loan Details',
            style: AppConstants.headlineSmall,
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            'Principal Amount',
            'KES ${NumberFormat('#,##0.00').format(_loan!.amount)}',
            Icons.money,
          ),
          _buildDetailRow(
            'Interest Rate',
            '${_loan!.interestRate.toStringAsFixed(1)}%',
            Icons.percent,
          ),
          _buildDetailRow(
            'Interest Amount',
            'KES ${NumberFormat('#,##0.00').format(interestAmount)}',
            Icons.calculate,
          ),
          _buildDetailRow(
            'Total Amount',
            'KES ${NumberFormat('#,##0.00').format(totalAmount)}',
            Icons.account_balance_wallet,
          ),
          _buildDetailRow(
            'Purpose',
            _loan!.purpose,
            Icons.category,
          ),
          _buildDetailRow(
            'Applied Date',
            DateFormat('dd MMM yyyy, HH:mm').format(_loan!.createdAt),
            Icons.calendar_today,
          ),
          _buildDetailRow(
            'Due Date',
            DateFormat('dd MMM yyyy').format(_loan!.dueDate),
            Icons.event,
          ),
          _buildDetailRow(
            'Days Remaining',
            daysLeft > 0
                ? '$daysLeft days'
                : 'Overdue by ${daysLeft.abs()} days',
            Icons.timer,
            textColor: daysLeft > 0 ? null : AppConstants.errorColor,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'Payment History',
            style: AppConstants.headlineSmall,
          ),
        ),
        ProviderPaymentScheduleSection(loanId: _loan!.id),
      ],
    );
  }

  Widget _buildActionButtons() {
    if (_loan!.status.toUpperCase() == 'PAID' ||
        _loan!.status.toUpperCase() == 'COMPLETED') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppConstants.successColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppConstants.successColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.check_circle,
              color: AppConstants.successColor,
              size: 48,
            ),
            SizedBox(height: 12),
            Text(
              'Loan Completed',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppConstants.successColor,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'This loan has been fully paid and completed.',
              style: AppConstants.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
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
            'Loan Actions',
            style: AppConstants.headlineSmall,
          ),
          const SizedBox(height: 16),
          if (_isUpdating)
            const Center(
              child: CircularProgressIndicator(),
            )
          else
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _loan!.status.toUpperCase() == 'APPROVED'
                            ? null
                            : () => _confirmAction('APPROVED'),
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Approve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.successColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _loan!.status.toUpperCase() == 'REJECTED'
                            ? null
                            : () => _confirmAction('REJECTED'),
                        icon: const Icon(Icons.cancel),
                        label: const Text('Reject'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.errorColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _loan!.status.toUpperCase() == 'PENDING'
                        ? null
                        : () => _confirmAction('PENDING'),
                    icon: const Icon(Icons.schedule),
                    label: const Text('Set to Pending'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.amber.shade700,
                      side: BorderSide(color: Colors.amber.shade700),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon,
      {Color? textColor, bool isCompact = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isCompact ? 8 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppConstants.backgroundSecondaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: isCompact ? 14 : 16,
              color: AppConstants.primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: (isCompact
                          ? AppConstants.bodySmall
                          : AppConstants.bodySmall)
                      .copyWith(
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: (isCompact
                          ? AppConstants.bodySmall
                          : AppConstants.bodyMedium)
                      .copyWith(
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
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
              _errorMessage ?? 'Loan not found',
              style: AppConstants.bodyMedium.copyWith(
                color: AppConstants.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _loadLoanData,
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
          ],
        ),
      ),
    );
  }

  void _confirmAction(String status) {
    String actionText = status.toLowerCase();
    String actionMessage = 'Are you sure you want to $actionText this loan?';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm ${status.toUpperCase()}'),
          content: Text(actionMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _updateLoanStatus(status);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: status == 'APPROVED'
                    ? AppConstants.successColor
                    : status == 'REJECTED'
                        ? AppConstants.errorColor
                        : Colors.amber.shade700,
                foregroundColor: Colors.white,
              ),
              child: Text(actionText.toUpperCase()),
            ),
          ],
        );
      },
    );
  }
}
