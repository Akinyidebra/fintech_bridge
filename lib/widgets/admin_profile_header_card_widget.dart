import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fintech_bridge/models/admin_model.dart';
import 'package:fintech_bridge/utils/constants.dart';

class AdminProfileHeaderCard extends StatelessWidget {
  final Admin admin;

  const AdminProfileHeaderCard({
    super.key,
    required this.admin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppConstants.cardGradient,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 20),
          _buildAdminStats(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
          ),
          child: CircleAvatar(
            radius: 40,
            backgroundImage: _getProfileImage(),
            backgroundColor: Colors.grey[300],
            child: _getProfileImage() == null
                ? const Icon(
                    Icons.admin_panel_settings,
                    size: 40,
                    color: Colors.grey,
                  )
                : null,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      admin.fullName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getAdminBadge(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Admin ID: ${admin.id}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  ImageProvider? _getProfileImage() {
    if (admin.profileImage == null || admin.profileImage!.isEmpty) {
      return null;
    }

    try {
      // Handle both data URI scheme and plain base64
      String base64Data = admin.profileImage!;
      if (base64Data.contains('base64,')) {
        base64Data = base64Data.split(',').last;
      }

      final bytes = base64Decode(base64Data);
      return MemoryImage(bytes);
    } catch (e) {
      // If base64 decoding fails, try as network image
      try {
        return NetworkImage(admin.profileImage!);
      } catch (e) {
        // If both fail, try as asset image
        return const AssetImage('assets/images/default_admin_avatar.png');
      }
    }
  }

  Widget _buildAdminStats() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildStatItem(
            'Access Level',
            _getAccessLevel(),
            icon: Icons.security_rounded,
          ),
          _buildStatDivider(),
          _buildStatItem(
            'Status',
            'Active',
            icon: Icons.verified_rounded,
            iconColor: AppConstants.successColor,
          ),
          _buildStatDivider(),
          _buildStatItem(
            'Since',
            _getJoinedDate(),
            icon: Icons.calendar_today_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value, {
    IconData? icon,
    Color? iconColor,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
              fontFamily: 'Poppins',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: iconColor ?? Colors.white,
                  size: 14,
                ),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.white.withOpacity(0.3),
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  String _getAdminBadge() {
    switch (admin.role.toLowerCase()) {
      case 'admin':
        return 'ADMIN';
      default:
        return 'ADMIN';
    }
  }

  String _getAccessLevel() {
    switch (admin.role.toLowerCase()) {
      case 'admin':
        return 'Full';
      default:
        return 'Basic';
    }
  }

  String _getJoinedDate() {
    final now = DateTime.now();
    final difference = now.difference(admin.createdAt);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '${years}yrs ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '${months}mths ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}dys ago';
    } else {
      return 'Today';
    }
  }
}
