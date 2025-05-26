import 'package:flutter/material.dart';
import 'package:fintech_bridge/utils/constants.dart';

class LoadingDialog extends StatelessWidget {
  final String message;
  
  const LoadingDialog({
    super.key,
    this.message = 'Processing your application...',
  });

  static void show(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return LoadingDialog(
          message: message ?? 'Processing your application...',
        );
      },
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: AppConstants.primaryColor,
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                color: AppConstants.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}