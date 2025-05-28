import 'package:flutter/material.dart';
import 'dart:io';
import 'package:fintech_bridge/utils/constants.dart';

class DocumentSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final File? frontImage;
  final File? backImage;
  final VoidCallback onPickFront;
  final VoidCallback onPickBack;

  const DocumentSection({
    super.key,
    required this.title,
    required this.icon,
    required this.frontImage,
    required this.backImage,
    required this.onPickFront,
    required this.onPickBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppConstants.textColor.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildImagePickerCard(
                  'Front Side',
                  frontImage,
                  onPickFront,
                  Icons.credit_card_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildImagePickerCard(
                  'Back Side',
                  backImage,
                  onPickBack,
                  Icons.credit_card_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppConstants.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppConstants.primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppConstants.textColor,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  Widget _buildImagePickerCard(
    String label,
    File? image,
    VoidCallback onTap,
    IconData placeholderIcon,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: image != null 
              ? Colors.transparent 
              : AppConstants.backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: image != null 
                ? AppConstants.primaryColor.withOpacity(0.3)
                : AppConstants.textColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: image != null ? _buildImagePreview(image) : _buildImagePlaceholder(label, placeholderIcon),
      ),
    );
  }

  Widget _buildImagePreview(File image) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: Image.file(
            image,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppConstants.successColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 12,
            ),
          ),
        ),
        Positioned(
          bottom: 4,
          left: 4,
          right: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Tap to change',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder(String label, IconData placeholderIcon) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          placeholderIcon,
          color: AppConstants.textColor.withOpacity(0.4),
          size: 32,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppConstants.textColor.withOpacity(0.6),
            fontFamily: 'Poppins',
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'Tap to upload',
          style: TextStyle(
            fontSize: 10,
            color: AppConstants.primaryColor.withOpacity(0.7),
            fontFamily: 'Poppins',
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}