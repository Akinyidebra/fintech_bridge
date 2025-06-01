import 'package:flutter/material.dart';
import 'package:fintech_bridge/models/provider_model.dart' as provider_model;
import 'package:fintech_bridge/utils/constants.dart';
import 'package:intl/intl.dart';

class AdminProviderDetailSection extends StatelessWidget {
  final provider_model.Provider provider;

  const AdminProviderDetailSection({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Business Information Section
        _buildSection(
          title: 'Business Information',
          children: [
            _buildDetailRow(
              icon: Icons.business_outlined,
              label: 'Business Name',
              value: provider.businessName,
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              icon: Icons.email_outlined,
              label: 'Business Email',
              value: provider.businessEmail,
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              icon: Icons.phone_outlined,
              label: 'Phone Number',
              value: provider.phone,
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              icon: Icons.category_outlined,
              label: 'Business Type',
              value: provider.businessType,
            ),
            if (provider.website != null && provider.website!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildDetailRow(
                icon: Icons.language_outlined,
                label: 'Website',
                value: provider.website!,
              ),
            ],
            if (provider.description != null && provider.description!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildDetailRow(
                icon: Icons.description_outlined,
                label: 'Description',
                value: provider.description!,
              ),
            ],
          ],
        ),

        const SizedBox(height: 24),

        // Loan Services Section
        _buildSection(
          title: 'Loan Services',
          children: [
            _buildDetailRow(
              icon: Icons.percent_outlined,
              label: 'Interest Rate',
              value: '${provider.interestRate.toStringAsFixed(2)}% per month',
            ),
            const SizedBox(height: 16),
            _buildLoanTypesRow(),
          ],
        ),

        const SizedBox(height: 24),

        // Verification Status Section
        _buildSection(
          title: 'Verification Status',
          borderColor: provider.verified ? Colors.green.shade200 : Colors.orange.shade200,
          children: [
            _buildDetailRow(
              icon: provider.verified ? Icons.verified_outlined : Icons.pending_outlined,
              label: 'Verification Status',
              value: provider.verified ? 'Verified' : 'Pending Verification',
              iconColor: provider.verified ? Colors.green.shade600 : Colors.orange.shade600,
              valueColor: provider.verified ? Colors.green.shade700 : Colors.orange.shade700,
            ),
            if (provider.verified && provider.verifiedAt != null) ...[
              const SizedBox(height: 16),
              _buildDetailRow(
                icon: Icons.calendar_today_outlined,
                label: 'Verified At',
                value: DateFormat('MMM dd, yyyy - hh:mm a').format(provider.verifiedAt!),
                iconColor: Colors.green.shade600,
              ),
            ],
            const SizedBox(height: 16),
            _buildDetailRow(
              icon: Icons.image_outlined,
              label: 'ID Documents',
              value: provider.identificationImages != null 
                  ? '${provider.identificationImages!.length} document(s) uploaded'
                  : 'No documents uploaded',
              iconColor: provider.identificationImages != null && provider.identificationImages!.isNotEmpty 
                  ? Colors.blue.shade600 
                  : Colors.grey.shade500,
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Profile Section
        if (provider.profileImage != null && provider.profileImage!.isNotEmpty) ...[
          _buildSection(
            title: 'Profile Information',
            children: [
              _buildDetailRow(
                icon: Icons.account_circle_outlined,
                label: 'Profile Image',
                value: 'Profile image uploaded',
                iconColor: Colors.blue.shade600,
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],

        // Account Information Section
        _buildSection(
          title: 'Account Information',
          children: [
            _buildDetailRow(
              icon: Icons.calendar_today_outlined,
              label: 'Account Created',
              value: DateFormat('MMM dd, yyyy - hh:mm a').format(provider.createdAt),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              icon: Icons.update_outlined,
              label: 'Last Updated',
              value: DateFormat('MMM dd, yyyy - hh:mm a').format(provider.updatedAt),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
    Color? borderColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            title,
            style: AppConstants.headlineSmall,
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: borderColor != null
                ? Border.all(color: borderColor, width: 1)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildLoanTypesRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppConstants.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.list_alt_outlined,
            color: AppConstants.primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Loan Types Offered',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                  color: AppConstants.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 8),
              if (provider.loanTypes.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: provider.loanTypes.map((loanType) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppConstants.primaryColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        loanType,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                    );
                  }).toList(),
                )
              else
                Text(
                  'No loan types specified',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    color: Colors.grey.shade600,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? iconColor,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (iconColor ?? AppConstants.primaryColor).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: iconColor ?? AppConstants.primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                  color: AppConstants.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  color: valueColor ?? AppConstants.textColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}