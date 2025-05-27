import 'package:fintech_bridge/widgets/profile_content_widget.dart';
import 'package:flutter/material.dart';
import 'package:fintech_bridge/utils/constants.dart';

class ProfileInfoSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<ProfileInfoItem> items;

  const ProfileInfoSection({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
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
          _buildInfoItems(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Icon(
          icon,
          color: iconColor,
          size: 22,
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: AppConstants.headlineSmall,
        ),
      ],
    );
  }

  Widget _buildInfoItems() {
    return Column(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          _buildInfoRow(items[i]),
          if (items[i].additionalContent != null) items[i].additionalContent!,
          if (i < items.length - 1) const Divider(height: 24),
        ],
      ],
    );
  }

  Widget _buildInfoRow(ProfileInfoItem item) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: item.backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            item.icon,
            color: item.iconColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppConstants.textColor.withOpacity(0.6),
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.textColor,
                  fontFamily: 'Poppins',
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}