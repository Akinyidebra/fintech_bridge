import 'dart:convert';
import 'package:fintech_bridge/models/student_model.dart';
import 'package:fintech_bridge/utils/constants.dart';
import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  final Future<Map<String, dynamic>>? userProfileFuture;
  final String? title;
  final bool showLogo;
  final bool showProfile;
  final List<Widget>? actions;
  final VoidCallback? onProfileTap;
  final Widget? leading;
  final bool showBackButton;

  const AppHeader({
    super.key,
    this.userProfileFuture,
    this.title,
    this.showLogo = true,
    this.showProfile = true,
    this.actions,
    this.onProfileTap,
    this.leading,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
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
          // Leading/Logo section
          Expanded(
            child: Row(
              children: [
                if (showBackButton)
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: AppConstants.primaryColor,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                if (leading != null) leading!,
                if (showLogo && leading == null && !showBackButton) ...[
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
                if (title != null && !showLogo) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title!,
                      style: AppConstants.titleLarge.copyWith(
                        color: AppConstants.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Actions section
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (actions != null) ...actions!,
              if (showProfile) _buildProfileSection(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    if (userProfileFuture == null) {
      return _buildDefaultProfile();
    }

    return FutureBuilder<Map<String, dynamic>>(
      future: userProfileFuture,
      builder: (context, snapshot) {
        String profileImage = '';
        if (snapshot.hasData && snapshot.data!['success']) {
          final student = snapshot.data!['data'] as Student;
          profileImage = student.profileImage ?? '';
        }

        return GestureDetector(
          onTap: onProfileTap,
          child: _buildProfileAvatar(profileImage),
        );
      },
    );
  }

  Widget _buildDefaultProfile() {
    return GestureDetector(
      onTap: onProfileTap,
      child: _buildProfileAvatar(''),
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