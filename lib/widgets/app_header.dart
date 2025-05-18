import 'dart:convert';
import 'package:fintech_bridge/models/student_model.dart';
import 'package:fintech_bridge/utils/constants.dart';
import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  final Future<Map<String, dynamic>> userProfileFuture;

  const AppHeader({
    Key? key,
    required this.userProfileFuture,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: userProfileFuture,
      builder: (context, snapshot) {
        String profileImage = '';
        if (snapshot.hasData && snapshot.data!['success']) {
          final student = snapshot.data!['data'] as Student;
          profileImage = student.profileImage ?? '';
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                    height: 32,
                    child: Image.asset(
                      'assets/icons/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 12),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Fin',
                          style: AppConstants.titleLarge.copyWith(
                            color: AppConstants.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: 'Tech Bridge',
                          style: AppConstants.titleLarge.copyWith(
                            color: AppConstants.accentColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              _buildProfileAvatar(profileImage),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileAvatar(String imageUrl) {
    if (imageUrl.isEmpty) {
      return _buildDefaultAvatar();
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppConstants.primaryColor, width: 2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: imageUrl.isNotEmpty
            ? _buildCachedBase64Image(imageUrl)
            : _buildDefaultAvatar(),
      ),
    );
  }

  Widget _buildCachedBase64Image(String data) {
    try {
      // Handle data URI scheme (e.g., "data:image/png;base64,iVBOR...")
      final base64Data = data.contains('base64,') ? data.split(',').last : data;

      final bytes = base64Decode(base64Data);
      return Image.memory(
        bytes,
        width: 28,
        height: 28,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
        gaplessPlayback: true, // Prevents blinking during image loading
      );
    } catch (e) {
      return _buildDefaultAvatar();
    }
  }

  Widget _buildDefaultAvatar() {
    return const CircleAvatar(
      radius: 14,
      backgroundColor: AppConstants.backgroundSecondaryColor,
      child: Icon(Icons.person, color: AppConstants.textSecondaryColor),
    );
  }
}