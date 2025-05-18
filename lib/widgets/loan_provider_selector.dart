import 'package:flutter/material.dart';
import 'package:fintech_bridge/utils/constants.dart';
import 'package:fintech_bridge/models/provider_model.dart' as model;

class LoanProviderSelector extends StatelessWidget {
  final List<model.Provider> providers;
  final model.Provider? selectedProvider;
  final String? selectedLoanType;
  final Function(model.Provider) onProviderChanged;
  final Function(String) onLoanTypeChanged;

  const LoanProviderSelector({
    super.key,
    required this.providers,
    required this.selectedProvider,
    required this.selectedLoanType,
    required this.onProviderChanged,
    required this.onLoanTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Loan Provider', style: AppConstants.headlineSmall),
        const SizedBox(height: 16),
        DropdownButtonFormField<model.Provider>(
          value: selectedProvider,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            hintText: 'Select a provider',
            filled: true,
            fillColor: AppConstants.backgroundSecondaryColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          items: providers.map((provider) {
            return DropdownMenuItem<model.Provider>(
              value: provider,
              child: Text(
                provider.businessName,
                style: const TextStyle(
                  fontSize: 15,
                  fontFamily: 'Poppins',
                ),
              ),
            );
          }).toList(),
          onChanged: (provider) {
            if (provider != null) {
              onProviderChanged(provider);
            }
          },
          validator: (value) => value == null ? 'Please select a provider' : null,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppConstants.primaryColor,
          ),
        ),
        if (selectedProvider != null) ...[
          const SizedBox(height: 20),
          _buildProviderCard(selectedProvider!),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: selectedLoanType,
            decoration: InputDecoration(
              labelText: 'Loan Type',
              labelStyle: const TextStyle(
                color: AppConstants.textSecondaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              filled: true,
              fillColor: AppConstants.backgroundSecondaryColor,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            items: selectedProvider!.loanTypes.map((type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(
                  type,
                  style: const TextStyle(
                    fontSize: 15,
                    fontFamily: 'Poppins',
                  ),
                ),
              );
            }).toList(),
            onChanged: (type) {
              if (type != null) {
                onLoanTypeChanged(type);
              }
            },
            validator: (value) => value == null ? 'Please select a loan type' : null,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppConstants.primaryColor,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProviderCard(model.Provider provider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.business_center,
                    color: AppConstants.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.businessName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Text(
                        provider.businessType,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildProviderInfoItem(
              icon: Icons.percent,
              title: 'Interest Rate',
              value: '${provider.interestRate}%',
            ),
            const SizedBox(height: 8),
            _buildProviderInfoItem(
              icon: Icons.category,
              title: 'Loan Types',
              value: provider.loanTypes.join(', '),
            ),
            if (provider.website != null) ...[
              const SizedBox(height: 8),
              _buildProviderInfoItem(
                icon: Icons.language,
                title: 'Website',
                value: provider.website!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProviderInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: AppConstants.textSecondaryColor,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  fontFamily: 'Poppins',
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}