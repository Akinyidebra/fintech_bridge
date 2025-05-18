import 'package:fintech_bridge/models/loan_model.dart';
import 'package:fintech_bridge/models/transaction_model.dart';
import 'package:fintech_bridge/screens/student/loan_application_screen.dart';
import 'package:fintech_bridge/screens/student/loan_details_screen.dart';
import 'package:fintech_bridge/services/database_service.dart';
import 'package:fintech_bridge/services/loan_service.dart';
import 'package:fintech_bridge/services/payment_service.dart';
import 'package:fintech_bridge/utils/constants.dart';
import 'package:fintech_bridge/widgets/activity_item.dart';
import 'package:fintech_bridge/widgets/app_header.dart';
import 'package:fintech_bridge/widgets/empty_section.dart';
import 'package:fintech_bridge/widgets/error_card.dart';
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
  late Future<Map<String, dynamic>> _loansFuture;
  late Future<Map<String, dynamic>> _transactionsFuture;
  late Future<Map<String, dynamic>> _userProfileFuture;
  late Future<double> _totalBalanceFuture;
  late Future<Map<String, dynamic>> _featuredLoansFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    final loanService = Provider.of<LoanService>(context, listen: false);
    final paymentService = Provider.of<PaymentService>(context, listen: false);
    final dbService = Provider.of<DatabaseService>(context, listen: false);

    setState(() {
      _userProfileFuture = dbService.getCurrentUserProfile();
      _loansFuture = loanService.getStudentLoans();
      _transactionsFuture = paymentService.getStudentTransactions();
      _totalBalanceFuture = _calculateTotalBalance(loanService, paymentService);
      _featuredLoansFuture = dbService.getFeaturedLoanProviders();
    });
  }

  Future<double> _calculateTotalBalance(
      LoanService loanService, PaymentService paymentService) async {
    try {
      final loansResult = await loanService.getStudentLoans();
      if (!loansResult['success'] || loansResult['data'] is! List<Loan>) {
        return 0.0;
      }

      double total = 0.0;
      final approvedLoans = (loansResult['data'] as List<Loan>)
          .where((l) => l.status == 'APPROVED');

      for (Loan loan in approvedLoans) {
        try {
          final balanceResult = await paymentService.getRemainingBalance(loan.id);
          if (balanceResult['success']) {
            total += balanceResult['data']['remainingBalance'];
          }
        } catch (e) {
          print('Error fetching balance for loan ${loan.id}: $e');
        }
      }
      return total;
    } catch (e) {
      print('Total balance calculation error: $e');
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          AppHeader(userProfileFuture: _userProfileFuture),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _refreshData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      WelcomeCard(
                        userProfileFuture: _userProfileFuture,
                        totalBalanceFuture: _totalBalanceFuture,
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialOverview() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _loansFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: CircularProgressIndicator(color: AppConstants.primaryColor),
            ),
          );
        }

        if (snapshot.hasError) {
          return const EmptySectionWidget(
            message: 'Unable to load financial summary',
          );
        }

        if (!snapshot.hasData || !(snapshot.data?['success'] ?? false)) {
          return const EmptySectionWidget(
            message: 'No financial data available',
          );
        }

        final loans = snapshot.data!['data'] as List<Loan>;
        if (loans.isEmpty) {
          return const EmptySectionWidget(
            message: 'No active loans found. Apply for a loan to see your financial summary.',
          );
        }

        final activeLoans = loans.where((loan) => loan.status == 'APPROVED').toList();

        // Calculate total upcoming payments
        double nextPaymentTotal = activeLoans.fold(0.0, (sum, loan) {
          if (loan.nextDueDate.isAfter(DateTime.now())) {
            return sum + loan.monthlyPayment;
          }
          return sum;
        });

        // Find nearest due date
        DateTime? nearestDueDate = activeLoans.isNotEmpty
            ? activeLoans.map((l) => l.nextDueDate).reduce((a, b) => a.isBefore(b) ? a : b)
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
                    amount: '\$${nextPaymentTotal.toStringAsFixed(2)}',
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
      },
    );
  }

  Widget _buildRecommendedLoans() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _featuredLoansFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: CircularProgressIndicator(color: AppConstants.primaryColor),
            ),
          );
        }

        if (snapshot.hasError) {
          return const EmptySectionWidget(
            message: 'Unable to load recommended loans',
          );
        }

        if (!snapshot.hasData || !(snapshot.data?['success'] ?? false)) {
          return const EmptySectionWidget(
            message: 'No recommended loans available',
          );
        }

        final providers = snapshot.data!['data'] as List<dynamic>;
        if (providers.isEmpty) {
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
            ...providers.take(2).map((provider) => LoanCardWidget(
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
                        provider: provider, loanType: '',
                      ),
                    ),
                  ),
                )),
          ],
        );
      },
    );
  }

  Widget _buildRecentActivity() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _transactionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: CircularProgressIndicator(color: AppConstants.primaryColor),
            ),
          );
        }

        if (snapshot.hasError) {
          return ErrorCardWidget(message: 'Error: ${snapshot.error}');
        }

        if (!snapshot.hasData || !(snapshot.data?['success'] ?? false)) {
          return const ErrorCardWidget(message: 'Failed to load recent activity');
        }

        final transactions = snapshot.data!['data'] as List<Transaction>;
        if (transactions.isEmpty) {
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
            ...transactions.take(3).map((transaction) => ActivityItemWidget(
                  icon: _getTransactionIcon(transaction.type),
                  iconColor: _getTransactionColor(transaction.type),
                  title: transaction.description,
                  date: DateFormat('MMM dd, yyyy').format(transaction.createdAt),
                  amount: '\$${transaction.amount.toStringAsFixed(2)}',
                  loanId: transaction.loanId,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoanDetailsScreen(loanId: transaction.loanId),
                      ),
                    );
                                    },
                )),
          ],
        );
      },
    );
  }

  IconData _getTransactionIcon(String type) {
    switch (type.toUpperCase()) {
      case 'PAYMENT':
        return Icons.payment;
      case 'DISBURSEMENT':
        return Icons.account_balance_wallet;
      case 'FEE':
        return Icons.receipt;
      case 'REFUND':
        return Icons.undo;
      default:
        return Icons.swap_horiz;
    }
  }

  Color _getTransactionColor(String type) {
    switch (type.toUpperCase()) {
      case 'PAYMENT':
        return AppConstants.successColor;
      case 'DISBURSEMENT':
        return AppConstants.primaryColor;
      case 'FEE':
        return AppConstants.warningColor;
      case 'REFUND':
        return AppConstants.accentColor;
      default:
        return AppConstants.secondaryColor;
    }
  }
}