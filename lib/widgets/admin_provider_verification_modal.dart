import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fintech_bridge/models/provider_model.dart' as provider_model;
import 'package:fintech_bridge/services/database_service.dart';
import 'package:fintech_bridge/utils/constants.dart';

class AdminProviderVerificationModal extends StatefulWidget {
  final provider_model.Provider? provider;
  final VoidCallback onVerificationSuccess;
  final Function(String) onVerificationError;

  const AdminProviderVerificationModal({
    super.key,
    required this.provider,
    required this.onVerificationSuccess,
    required this.onVerificationError,
  });

  @override
  State<AdminProviderVerificationModal> createState() =>
      _AdminProviderVerificationModalState();
}

class _AdminProviderVerificationModalState
    extends State<AdminProviderVerificationModal> {
  bool _isLoading = false;
  String? _reason;
  final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.provider!.verified
                        ? AppConstants.warningColor.withOpacity(0.1)
                        : AppConstants.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    widget.provider!.verified
                        ? Icons.remove_circle
                        : Icons.verified,
                    color: widget.provider!.verified
                        ? AppConstants.warningColor
                        : AppConstants.successColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.provider!.verified
                            ? 'Unverify Provider'
                            : 'Verify Provider',
                        style: AppConstants.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.provider!.businessName,
                        style: AppConstants.bodyMedium.copyWith(
                          color: AppConstants.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Current Status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppConstants.backgroundSecondaryColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Status',
                    style: AppConstants.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppConstants.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: widget.provider!.verified
                              ? AppConstants.successColor.withOpacity(0.1)
                              : AppConstants.warningColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.provider!.verified ? 'VERIFIED' : 'UNVERIFIED',
                          style: AppConstants.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: widget.provider!.verified
                                ? AppConstants.successColor
                                : AppConstants.warningColor,
                          ),
                        ),
                      ),
                      if (widget.provider!.verified &&
                          widget.provider!.verifiedAt != null) ...[
                        const SizedBox(width: 12),
                        Text(
                          'Verified on ${_formatDate(widget.provider!.verifiedAt!)}',
                          style: AppConstants.bodySmall.copyWith(
                            color: AppConstants.textSecondaryColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Verification Checklist (only show when verifying)
            if (!widget.provider!.verified) ...[
              const Text(
                'Verification Checklist',
                style: AppConstants.bodyLarge,
              ),
              const SizedBox(height: 12),
              _buildChecklistItem(
                'Business registration documents uploaded',
                widget.provider!.identificationImages != null &&
                    widget.provider!.identificationImages!.isNotEmpty,
              ),
              _buildChecklistItem(
                'Valid business email provided',
                widget.provider!.businessEmail.isNotEmpty &&
                    widget.provider!.businessEmail.contains('@'),
              ),
              _buildChecklistItem(
                'Complete business information',
                _hasCompleteProfile(),
              ),
              _buildChecklistItem(
                'Business type and loan types specified',
                widget.provider!.businessType.isNotEmpty &&
                    widget.provider!.loanTypes.isNotEmpty,
              ),
              _buildChecklistItem(
                'Interest rate information provided',
                widget.provider!.interestRate > 0,
              ),
              const SizedBox(height: 24),
            ],

            // Reason field (for unverification)
            if (widget.provider!.verified) ...[
              const Text(
                'Reason for Unverification',
                style: AppConstants.bodyLarge,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter reason for unverifying this provider...',
                  hintStyle: AppConstants.bodyMedium.copyWith(
                    color: AppConstants.textSecondaryColor,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppConstants.primaryColor),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                onChanged: (value) {
                  setState(() {
                    _reason = value.trim().isEmpty ? null : value.trim();
                  });
                },
              ),
              const SizedBox(height: 24),
            ],

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppConstants.textSecondaryColor,
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleVerification,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.provider!.verified
                          ? AppConstants.warningColor
                          : AppConstants.successColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            widget.provider!.verified ? 'Unverify' : 'Verify',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),

            // Loading overlay
            if (_isLoading) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppConstants.backgroundSecondaryColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppConstants.primaryColor),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.provider!.verified
                          ? 'Unverifying provider...'
                          : 'Verifying provider...',
                      style: AppConstants.bodyMedium.copyWith(
                        color: AppConstants.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistItem(String title, bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 20,
            color:
                isCompleted ? AppConstants.successColor : Colors.grey.shade400,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: AppConstants.bodyMedium.copyWith(
                color: isCompleted
                    ? AppConstants.primaryColor
                    : AppConstants.textSecondaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _hasCompleteProfile() {
    return widget.provider!.businessName.isNotEmpty &&
        widget.provider!.businessEmail.isNotEmpty &&
        widget.provider!.phone.isNotEmpty &&
        widget.provider!.businessType.isNotEmpty &&
        widget.provider!.loanTypes.isNotEmpty;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _handleVerification() async {
    // Validate inputs for unverification
    if (widget.provider!.verified && (_reason == null || _reason!.isEmpty)) {
      widget.onVerificationError('Please provide a reason for unverification');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final dbService = Provider.of<DatabaseService>(context, listen: false);

      Map<String, dynamic> result;

      if (widget.provider!.verified) {
        // Unverify provider
        result = await dbService.updateProviderVerification(
          widget.provider!.id,
          false,
          reason: _reason,
        );
      } else {
        // Verify provider
        result = await dbService.updateProviderVerification(
          widget.provider!.id,
          true,
        );
      }

      if (result['success']) {
        Navigator.pop(context);
        widget.onVerificationSuccess();
      } else {
        widget.onVerificationError(
            result['message'] ?? 'Failed to update verification status');
      }
    } catch (e) {
      widget.onVerificationError('Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
