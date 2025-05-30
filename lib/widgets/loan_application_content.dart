// ignore_for_file: null_check_always_fails

import 'package:fintech_bridge/models/provider_model.dart' as provider_model;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fintech_bridge/services/loan_service.dart';
import 'package:fintech_bridge/utils/constants.dart';
import 'package:fintech_bridge/widgets/loan_provider_selector.dart';
import 'package:fintech_bridge/widgets/loan_details_form.dart';
import 'package:fintech_bridge/widgets/terms_section.dart';
import 'package:fintech_bridge/widgets/gradient_button.dart';
import 'package:fintech_bridge/widgets/loan_application_header_card.dart';
import 'package:fintech_bridge/widgets/loan_form_container.dart';
import 'package:fintech_bridge/widgets/term_selector_modal.dart';
import 'package:fintech_bridge/widgets/loan_application_logic.dart';
import 'package:fintech_bridge/widgets/provider_loader_mixin.dart';
import 'package:fintech_bridge/screens/loading_screen.dart';

class LoanApplicationContent extends StatefulWidget {
  final String loanType;
  final provider_model.Provider? provider;

  const LoanApplicationContent({
    super.key,
    required this.loanType,
    this.provider,
  });

  @override
  State<LoanApplicationContent> createState() => _LoanApplicationContentState();
}

class _LoanApplicationContentState extends State<LoanApplicationContent>
    with ProviderLoaderMixin {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _purposeController = TextEditingController();
  final _termController = TextEditingController();
  String _selectedPurpose = 'Education';
  String? _selectedLoanType;
  late LoanService _loanService;

  // Centralized loading and error states
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeFields();
    _loanService = Provider.of<LoanService>(context, listen: false);
    _loadAllData();
  }

  void _initializeFields() {
    _termController.text = '6 months';
    _amountController.text = '100';
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load providers using the mixin but integrate with centralized loading
      await _loadProvidersWithCentralizedState();

      // Add any other data loading here if needed in the future
      // For example: await _loadUserPreferences();
      // await _loadLoanHistory();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load application data: ${e.toString()}';
        });
      }
      print('Loan application loading error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadProvidersWithCentralizedState() async {
    try {
      final loadedProviders = await _loanService.getApprovedProviders();

      if (!mounted) return;

      setState(() {
        providers = loadedProviders;

        if (widget.provider != null) {
          selectedProvider = providers.firstWhere(
            (p) => p.id == widget.provider!.id,
            orElse: () => providers.isNotEmpty
                ? providers.first
                : throw Exception('No providers found'),
          );
        } else {
          selectedProvider = providers.isNotEmpty ? providers.first : null;
        }
      });
    } catch (e) {
      throw Exception('Error loading providers: ${e.toString()}');
    }
  }

  Future<void> _refreshData() async {
    await _loadAllData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _purposeController.dispose();
    _termController.dispose();
    super.dispose();
  }

  void _showTermOptions() {
    TermSelectorModal.show(
      context,
      currentSelection: _termController.text,
      onTermSelected: (term) {
        setState(() {
          _termController.text = term;
        });
      },
    );
  }

  void _submitApplication() {
    LoanApplicationLogic.submitApplication(
      context: context,
      formKey: _formKey,
      amountController: _amountController,
      termController: _termController,
      purposeController: _purposeController,
      selectedPurpose: _selectedPurpose,
      selectedProvider: selectedProvider,
      selectedLoanType: _selectedLoanType,
      loanService: _loanService,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen while data is being fetched
    if (_isLoading) {
      return const LoadingScreen(
        message: 'Preparing loan application...',
        isFullScreen: false,
      );
    }

    // Show error state with retry option
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

    // Return the form content
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Loan Header Card
              const LoanApplicationHeaderCard(),
              const SizedBox(height: 24),

              const Text(
                'Loan Details',
                style: AppConstants.headlineSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),

              // Loan Details Form Section
              LoanFormContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Provider Selector Component - No individual loading spinner needed
                    LoanProviderSelector(
                      providers: providers,
                      selectedProvider: selectedProvider,
                      selectedLoanType: _selectedLoanType,
                      onProviderChanged: (provider) {
                        updateSelectedProvider(provider);
                        setState(() {
                          _selectedLoanType = null;
                        });
                      },
                      onLoanTypeChanged: (type) {
                        setState(() {
                          _selectedLoanType = type;
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    // Loan Details Form Component
                    LoanDetailsForm(
                      amountController: _amountController,
                      termController: _termController,
                      purposeController: _purposeController,
                      selectedPurpose: _selectedPurpose,
                      onPurposeChanged: (value) {
                        setState(() {
                          _selectedPurpose = value;
                        });
                      },
                      onTermTap: _showTermOptions,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Terms Section Component
              const TermsSection(),

              const SizedBox(height: 24),

              // Submit Button
              GradientButton(
                text: 'Submit Application',
                onPressed: _submitApplication,
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
