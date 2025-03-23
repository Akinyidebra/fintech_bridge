import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fintech_bridge/services/payment_service.dart';
import 'package:fintech_bridge/utils/constants.dart';
import 'package:fintech_bridge/models/transaction_model.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class TransactionsScreen extends StatefulWidget {
  final String? loanId;
  const TransactionsScreen({super.key, this.loanId});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen>
    with SingleTickerProviderStateMixin {
  String _selectedFilter = 'all';
  DateTime? _startDate;
  DateTime? _endDate;
  late TabController _tabController;
  bool _isShowingDateRangePicker = false;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredTransactions = [];
  Map<String, dynamic>? _selectedLoan;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _startDate = DateTime.now().subtract(const Duration(days: 30));
    _endDate = DateTime.now();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        switch (_tabController.index) {
          case 0:
            _selectedFilter = 'all';
            break;
          case 1:
            _selectedFilter = 'loans';
            break;
          case 2:
            _selectedFilter = 'payments';
            break;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentService = Provider.of<PaymentService>(context);

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            elevation: 0,
            backgroundColor: AppConstants.primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.only(left: 20, bottom: 16, right: 20),
              title: innerBoxIsScrolled
                  ? const Text('Financial Activities',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold))
                  : null,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: AppConstants.splashGradient,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Financial Activities',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Track your loans and payment history',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            _buildQuickStat(
                              icon: Icons.account_balance_wallet,
                              title: 'Total Loans',
                              value: '3',
                            ),
                            const SizedBox(width: 16),
                            _buildQuickStat(
                              icon: Icons.payments_outlined,
                              title: 'Total Payments',
                              value: '12',
                            ),
                            const SizedBox(width: 16),
                            _buildQuickStat(
                              icon: Icons.savings_outlined,
                              title: 'Total Amount',
                              value: '\$25,000',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.download_rounded, color: Colors.white),
                onPressed: () => _generateStatement(context),
                tooltip: 'Download Statement',
              ),
              IconButton(
                icon:
                    const Icon(Icons.filter_list_rounded, color: Colors.white),
                onPressed: () => _showFilterBottomSheet(context),
                tooltip: 'Filter Transactions',
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppConstants.accentColor,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Loans'),
                Tab(text: 'Payments'),
              ],
            ),
          ),
        ],
        body: FutureBuilder(
          future: paymentService.getStudentTransactions(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!['data'].isEmpty) {
              return _buildEmptyState();
            }

            final transactions = snapshot.data!['data'];

            // Filter transactions based on selected filter and search query
            _filteredTransactions = _filterTransactions(transactions);

            // Get active loans
            final activeLoans = _getActiveLoans(transactions);

            // Get specific loan if loanId is provided
            if (widget.loanId != null && _selectedLoan == null) {
              _selectedLoan = activeLoans.firstWhere(
                (loan) => loan['id'] == widget.loanId,
                orElse: () => activeLoans.isNotEmpty
                    ? activeLoans.first
                    : throw Exception(
                        'No loans found'), // Handle empty case properly
              );
            } else if (_selectedLoan == null && activeLoans.isNotEmpty) {
              _selectedLoan = activeLoans.first;
            }

            return Column(
              children: [
                if (_isShowingDateRangePicker) _buildDateRangePicker(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: TextField(
                    controller: _searchController,
                    decoration: AppConstants.inputDecoration(
                      labelText: 'Search transactions',
                      prefixIcon: Icons.search,
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                if (_selectedLoan != null) ...[
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildActiveLoanCard(_selectedLoan!),
                  ),
                ],
                if (activeLoans.length > 1) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 110,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemCount: activeLoans.length,
                      itemBuilder: (context, index) {
                        final loan = activeLoans[index];
                        final isSelected = _selectedLoan != null &&
                            loan['id'] == _selectedLoan!['id'];

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedLoan = loan;
                            });
                          },
                          child: Container(
                            width: 200,
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppConstants.primaryLightColor
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? AppConstants.primaryColor
                                    : AppConstants.borderColor,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  loan['purpose'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : AppConstants.textColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '\$${loan['totalAmount']}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : AppConstants.primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value:
                                      loan['paidAmount'] / loan['totalAmount'],
                                  backgroundColor: isSelected
                                      ? Colors.white.withOpacity(0.3)
                                      : AppConstants.backgroundSecondaryColor,
                                  color: isSelected
                                      ? Colors.white
                                      : AppConstants.accentColor,
                                  minHeight: 6,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                Expanded(
                  child:
                      _filteredTransactions.isEmpty && _searchQuery.isNotEmpty
                          ? _buildNoResultsFound()
                          : _filteredTransactions.isEmpty
                              ? _buildEmptyTabContent()
                              : _buildTransactionsList(_filteredTransactions),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _generateStatement(context),
        backgroundColor: AppConstants.accentColor,
        icon: const Icon(Icons.download_rounded),
        label: const Text('Statement'),
      ),
    );
  }

  Widget _buildActiveLoanCard(Map<String, dynamic> loan) {
    final double paidPercentage = (loan['paidAmount'] / loan['totalAmount']);
    final daysLeft = loan['dueDate'].difference(DateTime.now()).inDays;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppConstants.gradientContainerDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loan['purpose'],
                    style: AppConstants.bodyLarge.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      loan['status'].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 50,
                width: 50,
                child: Stack(
                  children: [
                    CircularProgressIndicator(
                      value: paidPercentage,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      color: AppConstants.accentColor,
                      strokeWidth: 6,
                    ),
                    Center(
                      child: Text(
                        '${(paidPercentage * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Amount',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.7), fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${loan['totalAmount']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Paid Amount',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.7), fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${loan['paidAmount']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Days Left',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.7), fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$daysLeft days',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: paidPercentage,
            backgroundColor: Colors.white.withOpacity(0.2),
            color: AppConstants.accentColor,
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Disbursed: ${DateFormat('MMM dd, yyyy').format(loan['disbursementDate'])}',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.7), fontSize: 12),
              ),
              Text(
                'Due: ${DateFormat('MMM dd, yyyy').format(loan['dueDate'])}',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.7), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showLoanDetails(loan),
                  icon: const Icon(Icons.visibility_outlined,
                      color: Colors.white),
                  label: const Text('View Details'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _makePayment(loan),
                  icon: const Icon(Icons.payments_outlined),
                  label: const Text('Make Payment'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: AppConstants.primaryColor,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
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

  Widget _buildQuickStat({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList(List<dynamic> transactions) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      itemCount: transactions.length + 1, // +1 for the header
      itemBuilder: (context, index) {
        if (index == 0) {
          return const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Text(
                  'Recent Transactions',
                  style: AppConstants.headlineSmall,
                ),
                Spacer(),
                Icon(Icons.sort, color: AppConstants.textSecondaryColor),
                SizedBox(width: 4),
                Text(
                  'Sort by Date',
                  style: AppConstants.bodySmallSecondary,
                ),
              ],
            ),
          );
        }

        final transaction = transactions[index - 1]; // Adjust for header
        return _buildEnhancedTransactionItem(transaction);
      },
    );
  }

  Widget _buildEnhancedTransactionItem(Transaction transaction) {
    final statusColors = {
      'approved': AppConstants.successColor,
      'rejected': AppConstants.errorColor,
      'pending': AppConstants.warningColor,
      'disbursed': AppConstants.secondaryColor,
      'completed': AppConstants.successColor,
    };

    final typeIcons = {
      'LOAN': Icons.account_balance_outlined,
      'PAYMENT': Icons.payments_outlined,
      'DISBURSEMENT': Icons.account_balance_wallet_outlined,
      'APPLICATION': Icons.description_outlined,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppConstants.containerDecoration,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showTransactionDetails(transaction),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: statusColors[transaction.status.toLowerCase()]
                            ?.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        typeIcons[transaction.type] ??
                            Icons.receipt_long_outlined,
                        color: statusColors[transaction.status.toLowerCase()],
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction.type,
                            style: AppConstants.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            transaction.description,
                            style: AppConstants.bodyMediumSecondary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${transaction.amount.toStringAsFixed(2)}',
                          style: AppConstants.titleMedium.copyWith(
                            color: transaction.type == 'PAYMENT'
                                ? AppConstants.successColor
                                : transaction.type == 'DISBURSEMENT'
                                    ? AppConstants.secondaryColor
                                    : AppConstants.textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color:
                                statusColors[transaction.status.toLowerCase()]
                                    ?.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            transaction.status.toUpperCase(),
                            style: TextStyle(
                              color: statusColors[
                                  transaction.status.toLowerCase()],
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ID: #${transaction.id.substring(0, 8)}',
                      style: AppConstants.bodySmallSecondary,
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: AppConstants.textSecondaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('MMM dd, yyyy - hh:mm a')
                              .format(transaction.createdAt),
                          style: AppConstants.bodySmallSecondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateRangePicker() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Select Date Range',
                style: AppConstants.titleMedium,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _isShowingDateRangePicker = false;
                  });
                },
              ),
            ],
          ),
          SfDateRangePicker(
            selectionMode: DateRangePickerSelectionMode.range,
            initialSelectedRange: PickerDateRange(
              _startDate ?? DateTime.now().subtract(const Duration(days: 30)),
              _endDate ?? DateTime.now(),
            ),
            onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
              if (args.value is PickerDateRange) {
                setState(() {
                  _startDate = args.value.startDate;
                  _endDate = args.value.endDate;
                });
              }
            },
            headerStyle: const DateRangePickerHeaderStyle(
              textStyle: AppConstants.titleMedium,
            ),
            monthCellStyle: DateRangePickerMonthCellStyle(
              todayTextStyle: const TextStyle(
                color: AppConstants.primaryColor,
                fontWeight: FontWeight.bold,
              ),
              todayCellDecoration: BoxDecoration(
                color: AppConstants.primaryLightColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
            selectionColor: AppConstants.primaryColor,
            startRangeSelectionColor: AppConstants.primaryColor,
            endRangeSelectionColor: AppConstants.primaryColor,
            rangeSelectionColor: AppConstants.primaryColor.withOpacity(0.1),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _startDate =
                          DateTime.now().subtract(const Duration(days: 30));
                      _endDate = DateTime.now();
                    });
                  },
                  style: AppConstants.secondaryButtonStyle,
                  child: const Text('Last 30 Days'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppConstants.gradientButton(
                  text: 'Apply Filter',
                  onPressed: () {
                    setState(() {
                      _isShowingDateRangePicker = false;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppConstants.primaryLightColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance_wallet_rounded,
              size: 64,
              color: AppConstants.primaryColor.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Financial Activity Yet',
            style: AppConstants.headlineMedium,
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Your transactions and loan activities will appear here',
              style: AppConstants.bodyMediumSecondary,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 200,
            child: AppConstants.gradientButton(
              text: 'Apply for a Loan',
              onPressed: () {
                // Navigate to loan application screen
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTabContent() {
    final messages = {
      'all': 'No transactions found for the selected period',
      'loans': 'No loan transactions found for the selected period',
      'payments': 'No payment transactions found for the selected period',
    };

    final icons = {
      'all': Icons.receipt_long_outlined,
      'loans': Icons.account_balance_outlined,
      'payments': Icons.payments_outlined,
    };

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppConstants.backgroundSecondaryColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icons[_selectedFilter] ?? Icons.receipt_long_outlined,
              size: 48,
              color: AppConstants.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            messages[_selectedFilter] ?? '',
            style: AppConstants.bodyMediumSecondary,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 200,
            child: OutlinedButton.icon(
              onPressed: () => _showFilterBottomSheet(context),
              icon: const Icon(Icons.filter_list_rounded),
              label: const Text('Change Filter'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppConstants.primaryColor,
                side: const BorderSide(color: AppConstants.primaryColor),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppConstants.backgroundSecondaryColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_outlined,
              size: 48,
              color: AppConstants.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No results found for "$_searchQuery"',
            style: AppConstants.bodyMediumSecondary,
          ),
          const SizedBox(height: 8),
          const Text(
            'Try a different search term or filter',
            style: AppConstants.bodySmallSecondary,
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _searchController.clear();
                _searchQuery = '';
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Clear Search'),
            style: AppConstants.textButtonStyle,
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter Transactions',
                  style: AppConstants.headlineSmall,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Date Range',
              style: AppConstants.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _isShowingDateRangePicker = true;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppConstants.borderColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'From',
                            style: AppConstants.bodySmallSecondary,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _startDate != null
                                ? DateFormat('MMM dd, yyyy').format(_startDate!)
                                : 'Select date',
                            style: AppConstants.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _isShowingDateRangePicker = true;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppConstants.borderColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'To',
                            style: AppConstants.bodySmallSecondary,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _endDate != null
                                ? DateFormat('MMM dd, yyyy').format(_endDate!)
                                : 'Select date',
                            style: AppConstants.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Transaction Type',
              style: AppConstants.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildFilterChip(
                  label: 'All',
                  isSelected: _selectedFilter == 'all',
                  onTap: () => setState(() {
                    _selectedFilter = 'all';
                    _tabController.animateTo(0);
                    Navigator.pop(context);
                  }),
                ),
                _buildFilterChip(
                  label: 'Loans',
                  isSelected: _selectedFilter == 'loans',
                  onTap: () => setState(() {
                    _selectedFilter = 'loans';
                    _tabController.animateTo(1);
                    Navigator.pop(context);
                  }),
                ),
                _buildFilterChip(
                  label: 'Payments',
                  isSelected: _selectedFilter == 'payments',
                  onTap: () => setState(() {
                    _selectedFilter = 'payments';
                    _tabController.animateTo(2);
                    Navigator.pop(context);
                  }),
                ),
                _buildFilterChip(
                  label: 'Disbursements',
                  isSelected: _selectedFilter == 'disbursements',
                  onTap: () => setState(() {
                    _selectedFilter = 'disbursements';
                    Navigator.pop(context);
                  }),
                ),
                _buildFilterChip(
                  label: 'Applications',
                  isSelected: _selectedFilter == 'applications',
                  onTap: () => setState(() {
                    _selectedFilter = 'applications';
                    Navigator.pop(context);
                  }),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Status',
              style: AppConstants.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildFilterChip(
                  label: 'All Status',
                  isSelected: true,
                  onTap: () {},
                ),
                _buildFilterChip(
                  label: 'Approved',
                  isSelected: false,
                  onTap: () {},
                ),
                _buildFilterChip(
                  label: 'Pending',
                  isSelected: false,
                  onTap: () {},
                ),
                _buildFilterChip(
                  label: 'Completed',
                  isSelected: false,
                  onTap: () {},
                ),
                _buildFilterChip(
                  label: 'Rejected',
                  isSelected: false,
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _startDate =
                            DateTime.now().subtract(const Duration(days: 30));
                        _endDate = DateTime.now();
                        _selectedFilter = 'all';
                        _tabController.animateTo(0);
                      });
                      Navigator.pop(context);
                    },
                    style: AppConstants.secondaryButtonStyle,
                    child: const Text('Reset Filters'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AppConstants.gradientButton(
                    text: 'Apply Filters',
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppConstants.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppConstants.primaryColor
                : AppConstants.borderColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppConstants.textColor,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  List<dynamic> _filterTransactions(List<dynamic> transactions) {
    // Filter by transaction type
    List<dynamic> filtered = [];

    if (_selectedFilter == 'all') {
      filtered = List.from(transactions);
    } else if (_selectedFilter == 'loans') {
      filtered = transactions
          .where((t) => t.type == 'LOAN' || t.type == 'DISBURSEMENT')
          .toList();
    } else if (_selectedFilter == 'payments') {
      filtered = transactions.where((t) => t.type == 'PAYMENT').toList();
    } else if (_selectedFilter == 'disbursements') {
      filtered = transactions.where((t) => t.type == 'DISBURSEMENT').toList();
    } else if (_selectedFilter == 'applications') {
      filtered = transactions.where((t) => t.type == 'APPLICATION').toList();
    }

    // Filter by date range
    if (_startDate != null && _endDate != null) {
      filtered = filtered.where((t) {
        final transactionDate = t.createdAt;
        return transactionDate.isAfter(_startDate!) &&
            transactionDate.isBefore(_endDate!.add(const Duration(days: 1)));
      }).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((t) {
        return t.description.toLowerCase().contains(query) ||
            t.type.toLowerCase().contains(query) ||
            t.status.toLowerCase().contains(query) ||
            t.id.toLowerCase().contains(query);
      }).toList();
    }

    // Sort by date (newest first)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return filtered;
  }

  List<Map<String, dynamic>> _getActiveLoans(List<dynamic> transactions) {
    final loans = <Map<String, dynamic>>[];

    // This would typically come from an API call
    // For now, using mock data
    loans.add({
      'id': 'loan-001',
      'purpose': 'Tuition Fee',
      'totalAmount': 10000,
      'paidAmount': 3500,
      'status': 'active',
      'disbursementDate': DateTime.now().subtract(const Duration(days: 60)),
      'dueDate': DateTime.now().add(const Duration(days: 120)),
    });

    loans.add({
      'id': 'loan-002',
      'purpose': 'Housing',
      'totalAmount': 8000,
      'paidAmount': 2000,
      'status': 'active',
      'disbursementDate': DateTime.now().subtract(const Duration(days: 90)),
      'dueDate': DateTime.now().add(const Duration(days: 90)),
    });

    loans.add({
      'id': 'loan-003',
      'purpose': 'Books & Supplies',
      'totalAmount': 2500,
      'paidAmount': 500,
      'status': 'active',
      'disbursementDate': DateTime.now().subtract(const Duration(days: 30)),
      'dueDate': DateTime.now().add(const Duration(days: 150)),
    });

    return loans;
  }

  void _showTransactionDetails(Transaction transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Transaction Details',
                  style: AppConstants.headlineSmall,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppConstants.gradientContainerDecoration,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        transaction.type,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          transaction.status.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Amount',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${transaction.amount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Date',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('MMM dd, yyyy')
                                .format(transaction.createdAt),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Transaction Information',
              style: AppConstants.titleMedium,
            ),
            const SizedBox(height: 12),
            _buildDetailItem('ID', '#${transaction.id}'),
            _buildDetailItem('Description', transaction.description),
            _buildDetailItem('Status', transaction.status),
            _buildDetailItem(
                'Time', DateFormat('hh:mm a').format(transaction.createdAt)),
            _buildDetailItem('Payment Method', 'Bank Transfer'),
            const Divider(height: 32),
            const Text(
              'Related Loan',
              style: AppConstants.titleMedium,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppConstants.borderColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryLightColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance_outlined,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tuition Fee Loan',
                          style: AppConstants.titleMedium,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Loan ID: loan-001',
                          style: AppConstants.bodySmallSecondary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      foregroundColor: AppConstants.primaryColor,
                    ),
                    child: const Text('View'),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.receipt_long_outlined),
                    label: const Text('Download Receipt'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppConstants.primaryColor,
                      side: const BorderSide(color: AppConstants.primaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AppConstants.gradientButton(
                    text: 'Contact Support',
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppConstants.bodyMediumSecondary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppConstants.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  void _showLoanDetails(Map<String, dynamic> loan) {
    // Navigate to loan details screen
  }

  void _makePayment(Map<String, dynamic> loan) {
    // Navigate to payment screen
  }

  void _generateStatement(BuildContext context) {
    setState(() {});

    // Simulate download
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {});

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppConstants.successColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: AppConstants.successColor,
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Statement Generated',
                style: AppConstants.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text(
                'Your financial statement has been successfully generated and downloaded',
                style: AppConstants.bodyMediumSecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              AppConstants.gradientButton(
                text: 'View Statement',
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: AppConstants.textButtonStyle,
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      );
    });
  }
}
