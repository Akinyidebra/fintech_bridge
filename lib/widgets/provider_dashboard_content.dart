import 'package:fintech_bridge/models/loan_model.dart';
import 'package:fintech_bridge/models/transaction_model.dart';
import 'package:fintech_bridge/screens/loading_screen.dart';
import 'package:fintech_bridge/screens/provider/loan_details_screen.dart';
import 'package:fintech_bridge/services/database_service.dart';
import 'package:fintech_bridge/services/loan_service.dart';
import 'package:fintech_bridge/services/payment_service.dart';
import 'package:fintech_bridge/utils/constants.dart';
import 'package:fintech_bridge/widgets/provider_welcome_card.dart';
import 'package:fintech_bridge/widgets/provider_stats_card.dart';
import 'package:fintech_bridge/widgets/provider_activity_item.dart';
import 'package:fintech_bridge/widgets/pending_applications_card.dart';
import 'package:fintech_bridge/widgets/empty_section.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ProviderDashboardContent extends StatefulWidget {
  const ProviderDashboardContent({super.key});

  @override
  State<ProviderDashboardContent> createState() =>
      _ProviderDashboardContentState();
}

class _ProviderDashboardContentState extends State<ProviderDashboardContent> {
  // Data storage
  Map<String, dynamic>? _providerProfile;
  List<Loan>? _providerLoans;
  Map<String, int>? _loanStats;
  List<Map<String, dynamic>>? _providerTransactions;
  final Map<String, String> _studentNamesCache = {};

  // Loading and error states
  bool _isLoading = true;
  String? _errorMessage;

  // Currency formatter
  final NumberFormat _currencyFormat =
      NumberFormat.currency(symbol: 'KES. ', decimalDigits: 2);

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
      final dbService = Provider.of<DatabaseService>(context, listen: false);

      // Fetch provider profile and loans first
      final results = await Future.wait([
        dbService.getCurrentUserProfile(),
        loanService.getProviderLoans(),
      ]);

      // Process provider profile
      final providerProfileResult = results[0];
      if (providerProfileResult['success']) {
        _providerProfile = {
          'success': true,
          'data': providerProfileResult['data'],
        };
      } else {
        _providerProfile = {
          'success': false,
          'data': null,
        };
      }

      // Process loans
      final loansResult = results[1];
      if (loansResult['success'] && loansResult['data'] is List<Loan>) {
        _providerLoans = loansResult['data'] as List<Loan>;
        _loanStats = _calculateLoanStats(_providerLoans!);

        // Get provider-related transactions based on loan IDs
        await _loadProviderTransactions();
      } else {
        _providerLoans = [];
        _loanStats = _calculateLoanStats([]);
        _providerTransactions = [];
      }
    } catch (e) {
      _errorMessage = 'Failed to load dashboard data: ${e.toString()}';
      print('Provider Dashboard loading error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadProviderTransactions() async {
    try {
      if (_providerLoans == null || _providerLoans!.isEmpty) {
        _providerTransactions = [];
        return;
      }

      final paymentService =
          Provider.of<PaymentService>(context, listen: false);
      final dbService = Provider.of<DatabaseService>(context, listen: false);

      final loanIds = _providerLoans!.map((loan) => loan.id).toList();
      List<Map<String, dynamic>> enrichedTransactions = [];

      final allTransactionsResult = await paymentService.getAllTransactions();

      if (allTransactionsResult['success'] &&
          allTransactionsResult['data'] is List) {
        final allTransactions =
            (allTransactionsResult['data'] as List).cast<Transaction>();

        final providerTransactions = allTransactions
            .where((transaction) => loanIds.contains(transaction.loanId))
            .toList();

        for (Transaction transaction in providerTransactions) {
          try {
            final loan = _providerLoans!.firstWhere(
              (l) => l.id == transaction.loanId,
              orElse: () => Loan(
                id: '',
                studentId: 'Unknown',
                providerId: '',
                amount: 0,
                interestRate: 0,
                termMonths: 0,
                status: '',
                institutionName: '',
                purpose: '',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
                providerName: '',
                loanType: '',
                mpesaPhone: '',
                monthlyPayment: 0,
                remainingBalance: 0,
                nextDueDate: DateTime.now(),
                dueDate: DateTime.now(),
                mpesaTransactionCode: '',
                repaymentStartDate: DateTime.now(),
              ),
            );

            String studentName = 'Unknown Student';
            String studentId = loan.studentId;

            if (loan.studentId != 'Unknown' && loan.studentId.isNotEmpty) {
              if (_studentNamesCache.containsKey(loan.studentId)) {
                studentName = _studentNamesCache[loan.studentId]!;
              } else {
                studentName =
                    await dbService.getUserDisplayName(loan.studentId);
                _studentNamesCache[loan.studentId] = studentName;
              }
            }

            enrichedTransactions.add({
              'transaction': transaction,
              'studentName': studentName,
              'studentId': studentId,
              'loanAmount': loan.amount,
              'loanPurpose': loan.purpose,
              'institutionName': loan.institutionName,
            });
          } catch (e) {
            print('Error enriching transaction ${transaction.id}: $e');
            enrichedTransactions.add({
              'transaction': transaction,
              'studentName': 'Unknown',
              'studentId': 'Unknown',
              'loanAmount': 0.0,
              'loanPurpose': 'Unknown',
              'institutionName': 'Unknown',
            });
          }
        }

        enrichedTransactions.sort((a, b) => (b['transaction'] as Transaction)
            .createdAt
            .compareTo((a['transaction'] as Transaction).createdAt));
      }

      _providerTransactions = enrichedTransactions;
    } catch (e) {
      print('Error loading provider transactions: $e');
      _providerTransactions = [];
    }
  }

  Map<String, int> _calculateLoanStats(List<Loan> loans) {
    int activeLoans = loans.where((l) => l.status == 'APPROVED').length;
    int pendingApplications = loans.where((l) => l.status == 'PENDING').length;
    int completedLoans = loans.where((l) => l.status == 'PAID').length;
    int totalApplications = loans.length;
    int rejectedApplications =
        loans.where((l) => l.status == 'REJECTED').length;

    return {
      'active': activeLoans,
      'pending': pendingApplications,
      'completed': completedLoans,
      'total': totalApplications,
      'rejected': rejectedApplications,
    };
  }

  Future<void> _refreshData() async {
    _studentNamesCache.clear();
    await _loadAllData();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingScreen(
        message: 'Loading your provider dashboard...',
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
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
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

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
          ProviderWelcomeCard(
            providerProfileFuture: Future.value(_providerProfile),
            loanStats: _loanStats ?? {},
          ),

          const SizedBox(height: 24),

          _buildProviderOverview(),

          const SizedBox(height: 24),

          _buildPendingApplications(),

          const SizedBox(height: 24),

          _buildRecentActivity(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildProviderOverview() {
    if (_loanStats == null) {
      return const EmptySectionWidget(
        message: 'No loan data available at the moment.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Business Overview',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppConstants.textColor,
          ),
        ),

        const SizedBox(height: 16),

        // First row of stats
        Row(
          children: [
            Expanded(
              child: ProviderStatsCard(
                title: 'Active Loans',
                value: _loanStats!['active'].toString(),
                icon: Icons.trending_up_rounded,
                color: AppConstants.successColor,
                subtitle: 'Currently disbursed',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ProviderStatsCard(
                title: 'Pending',
                value: _loanStats!['pending'].toString(),
                icon: Icons.pending_actions_rounded,
                color: AppConstants.warningColor,
                subtitle: 'Awaiting approval',
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Second row of stats
        Row(
          children: [
            Expanded(
              child: ProviderStatsCard(
                title: 'Completed',
                value: _loanStats!['completed'].toString(),
                icon: Icons.check_circle_rounded,
                color: AppConstants.primaryColor,
                subtitle: 'Fully repaid',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ProviderStatsCard(
                title: 'Total Apps',
                value: _loanStats!['total'].toString(),
                icon: Icons.receipt_long_rounded,
                color: AppConstants.accentColor,
                subtitle: 'All applications',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPendingApplications() {
    if (_providerLoans == null) {
      return const EmptySectionWidget(
        message: 'No loan applications available.',
      );
    }

    final pendingLoans =
        _providerLoans!.where((loan) => loan.status == 'PENDING').toList();

    if (pendingLoans.isEmpty) {
      return const EmptySectionWidget(
        message: 'No pending applications at the moment.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pending Applications',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppConstants.textColor,
          ),
        ),

        const SizedBox(height: 16),

        // List of pending applications
        ...pendingLoans.take(3).map((loan) => PendingApplicationCard(
              loan: loan,
              onViewPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProviderLoanDetailsScreen(
                      loanId: loan.id,
                    ),
                  ),
                );
              },
            )),
      ],
    );
  }

  Widget _buildRecentActivity() {
    if (_providerTransactions == null || _providerTransactions!.isEmpty) {
      return const EmptySectionWidget(
        message: 'No recent activity found',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppConstants.textColor,
          ),
        ),

        const SizedBox(height: 16),

        // List of recent activity items (non-clickable)
        ...(_providerTransactions!.take(4).map((enrichedTransaction) {
          final transaction = enrichedTransaction['transaction'] as Transaction;
          final studentName = enrichedTransaction['studentName'] as String;

          return ProviderActivityItem(
            icon: _getTransactionIcon(transaction.type),
            iconColor: _getTransactionColor(transaction.type),
            title: _getProviderTransactionTitle(transaction, studentName),
            date: DateFormat('MMM dd, yyyy hh:mm a')
                .format(transaction.createdAt),
            amount: _currencyFormat.format(transaction.amount),
            loanId: transaction.loanId,
            studentName: studentName,
            // Removed onTap to make it non-clickable
          );
        })),
      ],
    );
  }

  String _getProviderTransactionTitle(
      Transaction transaction, String studentName) {
    switch (transaction.type.toUpperCase()) {
      case 'REPAYMENT':
        return 'Repayment from $studentName';
      case 'DISBURSEMENT':
        return 'Loan disbursed to $studentName';
      case 'APPLICATION':
        return 'New application from $studentName';
      case 'INTEREST':
        return 'Interest from $studentName';
      case 'PENALTY':
        return 'Penalty from $studentName';
      default:
        return '${transaction.description} - $studentName';
    }
  }

  IconData _getTransactionIcon(String type) {
    switch (type.toUpperCase()) {
      case 'DISBURSEMENT':
        return Icons.account_balance_wallet_rounded;
      case 'REPAYMENT_RECEIVED':
      case 'REPAYMENT':
        return Icons.payments_rounded;
      case 'APPLICATION_RECEIVED':
      case 'APPLICATION':
        return Icons.request_page_rounded;
      case 'LOAN_APPROVED':
        return Icons.check_circle_outline_rounded;
      case 'LOAN_REJECTED':
        return Icons.cancel_outlined;
      case 'INTEREST_EARNED':
      case 'INTEREST':
        return Icons.trending_up_rounded;
      case 'FEE_COLLECTED':
        return Icons.receipt_rounded;
      case 'PENALTY_COLLECTED':
      case 'PENALTY':
        return Icons.warning_amber_rounded;
      default:
        return Icons.swap_horiz_rounded;
    }
  }

  Color _getTransactionColor(String type) {
    switch (type.toUpperCase()) {
      case 'REPAYMENT_RECEIVED':
      case 'REPAYMENT':
      case 'INTEREST_EARNED':
      case 'INTEREST':
      case 'FEE_COLLECTED':
        return AppConstants.successColor;
      case 'DISBURSEMENT':
        return AppConstants.primaryColor;
      case 'APPLICATION_RECEIVED':
      case 'APPLICATION':
      case 'LOAN_APPROVED':
        return AppConstants.accentColor;
      case 'LOAN_REJECTED':
      case 'PENALTY_COLLECTED':
      case 'PENALTY':
        return AppConstants.errorColor;
      default:
        return AppConstants.secondaryColor;
    }
  }
}
