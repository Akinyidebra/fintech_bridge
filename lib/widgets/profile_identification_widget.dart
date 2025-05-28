import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fintech_bridge/utils/constants.dart';

class ProfileIdentificationSection extends StatelessWidget {
  final List<String> identificationImages;

  const ProfileIdentificationSection({
    super.key,
    required this.identificationImages,
  });

  @override
  Widget build(BuildContext context) {
    if (identificationImages.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(),
          const SizedBox(height: 16),
          _buildIdentificationGrid(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return const Row(
      children: [
        Icon(
          Icons.badge_rounded,
          color: AppConstants.accentColor,
          size: 22,
        ),
        SizedBox(width: 12),
        Text(
          'Identification Documents',
          style: AppConstants.headlineSmall,
        ),
      ],
    );
  }

  Widget _buildIdentificationGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemCount: identificationImages.length,
      itemBuilder: (context, index) {
        return _buildIdentificationCard(
          context,
          identificationImages[index],
          _getDocumentLabel(index),
          index,
        );
      },
    );
  }

  Widget _buildIdentificationCard(
      BuildContext context, String imageData, String label, int index) {
    return GestureDetector(
      onTap: () => _showImageDialog(context, imageData, label),
      child: Container(
        decoration: BoxDecoration(
          color: AppConstants.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppConstants.primaryColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  color: Colors.grey[100],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      _buildImage(imageData),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.zoom_in_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getDocumentIcon(index),
                        size: 16,
                        color: AppConstants.primaryColor,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          label,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppConstants.textColor,
                            fontFamily: 'Poppins',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tap to view',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppConstants.textColor.withOpacity(0.6),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String imageData) {
    final imageProvider = _getImageProvider(imageData);

    if (imageProvider != null) {
      return Image(
        image: imageProvider,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget();
        },
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) {
            return child;
          }
          return const Center(
            child: CircularProgressIndicator(
              color: AppConstants.primaryColor,
              strokeWidth: 2,
            ),
          );
        },
      );
    } else {
      return _buildErrorWidget();
    }
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_rounded,
            color: Colors.grey[400],
            size: 32,
          ),
          const SizedBox(height: 4),
          Text(
            'Failed to load',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[500],
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  ImageProvider? _getImageProvider(String imageData) {
    if (imageData.isEmpty) {
      return null;
    }

    try {
      // Handle both data URI scheme and plain base64
      String base64Data = imageData;
      if (base64Data.contains('base64,')) {
        base64Data = base64Data.split(',').last;
      }

      final bytes = base64Decode(base64Data);
      return MemoryImage(bytes);
    } catch (e) {
      // If base64 decoding fails, try as network image
      try {
        return NetworkImage(imageData);
      } catch (e) {
        // If both fail, return null to show error widget
        return null;
      }
    }
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppConstants.backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppConstants.primaryColor.withOpacity(0.2),
                width: 1,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.image_not_supported_rounded,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 12),
                Text(
                  'No identification documents uploaded',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppConstants.textColor.withOpacity(0.7),
                    fontFamily: 'Poppins',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Upload your National ID and Student ID for verification',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppConstants.textColor.withOpacity(0.5),
                    fontFamily: 'Poppins',
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getDocumentLabel(int index) {
    switch (index) {
      case 0:
        return 'National ID (Front)';
      case 1:
        return 'National ID (Back)';
      case 2:
        return 'Student ID (Front)';
      case 3:
        return 'Student ID (Back)';
      default:
        return 'ID Document ${index + 1}';
    }
  }

  IconData _getDocumentIcon(int index) {
    switch (index) {
      case 0:
      case 1:
        return Icons.credit_card_rounded;
      case 2:
      case 3:
        return Icons.school_rounded;
      default:
        return Icons.badge_rounded;
    }
  }

  void _showImageDialog(BuildContext context, String imageData, String label) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              label,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Image
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: InteractiveViewer(
                            child: _buildDialogImage(imageData),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDialogImage(String imageData) {
    final imageProvider = _getImageProvider(imageData);

    if (imageProvider != null) {
      return Image(
        image: imageProvider,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: Colors.white,
                  size: 48,
                ),
                SizedBox(height: 16),
                Text(
                  'Failed to load image',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          );
        },
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) {
            return child;
          }
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
        },
      );
    } else {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Colors.white,
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              'Failed to load image',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      );
    }
  }
}
