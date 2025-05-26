import 'package:fintech_bridge/models/loan_model.dart';
import 'package:fintech_bridge/models/transaction_model.dart';
import 'package:fintech_bridge/screens/loading_screen.dart';
import 'package:fintech_bridge/screens/student/loan_application_screen.dart';
import 'package:fintech_bridge/screens/student/loan_details_screen.dart';
import 'package:fintech_bridge/services/database_service.dart';
import 'package:fintech_bridge/services/loan_service.dart';
import 'package:fintech_bridge/services/payment_service.dart';
import 'package:fintech_bridge/utils/constants.dart';
import 'package:fintech_bridge/widgets/activity_item.dart';
import 'package:fintech_bridge/widgets/empty_section.dart';
import 'package:fintech_bridge/widgets/loan_card_widget.dart';
import 'package:fintech_bridge/widgets/summary_card.dart';
import 'package:fintech_bridge/widgets/welcome_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  // Data storage
  Map<String, dynamic>? _userProfile;
  List<Loan>? _loans;
  List<Transaction>? _transactions;
  List<dynamic>? _featuredProviders;
  double? _totalBalance;

  // Loading and error states
  bool _isLoading = true;
  String? _errorMessage;

  // Currency formatter - consistent with welcome card
  final NumberFormat _currencyFormat =
      NumberFormat.currency(symbol: 'Ksh. ', decimalDigits: 2);

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final loanService = Provider.of<LoanService>(context, listen: false);
      final paymentService =
          Provider.of<PaymentService>(context, listen: false);
      final dbService = Provider.of<DatabaseService>(context, listen: false);

      // Fetch all data concurrently
      final results = await Future.wait([
        dbService.getCurrentUserProfile(),
        loanService.getStudentLoans(),
        paymentService.getStudentTransactions(),
        dbService.getFeaturedLoanProviders(),
      ]);

      // Process user profile
      final userProfileResult = results[0];
      if (userProfileResult['success']) {
        _userProfile = userProfileResult;
      }

      // Process loans
      final loansResult = results[1];
      if (loansResult['success'] && loansResult['data'] is List<Loan>) {
        _loans = loansResult['data'] as List<Loan>;

        // Calculate total balance for approved loans
        _totalBalance =
            await _calculateTotalBalance(loanService, paymentService, _loans!);
      } else {
        _loans = [];
        _totalBalance = 0.0;
      }

      // Process transactions
      final transactionsResult = results[2];
      if (transactionsResult['success'] &&
          transactionsResult['data'] is List<Transaction>) {
        _transactions = transactionsResult['data'] as List<Transaction>;
      } else {
        _transactions = [];
      }

      // Process featured providers
      final providersResult = results[3];
      if (providersResult['success'] &&
          providersResult['data'] is List<dynamic>) {
        _featuredProviders = providersResult['data'] as List<dynamic>;
      } else {
        _featuredProviders = [];
      }
    } catch (e) {
      _errorMessage = 'Failed to load dashboard data: ${e.toString()}';
      print('Dashboard loading error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<double> _calculateTotalBalance(LoanService loanService,
      PaymentService paymentService, List<Loan> loans) async {
    try {
      double total = 0.0;
      final approvedLoans = loans.where((l) => l.status == 'APPROVED').toList();

      final balanceResults = await Future.wait(approvedLoans
          .map((loan) => paymentService.getRemainingBalance(loan.id)));

      for (int i = 0; i < balanceResults.length; i++) {
        final result = balanceResults[i];
        if (result['success']) {
          total += result['data']['remainingBalance'];
        }
      }

      return total;
    } catch (e) {
      print('Total balance calculation error: $e');
      return 0.0;
    }
  }

  Future<void> _refreshData() async {
    await _loadAllData();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingScreen(
        message: 'Loading your financial dashboard...',
        isFullScreen: false,
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppConstants.errorColor,
              ),
              const SizedBox(height: 16),
              const Text(
                'Something went wrong',
                style: AppConstants.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: AppConstants.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _refreshData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WelcomeCard(
                userProfileFuture: Future.value(_userProfile),
                totalBalanceFuture: Future.value(_totalBalance ?? 0.0),
              ),
              const SizedBox(height: 24),
              _buildFinancialOverview(),
              const SizedBox(height: 24),
              _buildRecommendedLoans(),
              const SizedBox(height: 24),
              _buildRecentActivity(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinancialOverview() {
    if (_loans == null || _loans!.isEmpty) {
      return const EmptySectionWidget(
        message:
            'No active loans found. Apply for a loan to see your financial summary.',
      );
    }

    final activeLoans =
        _loans!.where((loan) => loan.status == 'APPROVED').toList();

    // Calculate total upcoming payments
    double nextPaymentTotal = activeLoans.fold(0.0, (sum, loan) {
      if (loan.nextDueDate.isAfter(DateTime.now())) {
        return sum + loan.monthlyPayment;
      }
      return sum;
    });

    // Find nearest due date
    DateTime? nearestDueDate = activeLoans.isNotEmpty
        ? activeLoans
            .map((l) => l.nextDueDate)
            .reduce((a, b) => a.isBefore(b) ? a : b)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4.0, bottom: 16.0),
          child: Text(
            'Financial Summary',
            style: AppConstants.headlineSmall,
          ),
        ),
        Row(
          children: [
            Expanded(
              child: SummaryCard(
                title: 'Next Payment',
                amount: _currencyFormat.format(nextPaymentTotal),
                subtitle: nearestDueDate != null
                    ? 'Due ${DateFormat('MMM dd').format(nearestDueDate)}'
                    : 'No upcoming payments',
                icon: Icons.calendar_today_rounded,
                color: AppConstants.accentColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SummaryCard(
                title: 'Total Loans',
                amount: activeLoans.length.toString(),
                subtitle: 'Active Loans',
                icon: Icons.account_balance_rounded,
                color: AppConstants.secondaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecommendedLoans() {
    if (_featuredProviders == null || _featuredProviders!.isEmpty) {
      return const EmptySectionWidget(
        message: 'No loan providers available at this time',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 4.0),
                child: Text(
                  'Recommended Loans',
                  style: AppConstants.headlineSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ..._featuredProviders!.take(2).map((provider) => LoanCardWidget(
              title: provider.businessName,
              description: 'Interest Rate: ${provider.interestRate}%',
              features: provider.loanTypes,
              badgeText: provider.loanTypes.isNotEmpty
                  ? provider.loanTypes.first
                  : null,
              badgeColor: AppConstants.accentColor,
              onApplyPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoanApplicationScreen(
                    provider: provider,
                    loanType: '',
                  ),
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildRecentActivity() {
    if (_transactions == null || _transactions!.isEmpty) {
      return const EmptySectionWidget(message: 'No recent transactions found');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 4.0),
                child: Text(
                  'Recent Activity',
                  style: AppConstants.headlineSmall,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ..._transactions!.take(3).map((transaction) => ActivityItemWidget(
              icon: _getTransactionIcon(transaction.type),
              iconColor: _getTransactionColor(transaction.type),
              title: transaction.description,
              date: DateFormat('MMM dd, yyyy').format(transaction.createdAt),
              amount: _currencyFormat.format(transaction.amount),
              loanId: transaction.loanId,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        LoanDetailsScreen(loanId: transaction.loanId),
                  ),
                );
              },
            )),
      ],
    );
  }

  IconData _getTransactionIcon(String type) {
    switch (type.toUpperCase()) {
      // Payment related
      case 'PAYMENT':
        return Icons.payment;
      case 'REPAYMENT':
        return Icons.payments_outlined;
      case 'PARTIAL_PAYMENT':
        return Icons.payment_outlined;
      case 'FULL_PAYMENT':
        return Icons.paid;
      case 'TUITION_PAYMENT':
        return Icons.school_outlined;

      // Loan operations
      case 'DISBURSEMENT':
        return Icons.account_balance_wallet;
      case 'LOAN_APPLICATION':
        return Icons.request_page;
      case 'APPLICATION':
        return Icons.description_outlined;
      case 'LOAN_APPROVAL':
        return Icons.check_circle_outline;
      case 'EMERGENCY_LOAN':
        return Icons.warning_amber_outlined;
      case 'LOAN_EXTENSION':
        return Icons.update;
      case 'DEBT_CONSOLIDATION':
        return Icons.merge;

      // Fees and charges
      case 'FEE':
        return Icons.receipt;
      case 'LATE_FEE':
        return Icons.schedule;
      case 'PROCESSING_FEE':
        return Icons.receipt_long;
      case 'INTEREST':
        return Icons.trending_up;
      case 'PENALTY':
        return Icons.warning;

      // Student specific allowances
      case 'BOOK_ALLOWANCE':
        return Icons.menu_book;
      case 'LIVING_ALLOWANCE':
        return Icons.home_outlined;

      // Status changes
      case 'REJECTION':
        return Icons.cancel_outlined;
      case 'REFUND':
        return Icons.undo;
      case 'GRACE_PERIOD':
        return Icons.pause_circle_outline;
      case 'SCHOLARSHIP_CREDIT':
        return Icons.card_giftcard;

      default:
        return Icons.swap_horiz;
    }
  }

  Color _getTransactionColor(String type) {
    switch (type.toUpperCase()) {
      // Positive/Success transactions (green)
      case 'PAYMENT':
      case 'REPAYMENT':
      case 'PARTIAL_PAYMENT':
      case 'FULL_PAYMENT':
      case 'SCHOLARSHIP_CREDIT':
        return AppConstants.successColor;

      // Loan disbursements and approvals (primary blue)
      case 'DISBURSEMENT':
      case 'LOAN_APPROVAL':
      case 'BOOK_ALLOWANCE':
      case 'LIVING_ALLOWANCE':
      case 'TUITION_PAYMENT':
        return AppConstants.primaryColor;

      // Warning/Caution transactions (orange/amber)
      case 'FEE':
      case 'PROCESSING_FEE':
      case 'INTEREST':
      case 'GRACE_PERIOD':
      case 'LOAN_EXTENSION':
        return AppConstants.warningColor;

      // Negative/Error transactions (red)
      case 'REJECTION':
      case 'LATE_FEE':
      case 'PENALTY':
        return AppConstants.errorColor;

      // Neutral/Info transactions (accent orange)
      case 'REFUND':
      case 'LOAN_APPLICATION':
      case 'APPLICATION':
      case 'EMERGENCY_LOAN':
      case 'DEBT_CONSOLIDATION':
        return AppConstants.accentColor;

      // Default (secondary blue)
      default:
        return AppConstants.secondaryColor;
    }
  }
}
