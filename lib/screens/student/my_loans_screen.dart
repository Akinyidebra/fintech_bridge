import 'package:fintech_bridge/models/loan_model.dart';
import 'package:fintech_bridge/screens/student/loan_details_screen.dart';
import 'package:fintech_bridge/screens/student/loan_application_screen.dart'; // Added missing import
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fintech_bridge/services/loan_service.dart';
import 'package:fintech_bridge/utils/constants.dart';

class MyLoansScreen extends StatefulWidget {
  const MyLoansScreen({super.key});

  @override
  State<MyLoansScreen> createState() => _MyLoansScreenState();
}

class _MyLoansScreenState extends State<MyLoansScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loanService = Provider.of<LoanService>(context);

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSummaryCards(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildLoansTab(loanService, 'ALL'),
                  _buildLoansTab(loanService, 'ACTIVE'),
                  _buildLoansTab(loanService, 'PENDING'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
          const Text(
            'My Loans',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          GestureDetector(
            onTap: () {
              // Filter action
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppConstants.backgroundSecondaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.filter_list_rounded,
                color: AppConstants.primaryColor,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppConstants.cardGradient,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Loan Summary',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  icon: Icons.account_balance_rounded,
                  title: 'Total Loans',
                  value: '2',
                  subtitle: 'Active',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  icon: Icons.attach_money_rounded,
                  title: 'Total Amount',
                  value: '\$24,500',
                  subtitle: 'Borrowed',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  icon: Icons.calendar_today_rounded,
                  title: 'Next Payment',
                  value: '\$350',
                  subtitle: 'Due Mar 15',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: TabBar(
        controller: _tabController,
        labelColor: AppConstants.primaryColor,
        unselectedLabelColor: AppConstants.textSecondaryColor,
        indicatorColor: AppConstants.primaryColor,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Active'),
          Tab(text: 'Pending'),
        ],
      ),
    );
  }

  Widget _buildLoansTab(LoanService loanService, String filter) {
    return FutureBuilder<Map<String, dynamic>>(
      future: loanService.getStudentLoans(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingIndicator();
        }

        if (!snapshot.hasData || !snapshot.data!['success']) {
          return _buildErrorState('Failed to load loans');
        }

        final allLoans = snapshot.data!['data'] as List<Loan>;
        final filteredLoans = _filterLoans(allLoans, filter);

        if (filteredLoans.isEmpty) {
          return _buildEmptyState(filter);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: filteredLoans.length,
          itemBuilder: (context, index) => _buildLoanItem(filteredLoans[index]),
        );
      },
    );
  }

  // Added missing method for filtering loans
  List<Loan> _filterLoans(List<Loan> loans, String filter) {
    if (filter == 'ALL') {
      return loans;
    } else if (filter == 'ACTIVE') {
      return loans.where((loan) => loan.status == 'APPROVED').toList();
    } else if (filter == 'PENDING') {
      return loans.where((loan) => loan.status == 'PENDING').toList();
    }
    return loans;
  }

  // Added missing loading indicator widget
  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppConstants.primaryColor,
      ),
    );
  }

  // Added missing error state widget
  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 60,
            color: AppConstants.errorColor,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              color: AppConstants.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {}); // Refresh the screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String filter) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 60,
            color: AppConstants.textSecondaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No ${filter.toLowerCase()} loans found',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              color: AppConstants.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _navigateToLoanApplication(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Apply for a Loan'),
          ),
        ],
      ),
    );
  }

  void _navigateToLoanApplication(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LoanApplicationScreen(loanType: ''),
      ),
    ).then((result) {
      if (result != null && result == true) {
        setState(() {}); // Refresh the screen after successful application
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Loan application submitted successfully!')),
        );
      }
    });
  }

  Widget _buildLoanItem(Loan loan) {
    final currencyFormatter =
        NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final formattedAmount = currencyFormatter.format(loan.amount);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoanDetailsScreen(loanId: loan.id),
        ),
      ).then((_) => setState(() {})), // Refresh after returning from details
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getLoanIconColor(loan.purpose).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getLoanIcon(loan.purpose),
                      color: _getLoanIconColor(loan.purpose),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getLoanPurposeTitle(loan.purpose),
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${loan.id}',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            color: AppConstants.textSecondaryColor,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formattedAmount,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(loan.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getStatusText(loan.status),
                          style: TextStyle(
                            color: _getStatusColor(loan.status),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: AppConstants.backgroundSecondaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Due: ${DateFormat('MMM dd, yyyy').format(loan.dueDate)}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: AppConstants.textSecondaryColor,
                    ),
                  ),
                  const Row(
                    children: [
                      Text(
                        'View Details',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: AppConstants.primaryColor,
                        size: 14,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'APPROVED':
        return AppConstants.successColor;
      case 'PENDING':
        return AppConstants.warningColor;
      case 'REJECTED':
        return AppConstants.errorColor;
      default:
        return AppConstants.textColor;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'APPROVED':
        return 'Approved';
      case 'PENDING':
        return 'Pending';
      case 'REJECTED':
        return 'Rejected';
      case 'PAID':
        return 'Paid';
      default:
        return status;
    }
  }

  IconData _getLoanIcon(String purpose) {
    switch (purpose.toLowerCase()) {
      case 'tuition':
        return Icons.school_rounded;
      case 'housing':
        return Icons.home_rounded;
      case 'books':
        return Icons.book_rounded;
      case 'equipment':
        return Icons.laptop_rounded;
      default:
        return Icons.account_balance_rounded;
    }
  }

  Color _getLoanIconColor(String purpose) {
    switch (purpose.toLowerCase()) {
      case 'tuition':
        return AppConstants.primaryColor;
      case 'housing':
        return AppConstants.accentColor;
      case 'books':
        return Colors.green;
      case 'equipment':
        return Colors.purple;
      default:
        return AppConstants.secondaryColor;
    }
  }

  String _getLoanPurposeTitle(String purpose) {
    switch (purpose.toLowerCase()) {
      case 'tuition':
        return 'Tuition Loan';
      case 'housing':
        return 'Housing Loan';
      case 'books':
        return 'Books & Supplies';
      case 'equipment':
        return 'Equipment Loan';
      default:
        return '${purpose.substring(0, 1).toUpperCase()}${purpose.substring(1)} Loan';
    }
  }
}
