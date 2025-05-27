import 'package:fintech_bridge/models/loan_model.dart';
import 'package:fintech_bridge/widgets/loan_action_buttons.dart';
import 'package:fintech_bridge/widgets/loan_detail_section_widget.dart';
import 'package:fintech_bridge/widgets/loan_header_card_widget.dart';
import 'package:fintech_bridge/screens/loading_screen.dart';
import 'package:fintech_bridge/widgets/loan_summary_card_widget.dart';
import 'package:fintech_bridge/widgets/payment_modal.dart';
import 'package:fintech_bridge/widgets/payment_schedule_section_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fintech_bridge/services/loan_service.dart';
import 'package:fintech_bridge/utils/constants.dart';

class LoanDetailsContent extends StatefulWidget {
  final String loanId;

  const LoanDetailsContent({super.key, required this.loanId});

  @override
  State<LoanDetailsContent> createState() => _LoanDetailsContentState();
}

class _LoanDetailsContentState extends State<LoanDetailsContent> {
  bool _isLoading = true;
  String? _errorMessage;
  Loan? _loan;

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
      final result = await loanService.getLoanById(widget.loanId);

      if (result['success']) {
        setState(() {
          _loan = result['data'] as Loan;
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

  Future<void> _refreshData() async {
    await _loadLoanData();
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen while data is being fetched
    if (_isLoading) {
      return const LoadingScreen(
        message: 'Loading loan details...',
        isFullScreen: false,
      );
    }

    // Show error state with retry option
    if (_errorMessage != null || _loan == null) {
      return _buildErrorState();
    }

    final daysLeft = _loan!.dueDate.difference(DateTime.now()).inDays;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LoanHeaderCardWidget(loan: _loan!),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LoanSummaryCard(loan: _loan!, daysLeft: daysLeft),
                const SizedBox(height: 24),
                LoanDetailSection(loan: _loan!),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 16),
                  child: Text(
                    'Payment Schedule',
                    style: AppConstants.headlineSmall,
                  ),
                ),
                PaymentScheduleSection(loanId: _loan!.id),
                const SizedBox(height: 24),
                LoanActionButtons(
                  loan: _loan!,
                  onMakePayment: () => _showPaymentModal(context),
                  onDownloadStatement: () => _downloadStatement(),
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
              _errorMessage ?? 'Loan not found',
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
                    'Back to Loans',
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

  void _showPaymentModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PaymentModal(
        loan: _loan!,
        onPaymentSuccess: () {
          _refreshData();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment processed successfully!'),
              backgroundColor: AppConstants.successColor,
            ),
          );
        },
        onPaymentError: (message) {
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

  void _downloadStatement() {
    // Implement download statement logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Statement download will be available soon'),
        backgroundColor: AppConstants.primaryColor,
      ),
    );
  }
}
