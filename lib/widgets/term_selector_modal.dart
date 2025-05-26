import 'package:flutter/material.dart';
import 'package:fintech_bridge/utils/constants.dart';

class TermSelectorModal extends StatelessWidget {
  final String currentSelection;
  final Function(String) onTermSelected;
  
  const TermSelectorModal({
    super.key,
    required this.currentSelection,
    required this.onTermSelected,
  });

  static void show(
    BuildContext context, {
    required String currentSelection,
    required Function(String) onTermSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => TermSelectorModal(
        currentSelection: currentSelection,
        onTermSelected: onTermSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
              color: AppConstants.textSecondaryColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Select Loan Term',
            style: AppConstants.headlineSmall,
          ),
          const SizedBox(height: 16),
          ...[6, 12, 24, 36, 48, 60].map(
            (months) => _buildTermOption('$months months', context),
          ),
        ],
      ),
    );
  }

  Widget _buildTermOption(String term, BuildContext context) {
    return InkWell(
      onTap: () {
        onTermSelected(term);
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
            currentSelection == term
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
}