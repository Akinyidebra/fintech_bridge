import 'package:fintech_bridge/models/student_model.dart';
import 'package:fintech_bridge/screens/student/transaction_screen.dart';
import 'package:fintech_bridge/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WelcomeCard extends StatelessWidget {
  final Future<Map<String, dynamic>> userProfileFuture;
  final Future<double> totalBalanceFuture;

  const WelcomeCard({
    super.key,
    required this.userProfileFuture,
    required this.totalBalanceFuture,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: 'Ksh. ', decimalDigits: 2);
    
    return FutureBuilder<Map<String, dynamic>>(
      future: userProfileFuture,
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard();
        }

        if (!userSnapshot.hasData || !(userSnapshot.data?['success'] ?? false)) {
          return _buildErrorCard();
        }

        final student = userSnapshot.data!['data'] as Student;
        
        return FutureBuilder<double>(
          future: totalBalanceFuture,
          builder: (context, balanceSnapshot) {
            double balance = 0.0;
            if (balanceSnapshot.hasData) {
              balance = balanceSnapshot.data!;
            }
            
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppConstants.primaryColor,
                    Color(0xFF4C47CC),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppConstants.primaryColor.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: Text(
                          _getInitials(student.fullName),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, ${student.fullName}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            Text(
                              student.institutionName,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                                fontFamily: 'Poppins',
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Outstanding Balance',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Flexible(
                                  child: Text(
                                    currencyFormat.format(balance),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 28,
                                      fontFamily: 'Poppins',
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (balanceSnapshot.connectionState == ConnectionState.waiting)
                                  const SizedBox(
                                    height: 12,
                                    width: 12,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      _buildTransactionButton(context),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTransactionButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TransactionsScreen(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_rounded,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(height: 4),
            Text(
              'History',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      width: double.infinity,
      height: 180,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppConstants.primaryColor,
            Color(0xFF4C47CC),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to FinTech Bridge',
            style: TextStyle(
              color: AppConstants.textColor,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Unable to load your profile. Please try again later.',
            style: TextStyle(
              color: AppConstants.textSecondaryColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String fullName) {
    if (fullName.isEmpty) return '';
    
    final nameParts = fullName.trim().split(' ');
    if (nameParts.isEmpty) return '';
    
    if (nameParts.length == 1) {
      return nameParts[0][0].toUpperCase();
    }
    
    return '${nameParts[0][0]}${nameParts[nameParts.length - 1][0]}'.toUpperCase();
  }
}