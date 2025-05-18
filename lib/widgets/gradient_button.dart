import 'package:flutter/material.dart';
import 'package:fintech_bridge/utils/constants.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double height;
  final double width;
  final double borderRadius;
  final bool isLoading;

  const GradientButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.height = 56,
    this.width = double.infinity,
    this.borderRadius = 16,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: AppConstants.accentGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Container(
            alignment: Alignment.center,
            child: isLoading
                ? const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  )
                : Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      fontFamily: 'Poppins',
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}