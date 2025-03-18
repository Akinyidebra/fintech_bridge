import 'package:flutter/material.dart';

class AppConstants {
  // Theme Colors
  static const Color primaryColor = Color(0xFF1A2980);
  static const Color secondaryColor = Color(0xFFE0E0E0);
  static const Color accentColor = Color(0xFF808080);
  static const Color textPrimaryColor = Colors.black;
  static const Color textSecondaryColor = Color(0xFF757575);
  static const Color backgroundColor = Colors.white;

  // Text Styles
  static const TextStyle displaySmall = TextStyle(
    fontFamily: 'Inter Tight',
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: 'Inter Tight',
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: textPrimaryColor,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: 'Inter Tight',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    color: textPrimaryColor,
  );

  static const TextStyle bodyLargeSecondary = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    color: textSecondaryColor,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    color: textPrimaryColor,
  );

  static const TextStyle bodyMediumSecondary = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    color: textSecondaryColor,
  );

  // Button Style
  static final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    elevation: 2,
    minimumSize: const Size(double.infinity, 56),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(28),
    ),
    textStyle: titleMedium,
  );

  // Input Decoration
  static InputDecoration inputDecoration({
    required String labelText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: bodyMedium,
      hintStyle: bodyMedium,
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: secondaryColor,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: primaryColor,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: backgroundColor,
      prefixIcon: Icon(
        prefixIcon,
        color: accentColor,
      ),
      suffixIcon: suffixIcon,
    );
  }

  // Container Decoration
  static BoxDecoration containerDecoration = BoxDecoration(
    color: backgroundColor,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.2),
        spreadRadius: 1,
        blurRadius: 3,
        offset: const Offset(0, 2),
      ),
    ],
  );
}
