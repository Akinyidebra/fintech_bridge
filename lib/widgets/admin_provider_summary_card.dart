import 'package:flutter/material.dart';
import 'package:fintech_bridge/models/provider_model.dart' as provider_model;
import 'package:fintech_bridge/utils/constants.dart';
import 'package:intl/intl.dart';

class AdminProviderSummaryCard extends StatelessWidget {
  final provider_model.Provider provider;
  final int registrationDays;

  const AdminProviderSummaryCard({
    super.key,
    required this.provider,
    required this.registrationDays,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Quick Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  color: AppConstants.textColor,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: provider.verified
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: provider.verified
                        ? Colors.green.withOpacity(0.3)
                        : Colors.orange.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      provider.verified
                          ? Icons.verified_outlined
                          : Icons.pending_outlined,
                      size: 14,
                      color: provider.verified
                          ? Colors.green.shade600
                          : Colors.orange.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      provider.verified ? 'Verified' : 'Pending',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: provider.verified
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // First row - Registration and Business Type
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.calendar_today_outlined,
                  label: 'Registered',
                  value: '$registrationDays days ago',
                  color: AppConstants.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.category_outlined,
                  label: 'Business Type',
                  value: provider.businessType,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Second row - Interest Rate and Loan Types
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.percent_outlined,
                  label: 'Interest Rate',
                  value: '${provider.interestRate.toStringAsFixed(2)}%',
                  color: Colors.purple,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.list_alt_outlined,
                  label: 'Loan Types',
                  value: '${provider.loanTypes.length} type(s)',
                  color: Colors.indigo,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Third row - Documents and Profile
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.image_outlined,
                  label: 'Documents',
                  value: provider.identificationImages != null
                      ? '${provider.identificationImages!.length} uploaded'
                      : 'None uploaded',
                  color: provider.identificationImages != null &&
                          provider.identificationImages!.isNotEmpty
                      ? Colors.teal
                      : Colors.grey,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.account_circle_outlined,
                  label: 'Profile Image',
                  value: provider.profileImage != null &&
                          provider.profileImage!.isNotEmpty
                      ? 'Uploaded'
                      : 'Not uploaded',
                  color: provider.profileImage != null &&
                          provider.profileImage!.isNotEmpty
                      ? Colors.green
                      : Colors.grey,
                ),
              ),
            ],
          ),

          // Fourth row - Contact Information
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.email_outlined,
                  label: 'Business Email',
                  value: provider.businessEmail,
                  color: Colors.cyan,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.phone_outlined,
                  label: 'Phone Number',
                  value: provider.phone,
                  color: Colors.orange,
                ),
              ),
            ],
          ),

          // Website Information (if available)
          if (provider.website != null && provider.website!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSummaryItem(
              icon: Icons.language_outlined,
              label: 'Website',
              value: provider.website!,
              color: Colors.green.shade600,
            ),
          ],

          // Last Updated Information
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey.shade200,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.update_outlined,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  'Last updated: ${DateFormat('MMM dd, yyyy - hh:mm a').format(provider.updatedAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              color: AppConstants.textColor,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
