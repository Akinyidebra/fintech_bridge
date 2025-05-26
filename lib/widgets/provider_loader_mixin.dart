import 'package:flutter/material.dart';
import 'package:fintech_bridge/services/loan_service.dart';
import 'package:fintech_bridge/utils/constants.dart';
import 'package:fintech_bridge/models/provider_model.dart' as provider_model;

mixin ProviderLoaderMixin<T extends StatefulWidget> on State<T> {
  List<provider_model.Provider> providers = [];
  provider_model.Provider? selectedProvider;
  bool isLoadingProviders = false;

  Future<void> loadProviders(
    LoanService loanService, {
    provider_model.Provider? initialProvider,
  }) async {
    if (!mounted) return;
    
    setState(() {
      isLoadingProviders = true;
    });

    try {
      final loadedProviders = await loanService.getApprovedProviders();
      
      if (!mounted) return;
      
      setState(() {
        providers = loadedProviders;
        isLoadingProviders = false;
        
        if (initialProvider != null) {
          selectedProvider = providers.firstWhere(
            (p) => p.id == initialProvider.id,
            orElse: () => providers.isNotEmpty
                ? providers.first
                : throw Exception('No providers found'),
          );
        } else {
          selectedProvider = providers.isNotEmpty ? providers.first : null;
        }
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        isLoadingProviders = false;
      });
      
      _showProviderError(e.toString());
    }
  }

  void _showProviderError(String error) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading providers: $error'),
          backgroundColor: AppConstants.accentColor,
        ),
      );
    }
  }

  void updateSelectedProvider(provider_model.Provider? provider) {
    setState(() {
      selectedProvider = provider;
    });
  }
}