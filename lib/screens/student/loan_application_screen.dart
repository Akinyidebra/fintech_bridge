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
import 'package:fintech_bridge/widgets/loan_header_card.dart';
import 'package:fintech_bridge/widgets/loan_form_container.dart';
import 'package:fintech_bridge/widgets/term_selector_modal.dart';
import 'package:fintech_bridge/widgets/loan_application_logic.dart';
import 'package:fintech_bridge/widgets/provider_loader_mixin.dart';

class LoanApplicationScreen extends StatefulWidget {
  final String loanType;
  final provider_model.Provider? provider;

  const LoanApplicationScreen({
    super.key,
    required this.loanType,
    this.provider,
  });

  @override
  State<LoanApplicationScreen> createState() => _LoanApplicationScreenState();
}

class _LoanApplicationScreenState extends State<LoanApplicationScreen>
    with ProviderLoaderMixin {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _purposeController = TextEditingController();
  final _termController = TextEditingController();
  String _selectedPurpose = 'Education';
  String? _selectedLoanType;
  late LoanService _loanService;

  @override
  void initState() {
    super.initState();
    _initializeFields();
    _loanService = Provider.of<LoanService>(context, listen: false);
    loadProviders(_loanService, initialProvider: widget.provider);
  }

  void _initializeFields() {
    _termController.text = '12 months';
    _amountController.text = '5000';
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
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Loan Header Card
                LoanHeaderCard(loanType: widget.loanType),
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
                      // Provider Selector Component
                      if (isLoadingProviders)
                        const Center(
                          child: CircularProgressIndicator(
                            color: AppConstants.primaryColor,
                          ),
                        )
                      else
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
      ),
    );
  }
}