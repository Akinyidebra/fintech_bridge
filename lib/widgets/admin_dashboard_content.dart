import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fintech_bridge/models/loan_model.dart';
import 'package:fintech_bridge/models/transaction_model.dart' as tm;
import 'package:fintech_bridge/models/student_model.dart';
import 'package:fintech_bridge/models/provider_model.dart' as provider_model;
import 'package:fintech_bridge/screens/admin/admin_student_details_screen.dart';
import 'package:fintech_bridge/screens/loading_screen.dart';
import 'package:fintech_bridge/services/database_service.dart';
import 'package:fintech_bridge/services/payment_service.dart';
import 'package:fintech_bridge/utils/constants.dart';
import 'package:fintech_bridge/widgets/admin_activity_item.dart';
import 'package:fintech_bridge/widgets/admin_stats_card.dart';
import 'package:fintech_bridge/widgets/admin_verification_card.dart';
import 'package:fintech_bridge/widgets/admin_welcome_card.dart';
import 'package:fintech_bridge/widgets/empty_section.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AdminDashboardContent extends StatefulWidget {
  final provider_model.Provider? provider;

  const AdminDashboardContent({super.key, this.provider});

  @override
  State<AdminDashboardContent> createState() => _AdminDashboardContentState();
}

class _AdminDashboardContentState extends State<AdminDashboardContent> {
  // Data storage
  Map<String, dynamic>? _adminProfile;
  List<Loan>? _allLoans;
  List<Student>? _allStudents;
  List<provider_model.Provider>? _allProviders;
  Map<String, dynamic>? _systemStats;
  List<Map<String, dynamic>>? _allTransactions;
  final Map<String, String> _userNamesCache = {};

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
      final dbService = Provider.of<DatabaseService>(context, listen: false);

      // Fetch admin profile
      final adminProfileResult = await dbService.getCurrentUserProfile();
      if (adminProfileResult['success']) {
        _adminProfile = {
          'success': true,
          'data': adminProfileResult['data'],
        };
      } else {
        _adminProfile = {
          'success': false,
          'data': null,
        };
      }

      // Fetch all system data
      final results = await Future.wait([
        _fetchAllLoans(),
        _fetchAllStudents(),
        _fetchAllProviders(),
      ]);

      // Process data
      _allLoans = results[0] as List<Loan>?;
      _allStudents = results[1] as List<Student>?;
      _allProviders = results[2] as List<provider_model.Provider>?;

      // Calculate enhanced system statistics
      _systemStats = _calculateEnhancedSystemStats();

      // Load all transactions
      await _loadAllTransactions();
    } catch (e) {
      _errorMessage = 'Failed to load admin dashboard data: ${e.toString()}';
      print('Admin Dashboard loading error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<List<Loan>?> _fetchAllLoans() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('loans')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => Loan.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching all loans: $e');
      return [];
    }
  }

  Future<List<Student>?> _fetchAllStudents() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('students')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => Student.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching all students: $e');
      return [];
    }
  }

  Future<List<provider_model.Provider>?> _fetchAllProviders() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('providers')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => provider_model.Provider.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching all providers: $e');
      return [];
    }
  }

  Future<void> _loadAllTransactions() async {
    try {
      final paymentService =
          Provider.of<PaymentService>(context, listen: false);
      final allTransactionsResult = await paymentService.getAllTransactions();

      if (allTransactionsResult['success'] &&
          allTransactionsResult['data'] is List) {
        final allTransactions =
            (allTransactionsResult['data'] as List).cast<tm.Transaction>();
        List<Map<String, dynamic>> enrichedTransactions = [];

        for (tm.Transaction transaction in allTransactions) {
          try {
            String studentName = 'Unknown Student';
            String providerName = 'Unknown Provider';
            String studentId = 'Unknown';
            String providerId = 'Unknown';
            double loanAmount = 0.0;
            String loanPurpose = 'Unknown';
            String institutionName = 'Unknown';

            // Handle verification transactions differently
            if (transaction.type.toUpperCase() == 'VERIFICATION' ||
                transaction.type.toUpperCase() == 'UNVERIFICATION') {
              if (transaction.userId != null && transaction.userType != null) {
                if (transaction.userType == 'student') {
                  // Get student info directly using userId
                  if (_userNamesCache
                      .containsKey('student_${transaction.userId}')) {
                    studentName =
                        _userNamesCache['student_${transaction.userId}']!;
                  } else {
                    final student = _allStudents?.firstWhere(
                      (s) => s.id == transaction.userId,
                    );
                    if (student != null) {
                      studentName = student.fullName;
                      studentId = student.id;
                      institutionName = student.institutionName;
                      _userNamesCache['student_${transaction.userId}'] =
                          studentName;
                    }
                  }
                } else if (transaction.userType == 'provider') {
                  // Get provider info directly using userId
                  if (_userNamesCache
                      .containsKey('provider_${transaction.userId}')) {
                    providerName =
                        _userNamesCache['provider_${transaction.userId}']!;
                  } else {
                    final provider = _allProviders?.firstWhere(
                      (p) => p.id == transaction.userId,
                    );
                    if (provider != null) {
                      providerName = provider.businessName;
                      providerId = provider.id;
                      _userNamesCache['provider_${transaction.userId}'] =
                          providerName;
                    }
                  }
                }
              }
            } else {
              // Handle loan-related transactions (existing logic)
              final loan = _allLoans?.firstWhere(
                (l) => l.id == transaction.loanId,
              );

              if (loan != null) {
                loanAmount = loan.amount;
                loanPurpose = loan.purpose;
                institutionName = loan.institutionName;
                studentId = loan.studentId;
                providerId = loan.providerId;

                // Get student name
                if (_userNamesCache.containsKey('student_${loan.studentId}')) {
                  studentName = _userNamesCache['student_${loan.studentId}']!;
                } else {
                  final student = _allStudents?.firstWhere(
                    (s) => s.id == loan.studentId,
                  );
                  if (student != null) {
                    studentName = student.fullName;
                    _userNamesCache['student_${loan.studentId}'] = studentName;
                  }
                }

                // Get provider name
                if (_userNamesCache
                    .containsKey('provider_${loan.providerId}')) {
                  providerName =
                      _userNamesCache['provider_${loan.providerId}']!;
                } else {
                  final provider = _allProviders?.firstWhere(
                    (p) => p.id == loan.providerId,
                  );
                  if (provider != null) {
                    providerName = provider.businessName;
                    _userNamesCache['provider_${loan.providerId}'] =
                        providerName;
                  }
                }
              }
            }

            enrichedTransactions.add({
              'transaction': transaction,
              'studentName': studentName,
              'providerName': providerName,
              'studentId': studentId,
              'providerId': providerId,
              'loanAmount': loanAmount,
              'loanPurpose': loanPurpose,
              'institutionName': institutionName,
            });
          } catch (e) {
            print('Error enriching transaction ${transaction.id}: $e');
            enrichedTransactions.add({
              'transaction': transaction,
              'studentName': 'Unknown Student',
              'providerName': 'Unknown Provider',
              'studentId': 'Unknown',
              'providerId': 'Unknown',
              'loanAmount': 0.0,
              'loanPurpose': 'Unknown',
              'institutionName': 'Unknown',
            });
          }
        }

        enrichedTransactions.sort((a, b) => (b['transaction'] as tm.Transaction)
            .createdAt
            .compareTo((a['transaction'] as tm.Transaction).createdAt));

        _allTransactions = enrichedTransactions;
      } else {
        _allTransactions = [];
      }
    } catch (e) {
      print('Error loading all transactions: $e');
      _allTransactions = [];
    }
  }

  Map<String, dynamic> _calculateEnhancedSystemStats() {
    final students = _allStudents ?? [];
    final providers = _allProviders ?? [];
    final loans = _allLoans ?? [];

    // Student statistics
    int totalStudents = students.length;
    int verifiedStudents = students.where((s) => s.verified).length;
    int unverifiedStudents = totalStudents - verifiedStudents;
    int studentsWithActiveLoans = students.where((s) => s.hasActiveLoan).length;
    int studentsWithCompleteDocs =
        students.where((s) => s.hasIdentificationImages).length;

    // Provider statistics
    int totalProviders = providers.length;
    int verifiedProviders = providers.where((p) => p.verified).length;
    int unverifiedProviders = totalProviders - verifiedProviders;
    int activeProviders =
        providers.where((p) => p.verified && p.loanTypes.isNotEmpty).length;

    // Loan statistics
    int totalLoans = loans.length;
    int activeLoans = loans.where((l) => l.status == 'ACTIVE').length;
    int pendingLoans = loans.where((l) => l.status == 'PENDING').length;
    double totalLoanAmount = loans.fold(0.0, (sum, loan) => sum + loan.amount);
    double averageLoanAmount =
        totalLoans > 0 ? totalLoanAmount / totalLoans : 0.0;

    // Recent activity (last 7 days)
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    int recentStudentSignups =
        students.where((s) => s.createdAt.isAfter(sevenDaysAgo)).length;
    int recentProviderSignups =
        providers.where((p) => p.createdAt.isAfter(sevenDaysAgo)).length;
    int recentLoanApplications =
        loans.where((l) => l.createdAt.isAfter(sevenDaysAgo)).length;

    return {
      'totalStudents': totalStudents,
      'verifiedStudents': verifiedStudents,
      'unverifiedStudents': unverifiedStudents,
      'studentsWithActiveLoans': studentsWithActiveLoans,
      'studentsWithCompleteDocs': studentsWithCompleteDocs,
      'totalProviders': totalProviders,
      'verifiedProviders': verifiedProviders,
      'unverifiedProviders': unverifiedProviders,
      'activeProviders': activeProviders,
      'totalLoans': totalLoans,
      'activeLoans': activeLoans,
      'pendingLoans': pendingLoans,
      'totalLoanAmount': totalLoanAmount,
      'averageLoanAmount': averageLoanAmount,
      'recentStudentSignups': recentStudentSignups,
      'recentProviderSignups': recentProviderSignups,
      'recentLoanApplications': recentLoanApplications,
    };
  }

  Future<void> _refreshData() async {
    _userNamesCache.clear();
    await _loadAllData();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingScreen(
        message: 'Loading admin dashboard...',
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
          AdminWelcomeCard(
            adminProfileFuture: Future.value(_adminProfile),
            systemStats: _systemStats ?? {},
          ),
          const SizedBox(height: 24),
          _buildEnhancedSystemOverview(),
          const SizedBox(height: 24),
          _buildVerificationPendingSection(),
          const SizedBox(height: 24),
          _buildRecentActivity(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildEnhancedSystemOverview() {
    if (_systemStats == null) {
      return const EmptySectionWidget(
        message: 'No system data available at the moment.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'System Overview',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppConstants.textColor,
          ),
        ),
        const SizedBox(height: 16),

        // First row - Total users with verification breakdown
        Row(
          children: [
            Expanded(
              child: AdminStatsCard(
                title: 'Active Students',
                value: _systemStats!['totalStudents'].toString(),
                icon: Icons.school_rounded,
                color: AppConstants.primaryColor,
                subtitle:
                    '${_systemStats!['verifiedStudents']} verified, ${_systemStats!['unverifiedStudents']} pending',
                trend: _systemStats!['recentStudentSignups'] > 0
                    ? '+${_systemStats!['recentStudentSignups']} this week'
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AdminStatsCard(
                title: 'Active Providers',
                value: _systemStats!['totalProviders'].toString(),
                icon: Icons.business_rounded,
                color: AppConstants.accentColor,
                subtitle:
                    '${_systemStats!['verifiedProviders']} verified, ${_systemStats!['unverifiedProviders']} pending',
                trend: _systemStats!['recentProviderSignups'] > 0
                    ? '+${_systemStats!['recentProviderSignups']} this week'
                    : null,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Second row - Loan statistics
        Row(
          children: [
            Expanded(
              child: AdminStatsCard(
                title: 'Total Loans',
                value: _systemStats!['totalLoans'].toString(),
                icon: Icons.account_balance_wallet_rounded,
                color: AppConstants.successColor,
                subtitle:
                    '${_systemStats!['activeLoans']} active, ${_systemStats!['pendingLoans']} pending',
                trend: _systemStats!['recentLoanApplications'] > 0
                    ? '+${_systemStats!['recentLoanApplications']} this week'
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AdminStatsCard(
                title: 'Avg. Loan Amount',
                value: _currencyFormat
                    .format(_systemStats!['averageLoanAmount'])
                    .replaceAll('.00', ''),
                icon: Icons.trending_up_rounded,
                color: AppConstants.warningColor,
                subtitle:
                    'Total: ${_currencyFormat.format(_systemStats!['totalLoanAmount']).replaceAll('.00', '')}',
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Third row - Verification status
        Row(
          children: [
            Expanded(
              child: AdminStatsCard(
                title: 'Unverified Users',
                value: (_systemStats!['unverifiedStudents'] +
                        _systemStats!['unverifiedProviders'])
                    .toString(),
                icon: Icons.pending_actions_rounded,
                color: AppConstants.errorColor,
                subtitle:
                    '${_systemStats!['unverifiedStudents']} students, ${_systemStats!['unverifiedProviders']} providers',
                trend: 'Requires attention',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AdminStatsCard(
                title: 'Complete Profiles',
                value: _systemStats!['studentsWithCompleteDocs'].toString(),
                icon: Icons.verified_user_rounded,
                color: AppConstants.primaryColor,
                subtitle: 'Students with documents uploaded',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVerificationPendingSection() {
    if (_allStudents == null && _allProviders == null) {
      return const EmptySectionWidget(
        message: 'No user data available.',
      );
    }

    // Get unverified users
    final unverifiedStudents =
        _allStudents?.where((student) => !student.verified).toList() ?? [];
    final unverifiedProviders =
        _allProviders?.where((provider) => !provider.verified).toList() ?? [];

    // Combine and sort by creation date (most recent first)
    List<Map<String, dynamic>> pendingVerifications = [];

    for (var student in unverifiedStudents) {
      pendingVerifications.add({
        'type': 'student',
        'data': student,
        'createdAt': student.createdAt,
      });
    }

    for (var provider in unverifiedProviders) {
      pendingVerifications.add({
        'type': 'provider',
        'data': provider,
        'createdAt': provider.createdAt,
      });
    }

    pendingVerifications
        .sort((a, b) => b['createdAt'].compareTo(a['createdAt']));

    if (pendingVerifications.isEmpty) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pending Verifications',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppConstants.textColor,
            ),
          ),
          SizedBox(height: 16),
          EmptySectionWidget(
            message:
                '🎉 All users are verified! Great job maintaining platform quality.',
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Pending Verifications',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppConstants.textColor,
              ),
            ),
            Text(
              '${pendingVerifications.length} awaiting review',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: AppConstants.errorColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Show first 3 pending verifications
        ...pendingVerifications.take(3).map((item) {
          if (item['type'] == 'student') {
            final student = item['data'] as Student;
            return AdminVerificationCard(
              userType: 'student',
              userName: student.fullName,
              userEmail: student.universityEmail,
              institution: student.institutionName,
              course: student.course,
              yearOfStudy: student.yearOfStudy.toInt(),
              phone: student.phone,
              createdAt: student.createdAt,
              onViewPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminStudentDetailsScreen(
                      studentId: student.id,
                    ),
                  ),
                );
              },
            );
          } else {
            final provider = item['data'] as provider_model.Provider;
            return AdminVerificationCard(
              userType: 'provider',
              userName: provider.businessName,
              userEmail: provider.businessEmail,
              businessType: provider.businessType,
              loanTypes: provider.loanTypes,
              interestRate: provider.interestRate,
              phone: provider.phone,
              website: provider.website,
              createdAt: provider.createdAt,
              onViewPressed: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => AdminStudentDetailsScreen(
                //       studentId: student.id,
                //     ),
                //   ),
                // );
              },
            );
          }
        }).toList(),

        if (pendingVerifications.length > 3) ...[
          const SizedBox(height: 12),
          Center(
            child: TextButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, '/admin/verification'),
              icon: const Icon(Icons.visibility_rounded),
              label: Text(
                  'View all ${pendingVerifications.length} pending verifications'),
              style: TextButton.styleFrom(
                foregroundColor: AppConstants.primaryColor,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRecentActivity() {
    if (_allTransactions == null || _allTransactions!.isEmpty) {
      return const EmptySectionWidget(
        message: 'No recent activity found',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppConstants.textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // List of recent activity items (show first 4)
        ...(_allTransactions!.take(4).map((enrichedTransaction) {
          final transaction =
              enrichedTransaction['transaction'] as tm.Transaction;
          final studentName = enrichedTransaction['studentName'] as String;
          final providerName = enrichedTransaction['providerName'] as String;

          return AdminActivityItem(
            icon: _getTransactionIcon(transaction.type),
            iconColor: _getTransactionColor(transaction.type),
            title: _getAdminTransactionTitle(
                transaction, studentName, providerName),
            date: DateFormat('MMM dd, yyyy hh:mm a')
                .format(transaction.createdAt),
            amount: _currencyFormat.format(transaction.amount),
            loanId: transaction.loanId,
            studentName: studentName,
            providerName: providerName,
            onTap: () {
              Navigator.pushNamed(context, '/admin/transaction-details',
                  arguments: transaction.id);
            },
            // NEW: Add verification status and user type
            verificationStatus: _getVerificationStatus(transaction.type),
            userType: _getUserType(transaction),
          );
        })),
      ],
    );
  }

  String _getAdminTransactionTitle(
      tm.Transaction transaction, String studentName, String providerName) {
    switch (transaction.type.toUpperCase()) {
      case 'REPAYMENT':
        return '$studentName made repayment to $providerName';
      case 'DISBURSEMENT':
        return '$providerName disbursed loan to $studentName';
      case 'APPLICATION':
        return '$studentName applied for loan from $providerName';
      case 'INTEREST':
        return 'Interest charged: $studentName to $providerName';
      case 'PENALTY':
        return 'Penalty charged: $studentName to $providerName';
      case 'VERIFICATION':
        return 'Account verified for $studentName';
      case 'UNVERIFICATION':
        return 'Account unverified for $studentName';
      default:
        return '${transaction.description} - $studentName & $providerName';
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
      case 'VERIFICATION':
        return Icons.verified_user_rounded;
      case 'UNVERIFICATION':
        return Icons.no_accounts_rounded;
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
      case 'VERIFICATION':
        return AppConstants.successColor;
      case 'UNVERIFICATION':
        return AppConstants.warningColor;
      default:
        return AppConstants.secondaryColor;
    }
  }

  // Add this new method to extract verification status
  String? _getVerificationStatus(String type) {
    switch (type.toUpperCase()) {
      case 'VERIFICATION':
        return 'verified';
      case 'UNVERIFICATION':
        return 'unverified';
      default:
        return null;
    }
  }

  // Add this new method to extract user type
  String? _getUserType(tm.Transaction transaction) {
    if (transaction.description.contains('Student')) {
      return 'student';
    } else if (transaction.description.contains('Provider')) {
      return 'provider';
    }
    return null;
  }
}
