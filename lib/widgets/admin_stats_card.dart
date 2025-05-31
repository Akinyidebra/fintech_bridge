import 'package:fintech_bridge/utils/constants.dart';
import 'package:flutter/material.dart';

class AdminStatsCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final String? trend; // Modified to match your usage
  final String? additionalInfo;

  const AdminStatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
    this.trend, // Simplified trend parameter
    this.additionalInfo,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.black.withOpacity(0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with icon and navigation indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 22,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 14),
            
            // Main value with enhanced styling
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppConstants.textColor,
                height: 1.1,
              ),
            ),
            
            const SizedBox(height: 6),
            
            // Title
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppConstants.textColor,
              ),
            ),
            
            const SizedBox(height: 4),
            
            // Subtitle with better spacing
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                color: AppConstants.textSecondaryColor.withOpacity(0.8),
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            // Trend indicator (matches your usage)
            if (trend != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getTrendColor(trend!).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _getTrendColor(trend!).withOpacity(0.2),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getTrendIcon(trend!),
                      size: 12,
                      color: _getTrendColor(trend!),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        trend!,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _getTrendColor(trend!),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // Additional info if provided
            if (additionalInfo != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  additionalInfo!,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: color.withOpacity(0.8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Helper methods to determine trend styling
  Color _getTrendColor(String trendText) {
    final lowerTrend = trendText.toLowerCase();
    if (lowerTrend.contains('requires attention') || 
        lowerTrend.contains('pending') ||
        lowerTrend.contains('overdue')) {
      return AppConstants.errorColor;
    } else if (lowerTrend.contains('+') || 
               lowerTrend.contains('increase') ||
               lowerTrend.contains('this week')) {
      return AppConstants.successColor;
    } else if (lowerTrend.contains('warning') || 
               lowerTrend.contains('review')) {
      return AppConstants.warningColor;
    }
    return AppConstants.primaryColor;
  }

  IconData _getTrendIcon(String trendText) {
    final lowerTrend = trendText.toLowerCase();
    if (lowerTrend.contains('requires attention') || 
        lowerTrend.contains('pending')) {
      return Icons.warning_amber_rounded;
    } else if (lowerTrend.contains('+') || 
               lowerTrend.contains('this week')) {
      return Icons.trending_up_rounded;
    } else if (lowerTrend.contains('review')) {
      return Icons.visibility_rounded;
    }
    return Icons.info_outline_rounded;
  }
}