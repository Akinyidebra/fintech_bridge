import 'dart:convert';
import 'package:fintech_bridge/models/loan_model.dart';
import 'package:fintech_bridge/models/student_model.dart';
import 'package:fintech_bridge/models/transaction_model.dart';
import 'package:fintech_bridge/models/provider_model.dart' as model;
import 'package:fintech_bridge/screens/student/loan_application_screen.dart';
import 'package:fintech_bridge/screens/student/loan_details_screen.dart';
import 'package:fintech_bridge/screens/student/my_loans_screen.dart';
import 'package:fintech_bridge/screens/student/profile_screen.dart';
import 'package:fintech_bridge/screens/student/transaction_screen.dart';
import 'package:fintech_bridge/services/database_service.dart';
import 'package:fintech_bridge/services/loan_service.dart';
import 'package:fintech_bridge/services/payment_service.dart';
import 'package:fintech_bridge/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _currentIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const DashboardContent(),
      const LoanApplicationScreen(loanType: '', provider: '',),
      const MyLoansScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              icon: Icons.home_rounded,
              label: 'Home',
              isSelected: _currentIndex == 0,
              onTap: () => setState(() => _currentIndex = 0),
            ),
            _buildNavItem(
              icon: Icons.add_box_rounded,
              label: 'Apply',
              isSelected: _currentIndex == 1,
              onTap: () => setState(() => _currentIndex = 1),
            ),
            _buildNavItem(
              icon: Icons.account_balance_rounded,
              label: 'Loans',
              isSelected: _currentIndex == 2,
              onTap: () => setState(() => _currentIndex = 2),
            ),
            _buildNavItem(
              icon: Icons.person_rounded,
              label: 'Profile',
              isSelected: _currentIndex == 3,
              onTap: () => setState(() => _currentIndex = 3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppConstants.primaryColor.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isSelected
                  ? AppConstants.primaryColor
                  : AppConstants.textSecondaryColor,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? AppConstants.primaryColor
                  : AppConstants.textSecondaryColor,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontFamily: 'Poppins',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

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
          final balanceResult =
              await paymentService.getRemainingBalance(loan.id);
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
          _buildHeader(context),
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
                      _buildWelcomeCard(context),
                      const SizedBox(height: 24),
                      _buildFinancialOverview(context),
                      const SizedBox(height: 24),
                      _buildRecommendedLoans(context),
                      const SizedBox(height: 24),
                      _buildRecentActivity(context),
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

  Widget _buildHeader(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _userProfileFuture,
      builder: (context, snapshot) {
        String profileImage = '';
        if (snapshot.hasData && snapshot.data!['success']) {
          final student = snapshot.data!['data'] as Student;
          profileImage = student.profileImage ?? '';
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          // Don't change profileImage during loading, maintain previous state
        } else {
          // Error or no data - use default empty string
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                    height: 32,
                    child: Image.asset(
                      'assets/icons/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 12),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Fin',
                          style: AppConstants.titleLarge.copyWith(
                            color: AppConstants.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: 'Tech Bridge',
                          style: AppConstants.titleLarge.copyWith(
                            color: AppConstants.accentColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              _buildProfileAvatar(profileImage),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileAvatar(String imageUrl) {
    if (imageUrl.isEmpty) {
      return _buildDefaultAvatar();
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppConstants.primaryColor, width: 2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: imageUrl.isNotEmpty
            ? _buildCachedBase64Image(imageUrl)
            : _buildDefaultAvatar(),
      ),
    );
  }

  Widget _buildCachedBase64Image(String data) {
    try {
      // Handle data URI scheme (e.g., "data:image/png;base64,iVBOR...")
      final base64Data = data.contains('base64,') ? data.split(',').last : data;

      final bytes = base64Decode(base64Data);
      return Image.memory(
        bytes,
        width: 28,
        height: 28,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
        gaplessPlayback: true, // Prevents blinking during image loading
      );
    } catch (e) {
      return _buildDefaultAvatar();
    }
  }

  Widget _buildDefaultAvatar() {
    return const CircleAvatar(
      radius: 14,
      backgroundColor: AppConstants.backgroundSecondaryColor,
      child: Icon(Icons.person, color: AppConstants.textSecondaryColor),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _userProfileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingIndicator();
        }

        if (!snapshot.hasData || !snapshot.data!['success']) {
          return _buildErrorCard('Failed to load profile data');
        }

        final student = snapshot.data!['data'] as Student;
        final role = snapshot.data!['role'];

        return Container(
          margin: const EdgeInsets.only(top: 20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppConstants.cardGradient,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppConstants.primaryColor.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      'Hello, ${student.fullName}!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildRoleBadge(role),
                ],
              ),
              Text(
                'ID: ${student.studentId}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontFamily: 'Poppins',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 20),
              _buildBalanceSection(context, student),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRoleBadge(String role) {
    return Container(
      margin: const EdgeInsets.only(left: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        role.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  Widget _buildBalanceSection(BuildContext context, Student student) {
    return FutureBuilder<double>(
      future: _totalBalanceFuture,
      builder: (context, snapshot) {
        final totalBalance = snapshot.hasData ? snapshot.data! : 0.0;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Balance',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            '\$${totalBalance.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TransactionsScreen(),
                  ),
                ),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'View Details',
                    style: TextStyle(
                      color: AppConstants.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFinancialOverview(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _loansFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingIndicator();
        }

        if (snapshot.hasError) {
          return _buildEmptySection('Unable to load financial summary');
        }

        if (!snapshot.hasData || !(snapshot.data?['success'] ?? false)) {
          return _buildEmptySection('No financial data available');
        }

        final loans = snapshot.data!['data'] as List<Loan>;
        if (loans.isEmpty) {
          return _buildEmptySection(
              'No active loans found. Apply for a loan to see your financial summary.');
        }

        final activeLoans =
            loans.where((loan) => loan.status == 'APPROVED').toList();

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
                  child: _buildSummaryCard(
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
                  child: _buildSummaryCard(
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


  Widget _buildSummaryCard({
    required String title,
    required String amount,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
              Container(
                padding: const EdgeInsets.all(8),
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
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppConstants.textSecondaryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            amount,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppConstants.textSecondaryColor,
              fontSize: 12,
              fontFamily: 'Poppins',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedLoans(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: Provider.of<DatabaseService>(context, listen: false)
          .getVerifiedProviders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingIndicator();
        }

        if (snapshot.hasError) {
          return _buildEmptySection('Unable to load recommended loans');
        }

        if (!snapshot.hasData || !(snapshot.data?['success'] ?? false)) {
          return _buildEmptySection('No recommended loans available');
        }

        final providers = snapshot.data!['data'] as List<model.Provider>;
        if (providers.isEmpty) {
          return _buildEmptySection('No loan providers available at this time');
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
            ...providers.take(2).map((provider) => _buildLoanCard(
                  context: context,
                  title: provider.businessName,
                  description: 'Interest Rate: ${provider.interestRate}%',
                  features: provider.loanTypes,
                  badgeText: provider.loanTypes.isNotEmpty
                      ? provider.loanTypes.first
                      : null,
                  badgeColor: AppConstants.accentColor,
                )),
          ],
        );
      },
    );
  }

  Widget _buildLoanCard({
    required BuildContext context,
    required String title,
    required String description,
    required List<String> features,
    String? badgeText,
    Color? badgeColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppConstants.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: AppConstants.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (badgeText != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: badgeColor!.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      color: badgeColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ...features.take(2).map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppConstants.successColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.check,
                          color: AppConstants.successColor,
                          size: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        feature,
                        style: AppConstants.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          LoanApplicationScreen(loanType: title),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Apply Now',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppConstants.backgroundSecondaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: AppConstants.primaryColor,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _transactionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingIndicator();
        }

        if (snapshot.hasError) {
          return _buildErrorCard('Error: ${snapshot.error}');
        }

        if (!snapshot.hasData || !(snapshot.data?['success'] ?? false)) {
          return _buildErrorCard('Failed to load recent activity');
        }

        final transactions = snapshot.data!['data'] as List<Transaction>;
        if (transactions.isEmpty) {
          return _buildEmptySection('No recent transactions found');
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
            ...transactions.take(3).map((transaction) => _buildActivityItem(
                  context: context,
                  icon: _getTransactionIcon(transaction.type),
                  iconColor: _getTransactionColor(transaction.type),
                  title: transaction.description,
                  date:
                      DateFormat('MMM dd, yyyy').format(transaction.createdAt),
                  amount: '\$${transaction.amount.toStringAsFixed(2)}',
                  loanId: transaction.loanId,
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

  Widget _buildActivityItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String date,
    String? amount,
    bool showArrow = false,
    Color? backgroundColor,
    String? loanId,
  }) {
    return GestureDetector(
      onTap: () {
        if (loanId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoanDetailsScreen(loanId: loanId),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.black.withOpacity(0.03),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: AppConstants.textSecondaryColor,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (amount != null)
              Text(
                amount,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            if (showArrow)
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppConstants.textSecondaryColor,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 30),
      child: Center(
        child: CircularProgressIndicator(color: AppConstants.primaryColor),
      ),
    );
  }

  bool _isConnectionError(dynamic error) {
    return error is FirebaseException &&
        ['unavailable', 'network-error'].contains(error.code);
  }

  Widget _buildErrorCard(String message) {
    final isConnectionError = _isConnectionError(message);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(Icons.wifi_off, color: AppConstants.errorColor),
          const SizedBox(height: 12),
          Text(
            isConnectionError
                ? 'No internet connection\nPlease check your network'
                : 'Error: $message',
            style: const TextStyle(color: AppConstants.errorColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySection(String message) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppConstants.backgroundSecondaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(Icons.info_outline,
              color: AppConstants.textSecondaryColor),
          const SizedBox(height: 12),
          Text(
            message,
            style: AppConstants.bodyMediumSecondary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
