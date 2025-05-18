import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fintech_bridge/utils/constants.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? hint;
  final bool obscureText;
  final TextInputType keyboardType;
  final FormFieldValidator<String>? validator;
  final bool readOnly;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.readOnly = false,
    this.onTap,
    this.inputFormatters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppConstants.textSecondaryColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
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
            prefixIcon: Icon(
              icon,
              color: AppConstants.primaryColor,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
          ),
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'Poppins',
            color: AppConstants.textColor,
          ),
          validator: validator ?? (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            return null;
          },
        ),
      ],
    );
  }
}