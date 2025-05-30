import 'package:fintech_bridge/models/provider_model.dart';
import 'package:fintech_bridge/utils/constants.dart';
import 'package:flutter/material.dart';

class ProviderWelcomeCard extends StatelessWidget {
  final Future<Map<String, dynamic>>? providerProfileFuture;
  final Map<String, int> loanStats;

  const ProviderWelcomeCard({
    super.key,
    required this.providerProfileFuture,
    required this.loanStats,
  });

  @override
  Widget build(BuildContext context) {
    // Handle null future case
    if (providerProfileFuture == null) {
      return _buildErrorCard();
    }

    return FutureBuilder<Map<String, dynamic>>(
      future: providerProfileFuture!,
      builder: (context, providerSnapshot) {
        if (providerSnapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard();
        }

        if (!providerSnapshot.hasData ||
            !(providerSnapshot.data?['success'] ?? false) ||
            providerSnapshot.data?['data'] == null) {
          return _buildErrorCard();
        }

        // Fix: Ensure we're casting the correct data structure
        final providerData = providerSnapshot.data!['data'];

        // Handle both direct Provider object and nested data structure
        Provider provider;
        if (providerData is Provider) {
          provider = providerData;
        } else {
          return _buildErrorCard();
        }

        return Container(
          width: double.infinity,
          constraints: const BoxConstraints(
            minHeight: 180,
            maxHeight: 200,
          ),
          padding: const EdgeInsets.all(20), // Reduced padding
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
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header row with better space management
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10), // Reduced padding
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.business_rounded,
                      color: Colors.white,
                      size: 24, // Reduced icon size
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Welcome back,',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12, // Reduced font size
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          provider.businessName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16, // Reduced font size
                            fontFamily: 'Poppins',
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                  // Status badge with white container background for visibility
                  Flexible(
                    child: Container(
                      // padding: const EdgeInsets.all(
                      //     14),
                      padding: const EdgeInsets.fromLTRB(
                          25, 10, 25, 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(19),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(provider.verified)
                              .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _getStatusColor(provider.verified)
                                .withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _getStatusText(provider.verified),
                          style: TextStyle(
                            color: _getStatusColor(provider.verified),
                            fontSize: 10, // Reduced font size
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16), // Reduced spacing
              // Quick stats row with better responsiveness
              Flexible(
                child: Row(
                  children: [
                    Expanded(
                      child: _buildQuickStat(
                        'Active',
                        loanStats['active']?.toString() ?? '0',
                        Icons.trending_up_rounded,
                      ),
                    ),
                    const SizedBox(width: 12), // Reduced spacing
                    Expanded(
                      child: _buildQuickStat(
                        'Pending',
                        loanStats['pending']?.toString() ?? '0',
                        Icons.pending_actions_rounded,
                      ),
                    ),
                    const SizedBox(width: 12), // Reduced spacing
                    Expanded(
                      child: _buildQuickStat(
                        'Done',
                        loanStats['completed']?.toString() ?? '0',
                        Icons.check_circle_rounded,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickStat(String title, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.8),
          size: 20, // Reduced icon size
        ),
        const SizedBox(height: 4), // Reduced spacing
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18, // Reduced font size
            fontFamily: 'Poppins',
          ),
        ),
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 10, // Reduced font size
            fontFamily: 'Poppins',
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
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
      height: 180,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Welcome to FinTech Bridge',
            style: TextStyle(
              color: AppConstants.textColor,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          Flexible(
            child: Text(
              'Unable to load your provider profile. Please try again later.',
              style: TextStyle(
                color: AppConstants.textSecondaryColor,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(bool verified) {
    return verified ? Colors.green : Colors.orange;
  }

  String _getStatusText(bool verified) {
    return verified ? 'Verified' : 'Pending';
  }
}
