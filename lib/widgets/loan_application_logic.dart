import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fintech_bridge/services/loan_service.dart';
import 'package:fintech_bridge/utils/constants.dart';
import 'package:fintech_bridge/widgets/loading_dialog.dart';
import 'package:fintech_bridge/models/provider_model.dart' as provider_model;

class LoanApplicationLogic {
  static Future<void> submitApplication({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required TextEditingController amountController,
    required TextEditingController termController,
    required TextEditingController purposeController,
    required String selectedPurpose,
    required provider_model.Provider? selectedProvider,
    required String? selectedLoanType,
    required LoanService loanService,
  }) async {
    if (!formKey.currentState!.validate() ||
        selectedProvider == null ||
        selectedLoanType == null) {
      _showSnackBar(
        context,
        'Please fill in all required fields',
        AppConstants.accentColor,
      );
      return;
    }

    // Parse loan amount
    final amountText = amountController.text.replaceAll(',', '');
    final amount = double.tryParse(amountText) ?? 0.0;

    if (amount <= 0) {
      _showSnackBar(
        context,
        'Please enter a valid loan amount',
        AppConstants.accentColor,
      );
      return;
    }

    try {
      // Check eligibility
      final eligibilityCheck = await loanService.checkLoanEligibility(
        requestedAmount: amount,
        providerId: selectedProvider.id,
      );

      final bool isEligible = eligibilityCheck['eligible'] ?? false;
      final String message = eligibilityCheck['message'] ?? 'Eligibility check failed';

      if (!isEligible) {
        _showSnackBar(context, message, AppConstants.accentColor);
        return;
      }

      // Show loading dialog
      if (context.mounted) {
        LoadingDialog.show(context);
      }

      // Parse term months
      final termMonths = int.parse(termController.text.replaceAll(' months', ''));

      // Calculate monthly payment
      final monthlyPayment = _calculateMonthlyPayment(
        amount: amount,
        interestRate: selectedProvider.interestRate,
        termMonths: termMonths,
      );

      // Get student data
      final student = await loanService.getCurrentStudent();

      // Submit loan request
      final result = await loanService.createLoanRequest(
        providerId: selectedProvider.id,
        providerName: selectedProvider.businessName,
        loanType: selectedLoanType,
        institutionName: student['institutionName'] ?? 'Unknown Institution',
        mpesaPhone: student['mpesaPhone'] ?? '',
        amount: amount,
        interestRate: selectedProvider.interestRate,
        termMonths: termMonths,
        monthlyPayment: monthlyPayment,
        purpose: '$selectedPurpose: ${purposeController.text}',
        dueDate: DateTime.now().add(const Duration(days: 90)),
        repaymentMethod: 'M-PESA',
        repaymentStartDate: DateTime.now(),
      );

      // Hide loading dialog
      if (context.mounted) {
        LoadingDialog.hide(context);

        final bool success = result['success'] ?? false;
        final String resultMessage = result['message'] ?? 'Unknown error occurred';

        if (success) {
          // Navigate back and show success
          Navigator.pop(context);
          _showSnackBar(context, resultMessage, Colors.green);
        } else {
          _showSnackBar(context, resultMessage, AppConstants.accentColor);
        }
      }
    } catch (e) {
      // Handle errors
      if (context.mounted) {
        LoadingDialog.hide(context);
        _showSnackBar(
          context,
          'Error: ${e.toString()}',
          AppConstants.accentColor,
        );
      }
    }
  }

  static double _calculateMonthlyPayment({
    required double amount,
    required double interestRate,
    required int termMonths,
  }) {
    if (interestRate == 0) {
      return amount / termMonths;
    }

    final monthlyRate = interestRate / 100 / 12;
    final numerator = monthlyRate * pow(1 + monthlyRate, termMonths);
    final denominator = pow(1 + monthlyRate, termMonths) - 1;
    return amount * (numerator / denominator);
  }

  static void _showSnackBar(BuildContext context, String message, Color backgroundColor) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
        ),
      );
    }
  }
}