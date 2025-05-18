import 'package:fintech_bridge/utils/constants.dart';
import 'package:flutter/material.dart';

class EmptySectionWidget extends StatelessWidget {
  final String message;

  const EmptySectionWidget({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppConstants.backgroundSecondaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(Icons.info_outline, color: AppConstants.textSecondaryColor),
          const SizedBox(height: 12),
          Text(
            message,
            style: AppConstants.bodyMediumSecondary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}