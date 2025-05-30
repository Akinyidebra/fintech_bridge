import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fintech_bridge/models/provider_model.dart';
import 'package:fintech_bridge/utils/constants.dart';

class ProviderProfileHeaderCard extends StatelessWidget {
  final Provider provider;

  const ProviderProfileHeaderCard({
    super.key,
    required this.provider,
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
          _buildProfileStats(),
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
                  Icons.business,
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
                      provider.businessName,
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
                    child: const Text(
                      'Provider',
                      style: TextStyle(
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
                provider.businessType,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontFamily: 'Poppins',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                provider.businessEmail,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  fontStyle: FontStyle.italic,
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
    if (provider.profileImage == null || provider.profileImage!.isEmpty) {
      return null;
    }

    try {
      // Handle both data URI scheme and plain base64
      String base64Data = provider.profileImage!;
      if (base64Data.contains('base64,')) {
        base64Data = base64Data.split(',').last;
      }
      
      final bytes = base64Decode(base64Data);
      return MemoryImage(bytes);
    } catch (e) {
      // If base64 decoding fails, try as network image
      try {
        return NetworkImage(provider.profileImage!);
      } catch (e) {
        // If both fail, try as asset image
        return const AssetImage('assets/images/default_business_avatar.png');
      }
    }
  }

  Widget _buildProfileStats() {
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStatItem(
            'Interest Rate',
            '${provider.interestRate.toStringAsFixed(1)}%',
          ),
          _buildStatDivider(),
          _buildStatItem(
            'Verification',
            provider.verified ? 'Verified' : 'Pending',
            icon: provider.verified
                ? Icons.verified_rounded
                : Icons.pending_rounded,
            iconColor: provider.verified ? Colors.white : Colors.amber,
          ),
          _buildStatDivider(),
          _buildStatItem(
            'Status',
            provider.approved ? 'Approved' : 'Pending',
            icon: provider.approved
                ? Icons.check_circle_rounded
                : Icons.unpublished_rounded,
            iconColor: provider.approved
                ? Colors.greenAccent
                : Colors.white70,
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
              fontSize: 14,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: iconColor ?? Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
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
      height: 40,
      width: 1,
      color: Colors.white.withOpacity(0.3),
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}