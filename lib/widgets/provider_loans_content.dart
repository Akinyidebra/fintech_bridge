import 'package:fintech_bridge/models/loan_model.dart';
import 'package:fintech_bridge/screens/provider/loan_details_screen.dart';
import 'package:fintech_bridge/screens/loading_screen.dart';
import 'package:fintech_bridge/widgets/provider_loan_item_card.dart';
import 'package:fintech_bridge/widgets/provider_loans_tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fintech_bridge/services/loan_service.dart';
import 'package:fintech_bridge/utils/constants.dart';

class ProviderLoansContent extends StatefulWidget {
  const ProviderLoansContent({super.key});

  @override
  State<ProviderLoansContent> createState() => _ProviderLoansContentState();
}

class _ProviderLoansContentState extends State<ProviderLoansContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _errorMessage;
  List<Loan> _allLoans = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 4, vsync: this); // Added one more tab for Rejected
    _loadLoansData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLoansData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final loanService = Provider.of<LoanService>(context, listen: false);
      // Changed to get provider loans instead of student loans
      final result = await loanService.getProviderLoans();

      if (result['success']) {
        setState(() {
          _allLoans = result['data'] as List<Loan>;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load loan applications';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading loan applications: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadLoansData();
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen while data is being fetched
    if (_isLoading) {
      return const LoadingScreen(
        message: 'Loading loan applications...',
        isFullScreen: false,
      );
    }

    // Show error state with retry option
    if (_errorMessage != null) {
      return Padding(
        padding:
            const EdgeInsets.only(top: 24.0), // Add top spacing for error state
        child: Center(
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
        ),
      );
    }

    return Column(
      children: [
        // Tab Bar with improved spacing
        ProviderLoansTabBar(controller: _tabController),

        const SizedBox(height: 16), // Space between tab bar and content

        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildLoansTab('ALL'),
              _buildLoansTab('PENDING'),
              _buildLoansTab('APPROVED'),
              _buildLoansTab('REJECTED'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoansTab(String filter) {
    final filteredLoans = _filterLoans(_allLoans, filter);

    if (filteredLoans.isEmpty) {
      return _buildEmptyState(filter);
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20), // Adjusted padding
        itemCount: filteredLoans.length,
        itemBuilder: (context, index) => ProviderLoanItemCard(
          loan: filteredLoans[index],
          onTap: () => _navigateToProviderLoanDetails(filteredLoans[index]),
          showStudentInfo:
              true, // Show student information instead of provider info
        ),
      ),
    );
  }

  List<Loan> _filterLoans(List<Loan> loans, String filter) {
    if (filter == 'ALL') {
      return loans;
    } else if (filter == 'APPROVED') {
      return loans.where((loan) => loan.status == 'APPROVED').toList();
    } else if (filter == 'PENDING') {
      return loans.where((loan) => loan.status == 'PENDING').toList();
    } else if (filter == 'REJECTED') {
      return loans.where((loan) => loan.status == 'REJECTED').toList();
    }
    return loans;
  }

  Widget _buildEmptyState(String filter) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color:
                        AppConstants.backgroundSecondaryColor.withOpacity(0.8),
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
                  child: Icon(
                    Icons.inbox_outlined,
                    size: 56,
                    color: AppConstants.textSecondaryColor.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  filter == 'ALL'
                      ? 'No loan applications yet'
                      : 'No ${filter.toLowerCase()} applications',
                  style: AppConstants.headlineSmall.copyWith(
                    color: AppConstants.textColor,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  filter == 'ALL'
                      ? 'Students haven\'t applied for loans from your organization yet'
                      : 'You don\'t have any ${filter.toLowerCase()} loan applications at the moment',
                  style: AppConstants.bodyMedium.copyWith(
                    color: AppConstants.textSecondaryColor,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _refreshData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                      shadowColor: AppConstants.primaryColor.withOpacity(0.3),
                    ),
                    child: const Text(
                      'Refresh Applications',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToProviderLoanDetails(Loan loan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProviderLoanDetailsScreen(
          loanId: loan.id,
        ),
      ),
    ).then((_) => _refreshData());
  }
}
