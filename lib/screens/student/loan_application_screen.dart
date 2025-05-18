import 'package:fintech_bridge/models/provider_model.dart' as provider_model;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fintech_bridge/services/loan_service.dart';
import 'package:fintech_bridge/utils/constants.dart';
import 'package:fintech_bridge/widgets/loan_provider_selector.dart';
import 'package:fintech_bridge/widgets/loan_details_form.dart';
import 'package:fintech_bridge/widgets/terms_section.dart';
import 'package:fintech_bridge/widgets/gradient_button.dart';
import 'dart:math';

class LoanApplicationScreen extends StatefulWidget {
  final String loanType;
  // Make provider optional
  final provider_model.Provider? provider;

  const LoanApplicationScreen({
    super.key,
    required this.loanType,
    this.provider,
  });

  @override
  State<LoanApplicationScreen> createState() => _LoanApplicationScreenState();
}

class _LoanApplicationScreenState extends State<LoanApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _purposeController = TextEditingController();
  final _termController = TextEditingController();
  String _selectedPurpose = 'Education';
  List<provider_model.Provider> _providers = [];
  provider_model.Provider? _selectedProvider;
  String? _selectedLoanType;
  late LoanService _loanService;

  @override
  void initState() {
    super.initState();
    _termController.text = '12 months';
    _amountController.text = '5000';
    _loanService = Provider.of<LoanService>(context, listen: false);
    _loadProviders();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _purposeController.dispose();
    _termController.dispose();
    super.dispose();
  }

  Future<void> _loadProviders() async {
    try {
      final providers = await _loanService.getApprovedProviders();
      setState(() {
        _providers = providers;
        if (widget.provider != null) {
          _selectedProvider = providers.firstWhere(
            (p) => p.id == widget.provider!.id,
            orElse: () => providers.isNotEmpty ? providers.first : null!,
          );
        } else {
          _selectedProvider = providers.isNotEmpty ? providers.first : null;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading providers: ${e.toString()}'),
          backgroundColor: AppConstants.accentColor,
        ),
      );
    }
  }

  void _showTermOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: AppConstants.textSecondaryColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Select Loan Term',
              style: AppConstants.headlineSmall,
            ),
            const SizedBox(height: 16),
            ...[6, 12, 24, 36, 48, 60].map(
              (months) => _buildTermOption('$months months'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermOption(String term) {
    return InkWell(
      onTap: () {
        setState(() {
          _termController.text = term;
        });
        Navigator.pop(context);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppConstants.textSecondaryColor.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              term,
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'Poppins',
                color: AppConstants.textColor,
              ),
            ),
            _termController.text == term
                ? const Icon(
                    Icons.check_circle_rounded,
                    color: AppConstants.primaryColor,
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  void _submitApplication(LoanService loanService) async {
    if (_formKey.currentState!.validate() &&
        _selectedProvider != null &&
        _selectedLoanType != null) {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: AppConstants.primaryColor,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Processing your application...',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      color: AppConstants.textColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

      try {
        // Parse loan amount - handle comma in the input
        final amountText = _amountController.text.replaceAll(',', '');
        final amount = double.tryParse(amountText) ?? 0.0;

        if (amount <= 0) {
          // Close loading dialog and show error
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter a valid loan amount'),
              backgroundColor: AppConstants.accentColor,
            ),
          );
          return;
        }

        // Parse term months
        final termMonths =
            int.parse(_termController.text.replaceAll(' months', ''));

        // Calculate monthly payment
        final monthlyPayment = _calculateMonthlyPayment(
          amount: amount,
          interestRate: _selectedProvider!.interestRate,
          termMonths: termMonths,
        );

        // Get student data from context or a service
        // This is a placeholder - you'll need to replace with actual student retrieval
        final student = await _loanService.getCurrentStudent();

        // Submit loan request
        final result = await loanService.createLoanRequest(
          providerId: _selectedProvider!.id,
          providerName: _selectedProvider!.businessName,
          loanType: _selectedLoanType!,
          institutionName: student.institutionName,
          mpesaPhone: student.mpesaPhone,
          amount: amount,
          interestRate: _selectedProvider!.interestRate,
          termMonths: termMonths,
          monthlyPayment: monthlyPayment,
          purpose: '$_selectedPurpose: ${_purposeController.text}',
          dueDate: DateTime.now().add(const Duration(days: 90)),
          repaymentMethod: 'M-PESA', // Default repayment method since it's not in the Provider model
          repaymentStartDate: DateTime.now(),
        );

        // Close loading dialog
        Navigator.pop(context);

        if (result['success']) {
          // Show success and go back
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          // Show error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: AppConstants.accentColor,
            ),
          );
        }
      } catch (e) {
        // Handle errors
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppConstants.accentColor,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: AppConstants.accentColor,
        ),
      );
    }
  }

  double _calculateMonthlyPayment({
    required double amount,
    required double interestRate,
    required int termMonths,
  }) {
    final monthlyRate = interestRate / 100 / 12;
    final numerator = monthlyRate * pow(1 + monthlyRate, termMonths);
    final denominator = pow(1 + monthlyRate, termMonths) - 1;
    return amount * (numerator / denominator);
  }

  @override
  Widget build(BuildContext context) {
    final loanService = Provider.of<LoanService>(context);

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            SizedBox(
              height: 24,
              child: Image.asset(
                'assets/icons/logo.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 10),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Fin',
                    style: AppConstants.titleLarge.copyWith(
                      color: AppConstants.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  TextSpan(
                    text: 'Tech Bridge',
                    style: AppConstants.titleLarge.copyWith(
                      color: AppConstants.accentColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppConstants.primaryColor,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                child: CircleAvatar(
                  radius: 14,
                  backgroundImage:
                      NetworkImage('https://i.pravatar.cc/150?img=5'),
                ),
              ),
            ),
          ),
        ],
      ),
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
                Container(
                  width: double.infinity,
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
                          const Icon(
                            Icons.account_balance_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              'Apply for ${widget.loanType}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                widget.loanType == 'Student Plus Loan'
                                    ? 'Fixed Rate 4.5% APR, No origination fees'
                                    : 'Variable Rate from 3.2% APR, Flexible repayment options',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 13,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'Loan Details',
                  style: AppConstants.headlineSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),

                // Loan Details Form Section
                Container(
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
                      // Provider Selector Component
                      LoanProviderSelector(
                        providers: _providers,
                        selectedProvider: _selectedProvider,
                        selectedLoanType: _selectedLoanType,
                        onProviderChanged: (provider) {
                          setState(() {
                            _selectedProvider = provider;
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
                        onTermTap: () => _showTermOptions(context),
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
                  onPressed: () => _submitApplication(loanService),
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