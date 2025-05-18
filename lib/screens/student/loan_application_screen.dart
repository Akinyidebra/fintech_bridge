import 'dart:math';

import 'package:fintech_bridge/models/provider_model.dart' as model;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fintech_bridge/services/loan_service.dart';
import 'package:fintech_bridge/utils/constants.dart';

class LoanApplicationScreen extends StatefulWidget {
  final String loanType;
  // Make provider optional
  final model.Provider provider;

  const LoanApplicationScreen({
    super.key,
    required this.loanType,
    required this.provider,
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
List<model.Provider> _providers = [];
  model.Provider? _selectedProvider;

  @override
  void initState() {
    super.initState();
    _termController.text = '12 months';
    _amountController.text = '5000';
    _loanService = Provider.of<LoanService>(context, listen: false);
    _loadProviders();
  }

  Future<void> _loadProviders() async {
    try {
      final providers = await _loanService.getApprovedProviders();
      setState(() {
        _providers = providers;
        if (widget.provider != null) {
          _selectedProvider = providers.firstWhere(
            (p) => p.id == widget.provider!.id,
            orElse: () => providers.first,
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading providers: ${e.toString()}')),
      );
    }
  }

  Widget _buildProviderCard(model.Provider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(provider.businessName,
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text(provider.businessType),
            SizedBox(height: 8),
            Text('Interest Rate: ${provider.interestRate}%'),
            Text('Loan Types: ${provider.loanTypes.join(', ')}'),
            if (provider.website != null)
              Text('Website: ${provider.website}'),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Loan Provider', style: AppConstants.headlineSmall),
        SizedBox(height: 16),
        DropdownButtonFormField<model.Provider>(
          value: _selectedProvider,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Select a provider',
          ),
          items: _providers.map((provider) {
            return DropdownMenuItem<model.Provider>(
              value: provider,
              child: Text(provider.businessName),
            );
          }).toList(),
          onChanged: (provider) {
            setState(() {
              _selectedProvider = provider;
              _selectedLoanType = null;
            });
          },
          validator: (value) =>
              value == null ? 'Please select a provider' : null,
        ),
        SizedBox(height: 20),
        if (_selectedProvider != null) ...[
          _buildProviderCard(_selectedProvider!),
          SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: _selectedLoanType,
            decoration: InputDecoration(
              labelText: 'Loan Type',
              border: OutlineInputBorder(),
            ),
            items: _selectedProvider!.loanTypes.map((type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: (type) => setState(() => _selectedLoanType = type),
            validator: (value) =>
                value == null ? 'Please select a loan type' : null,
          ),
        ],
      ],
    );
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
                _buildProviderDropdown(),
                      _buildTextField(
                        controller: _amountController,
                        label: 'Loan Amount',
                        icon: Icons.attach_money_rounded,
                        hint: '5,000',
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Loan Purpose',
                        style: TextStyle(
                          color: AppConstants.textSecondaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppConstants.backgroundSecondaryColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.1),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedPurpose,
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppConstants.primaryColor,
                            ),
                            iconSize: 24,
                            elevation: 0,
                            style: const TextStyle(
                              color: AppConstants.textColor,
                              fontSize: 16,
                              fontFamily: 'Poppins',
                            ),
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedPurpose = newValue!;
                              });
                            },
                            items: _loanPurposes.map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              },
                            ).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _termController,
                        label: 'Loan Term',
                        icon: Icons.calendar_today_rounded,
                        readOnly: true,
                        onTap: () {
                          _showTermOptions(context);
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _purposeController,
                        decoration: InputDecoration(
                          labelText: 'Additional Details',
                          hintText:
                          'Tell us more about how you plan to use this loan',
                          labelStyle: const TextStyle(
                            color: AppConstants.textSecondaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins',
                          ),
                          hintStyle: TextStyle(
                            color: AppConstants.textSecondaryColor
                                .withOpacity(0.5),
                            fontSize: 14,
                            fontFamily: 'Poppins',
                          ),
                          filled: true,
                          fillColor: AppConstants.backgroundSecondaryColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(
                            Icons.description_rounded,
                            color: AppConstants.primaryColor,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 16,
                          ),
                        ),
                        maxLines: 3,
                        validator: (value) =>
                        value!.isEmpty ? 'Required' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildTermSection(),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: AppConstants.cardGradient,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppConstants.primaryColor.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => _submitApplication(loanService),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Submit Application',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppConstants.textSecondaryColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppConstants.textSecondaryColor.withOpacity(0.5),
              fontSize: 14,
              fontFamily: 'Poppins',
            ),
            filled: true,
            fillColor: AppConstants.backgroundSecondaryColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            prefixIcon: Icon(
              icon,
              color: AppConstants.primaryColor,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
          ),
          keyboardType: icon == Icons.attach_money_rounded
              ? TextInputType.number
              : TextInputType.text,
          validator: (value) => value!.isEmpty ? 'Required' : null,
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'Poppins',
            color: AppConstants.textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTermSection() {
    return Container(
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
          const Text(
            'Terms & Conditions',
            style: TextStyle(
              color: AppConstants.textColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          _buildTermItem(
            'By submitting this application, you agree to our terms and conditions.',
          ),
          _buildTermItem(
            'We will review your application within 2 business days.',
          ),
          _buildTermItem(
            'You will receive updates on your application status via email.',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppConstants.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  color: AppConstants.successColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Flexible(
                child: Text(
                  'Your data is secured with 256-bit encryption',
                  style: TextStyle(
                    color: AppConstants.textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTermItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.check,
                color: AppConstants.primaryColor,
                size: 10,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppConstants.textSecondaryColor,
                fontSize: 13,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTermOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
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
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Select Loan Term',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 16),
            _buildTermOption('6 months'),
            _buildTermOption('12 months'),
            _buildTermOption('24 months'),
            _buildTermOption('36 months'),
            _buildTermOption('48 months'),
            _buildTermOption('60 months'),
          ],
        ),
      ),
    );
  }

  Widget _buildTermOption(String term) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _termController.text = term;
        });
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.withOpacity(0.2),
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
    if (_formKey.currentState!.validate() && _selectedProvider != null) {
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
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

      try {
        // Get provider data - use widget.provider if available, otherwise use dummy data
        final providerId = widget.provider?.id ?? _dummyProvider['id'] as String;
        final interestRate = widget.provider?.interestRate ?? _dummyProvider['interestRate'] as double;

        // Parse loan amount - handle comma in the input
        final amountText = _amountController.text.replaceAll(',', '');
        final amount = double.tryParse(amountText) ?? 0.0;

        if (amount <= 0) {
          // Close loading dialog and show error
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter a valid loan amount'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Parse term months
        final termMonths = int.parse(_termController.text.replaceAll(' months', ''));

        // Calculate monthly payment
        final monthlyPayment = _calculateMonthlyPayment(
          amount: amount,
          interestRate: interestRate,
          termMonths: termMonths,
        );

        // Submit loan request
        final result = await loanService.createLoanRequest(
          'providerId': _selectedProvider!.id,
        'loanType': _selectedLoanType,
        'interestRate': _selectedProvider!.interestRate,
        'businessName': _selectedProvider!.businessName,
          amount: amount,
          interestRate: interestRate,
          termMonths: termMonths,
          monthlyPayment: monthlyPayment,
          purpose: '$_selectedPurpose: ${_purposeController.text}',
          dueDate: DateTime.now().add(const Duration(days: 90)),
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
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        // Handle errors
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
}