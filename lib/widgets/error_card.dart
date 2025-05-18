import 'package:fintech_bridge/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ErrorCardWidget extends StatelessWidget {
  final String message;

  const ErrorCardWidget({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isConnectionError = _isConnectionError(message);
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(Icons.wifi_off, color: AppConstants.errorColor),
          const SizedBox(height: 12),
          Text(
            isConnectionError
                ? 'No internet connection\nPlease check your network'
                : 'Error: $message',
            style: const TextStyle(color: AppConstants.errorColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  bool _isConnectionError(dynamic error) {
    return error is FirebaseException &&
        ['unavailable', 'network-error'].contains(error.code);
  }
}