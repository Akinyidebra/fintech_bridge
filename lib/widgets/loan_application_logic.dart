import 'dart:math';
import 'package:fintech_bridge/screens/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:fintech_bridge/services/loan_service.dart';
import 'package:fintech_bridge/utils/constants.dart';
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
    // Early validation - don't show loading if validation fails
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

    // Store the initial context mounted state
    if (!context.mounted) return;

    bool loadingShown = false;

    try {
      // Check eligibility first
      final eligibilityCheck = await loanService.checkLoanEligibility(
        requestedAmount: amount,
        providerId: selectedProvider.id,
      );

      final bool isEligible = eligibilityCheck['eligible'] ?? false;
      final String message = eligibilityCheck['message'] ?? 'Eligibility check failed';

      if (!isEligible) {
        if (context.mounted) {
          _showSnackBar(context, message, AppConstants.accentColor);
        }
        return;
      }

      // Show loading overlay ONLY after eligibility check passes
      if (context.mounted) {
        LoadingOverlay.show(context, message: 'Processing your loan application...');
        loadingShown = true;
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

      // Always hide loading first, regardless of result
      if (loadingShown) {
        LoadingOverlay.hide();
        loadingShown = false;
        // Give a small delay to ensure overlay is removed
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // Process result only if context is still valid
      if (context.mounted) {
        final bool success = result['success'] ?? false;
        final String resultMessage = result['message'] ?? 'Unknown error occurred';

        if (success) {
          // Show success message
          _showSnackBar(context, resultMessage, Colors.green);
          
          // Wait a bit longer for snackbar to be visible before navigation
          await Future.delayed(const Duration(milliseconds: 800));
          
          // Navigate back only if context is still mounted
          if (context.mounted && Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        } else {
          _showSnackBar(context, resultMessage, AppConstants.accentColor);
        }
      }

    } catch (e) {
      // Critical: Always hide loading in catch block
      if (loadingShown) {
        LoadingOverlay.hide();
        loadingShown = false;
      }
      
      // Handle errors with context check
      if (context.mounted) {
        _showSnackBar(
          context,
          'Application failed. Please try again.',
          AppConstants.accentColor,
        );
      }
      
      // Log the error for debugging
      debugPrint('Loan application error: ${e.toString()}');
    } finally {
      // Final safety net - ensure loading is hidden
      if (loadingShown) {
        LoadingOverlay.hide();
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
          content: Text(
            message,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: backgroundColor,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }
}