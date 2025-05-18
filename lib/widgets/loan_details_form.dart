import 'package:flutter/material.dart';
import 'package:fintech_bridge/utils/constants.dart';
import 'package:fintech_bridge/widgets/custom_text_field.dart';

class LoanDetailsForm extends StatelessWidget {
  final TextEditingController amountController;
  final TextEditingController termController;
  final TextEditingController purposeController;
  final String selectedPurpose;
  final Function(String) onPurposeChanged;
  final VoidCallback onTermTap;

  // Define loan purposes (moved from the main class)
  final List<String> _loanPurposes = [
    'Education',
    'Medical Expenses',
    'Business',
    'Home Improvement',
    'Debt Consolidation',
    'Travel',
    'Other'
  ];

  LoanDetailsForm({
    super.key,
    required this.amountController,
    required this.termController,
    required this.purposeController,
    required this.selectedPurpose,
    required this.onPurposeChanged,
    required this.onTermTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Loan Amount Field
        CustomTextField(
          controller: amountController,
          label: 'Loan Amount',
          icon: Icons.attach_money_rounded,
          hint: '5,000',
          keyboardType: TextInputType.number,
        ),
        
        const SizedBox(height: 20),
        
        // Loan Purpose Dropdown
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  color: AppConstants.textSecondaryColor.withOpacity(0.1),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: selectedPurpose,
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
                    if (newValue != null) {
                      onPurposeChanged(newValue);
                    }
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
          ],
        ),
        
        const SizedBox(height: 20),
        
        // Loan Term Field
        CustomTextField(
          controller: termController,
          label: 'Loan Term',
          icon: Icons.calendar_today_rounded,
          readOnly: true,
          onTap: onTermTap,
        ),
        
        const SizedBox(height: 20),
        
        // Additional Details
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Additional Details',
              style: TextStyle(
                color: AppConstants.textSecondaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: purposeController,
              decoration: InputDecoration(
                hintText: 'Tell us more about how you plan to use this loan',
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
              style: const TextStyle(
                color: AppConstants.textColor,
                fontFamily: 'Poppins',
              ),
              validator: (value) => value!.isEmpty ? 'Required' : null,
            ),
          ],
        ),
      ],
    );
  }
}