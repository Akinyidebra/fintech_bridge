import 'package:fintech_bridge/models/provider_model.dart' as provider_model;
import 'package:fintech_bridge/screens/loading_screen.dart';
import 'package:fintech_bridge/widgets/admin_provider_action_buttons.dart';
import 'package:fintech_bridge/widgets/admin_provider_detail_section.dart';
import 'package:fintech_bridge/widgets/admin_provider_header_card.dart';
import 'package:fintech_bridge/widgets/admin_provider_summary_card.dart';
import 'package:fintech_bridge/widgets/admin_provider_verification_modal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fintech_bridge/services/database_service.dart';
import 'package:fintech_bridge/utils/constants.dart';

class AdminProviderDetailsContent extends StatefulWidget {
  final String providerId;

  const AdminProviderDetailsContent({super.key, required this.providerId});

  @override
  State<AdminProviderDetailsContent> createState() => _AdminProviderDetailsContentState();
}

class _AdminProviderDetailsContentState extends State<AdminProviderDetailsContent> {
  bool _isLoading = true;
  String? _errorMessage;
  provider_model.Provider? _provider;

  @override
  void initState() {
    super.initState();
    _loadProviderData();
  }

  Future<void> _loadProviderData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dbService = Provider.of<DatabaseService>(context, listen: false);
      final result = await dbService.getProviderById(widget.providerId);

      if (result['success']) {
        setState(() {
          _provider = result['data'] as provider_model.Provider;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Provider not found';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading provider: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadProviderData();
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen while data is being fetched
    if (_isLoading) {
      return const LoadingScreen(
        message: 'Loading provider details...',
        isFullScreen: false,
      );
    }

    // Show error state with retry option
    if (_errorMessage != null || _provider == null) {
      return _buildErrorState();
    }

    final registrationDays = DateTime.now().difference(_provider!.createdAt).inDays;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminProvidersHeaderCard(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AdminProviderSummaryCard(
                  provider: _provider!, 
                  registrationDays: registrationDays,
                ),
                const SizedBox(height: 24),
                AdminProviderDetailSection(provider: _provider!),
                const SizedBox(height: 24),
                AdminProviderActionButtons(
                  provider: _provider!,
                  onVerifyProvider: () => _showVerificationModal(context),
                  onEditProvider: () => _editProvider(),
                  onRefresh: _refreshData,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppConstants.backgroundSecondaryColor.withOpacity(0.8),
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
              child: const Icon(
                Icons.error_outline,
                size: 56,
                color: AppConstants.errorColor,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Something went wrong',
              style: AppConstants.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Provider not found',
              style: AppConstants.bodyMedium.copyWith(
                color: AppConstants.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _refreshData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Try Again',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppConstants.primaryColor,
                    side: const BorderSide(color: AppConstants.primaryColor),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Back to Providers',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showVerificationModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AdminProviderVerificationModal(
        provider: _provider!,
        onVerificationSuccess: () {
          _refreshData();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_provider!.verified 
                ? 'Provider unverified successfully!' 
                : 'Provider verified successfully!'),
              backgroundColor: AppConstants.successColor,
            ),
          );
        },
        onVerificationError: (message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: AppConstants.errorColor,
            ),
          );
        },
      ),
    );
  }

  void _editProvider() {
    // Implement edit provider logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Provider editing will be available soon'),
        backgroundColor: AppConstants.primaryColor,
      ),
    );
  }
}