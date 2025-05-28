import 'package:flutter/material.dart';
import 'dart:io';
import 'package:fintech_bridge/utils/constants.dart';
import 'package:fintech_bridge/widgets/document_section.dart';

class DocumentsTab extends StatelessWidget {
  final File? nationalIdFront;
  final File? nationalIdBack;
  final File? studentIdFront;
  final File? studentIdBack;
  final bool isUploadingImages;
  final Function(String) onPickImage;
  final VoidCallback onUploadDocuments;

  const DocumentsTab({
    super.key,
    required this.nationalIdFront,
    required this.nationalIdBack,
    required this.studentIdFront,
    required this.studentIdBack,
    required this.isUploadingImages,
    required this.onPickImage,
    required this.onUploadDocuments,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Identification Documents'),
          const SizedBox(height: 16),
          
          DocumentSection(
            title: 'National ID',
            icon: Icons.credit_card_rounded,
            frontImage: nationalIdFront,
            backImage: nationalIdBack,
            onPickFront: () => onPickImage('national_id_front'),
            onPickBack: () => onPickImage('national_id_back'),
          ),
          
          const SizedBox(height: 24),
          
          DocumentSection(
            title: 'Student ID',
            icon: Icons.school_rounded,
            frontImage: studentIdFront,
            backImage: studentIdBack,
            onPickFront: () => onPickImage('student_id_front'),
            onPickBack: () => onPickImage('student_id_back'),
          ),
          
          const SizedBox(height: 32),
          
          _buildUploadDocumentsButton(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppConstants.textColor,
        fontFamily: 'Poppins',
      ),
    );
  }

  Widget _buildUploadDocumentsButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isUploadingImages ? null : onUploadDocuments,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.secondaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isUploadingImages
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Upload Documents',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
      ),
    );
  }
}