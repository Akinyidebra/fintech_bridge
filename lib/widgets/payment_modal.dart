import 'package:fintech_bridge/models/loan_model.dart';
import 'package:fintech_bridge/services/payment_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fintech_bridge/utils/constants.dart';

class PaymentModal extends StatefulWidget {
  final Loan loan;
  final VoidCallback onPaymentSuccess;
  final Function(String) onPaymentError;

  const PaymentModal({
    super.key,
    required this.loan,
    required this.onPaymentSuccess,
    required this.onPaymentError,
  });

  @override
  State<PaymentModal> createState() => _PaymentModalState();
}

class _PaymentModalState extends State<PaymentModal> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  
  bool _isProcessing = false;
  String _selectedPaymentMethod = 'bank_transfer';
  
  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'bank_transfer',
      'name': 'Bank Transfer',
      'icon': Icons.account_balance_rounded,
    },
    {
      'id': 'mobile_money',
      'name': 'Mobile Money',
      'icon': Icons.phone_android_rounded,
    },
    {
      'id': 'card',
      'name': 'Credit/Debit Card',
      'icon': Icons.credit_card_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    // Set default amount to remaining balance
    _amountController.text = widget.loan.remainingBalance.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Make Payment',
                        style: AppConstants.headlineSmall,
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        style: IconButton.styleFrom(
                          backgroundColor: AppConstants.backgroundSecondaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Loan Summary
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppConstants.backgroundSecondaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Remaining Balance',
                              style: AppConstants.bodyMedium,
                            ),
                            Text(
                              'KES ${NumberFormat('#,##0.00').format(widget.loan.remainingBalance)}',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppConstants.primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Due Date',
                              style: AppConstants.bodyMedium,
                            ),
                            Text(
                              DateFormat('dd MMM yyyy').format(widget.loan.nextDueDate),
                              style: AppConstants.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: _isOverdue() ? Colors.red : AppConstants.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                        if (_isOverdue()) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'OVERDUE',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Payment Amount
                  const Text(
                    'Payment Amount',
                    style: AppConstants.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    decoration: InputDecoration(
                      hintText: 'Enter amount',
                      prefixText: 'KES ',
                      prefixStyle: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppConstants.primaryColor,
                      ),
                      filled: true,
                      fillColor: AppConstants.backgroundSecondaryColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppConstants.primaryColor),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter payment amount';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return 'Please enter a valid amount';
                      }
                      if (amount > widget.loan.remainingBalance) {
                        return 'Amount cannot exceed remaining balance';
                      }
                      // Minimum payment check (optional)
                      if (amount < 10) {
                        return 'Minimum payment amount is KES 10.00';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Quick amount buttons
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickAmountButton(
                          'Minimum',
                          widget.loan.monthlyPayment,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildQuickAmountButton(
                          'Half Balance',
                          widget.loan.remainingBalance / 2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildQuickAmountButton(
                          'Full Balance',
                          widget.loan.remainingBalance,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Payment Method
                  const Text(
                    'Payment Method',
                    style: AppConstants.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: _paymentMethods.map((method) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedPaymentMethod = method['id'];
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _selectedPaymentMethod == method['id']
                                  ? AppConstants.primaryColor.withOpacity(0.1)
                                  : AppConstants.backgroundSecondaryColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _selectedPaymentMethod == method['id']
                                    ? AppConstants.primaryColor
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  method['icon'],
                                  color: _selectedPaymentMethod == method['id']
                                      ? AppConstants.primaryColor
                                      : AppConstants.textSecondaryColor,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  method['name'],
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: _selectedPaymentMethod == method['id']
                                        ? AppConstants.primaryColor
                                        : AppConstants.primaryColor,
                                  ),
                                ),
                                const Spacer(),
                                if (_selectedPaymentMethod == method['id'])
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: AppConstants.primaryColor,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  
                  // Payment Note
                  const Text(
                    'Payment Note (Optional)',
                    style: AppConstants.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _noteController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Add a note for this payment...',
                      filled: true,
                      fillColor: AppConstants.backgroundSecondaryColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppConstants.primaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _processPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isProcessing
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Process Payment - KES ${_getPaymentAmount().toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAmountButton(String label, double amount) {
    return OutlinedButton(
      onPressed: () {
        setState(() {
          _amountController.text = amount.toStringAsFixed(2);
        });
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: const BorderSide(color: AppConstants.primaryColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppConstants.primaryColor,
            ),
          ),
          Text(
            'KES ${amount.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppConstants.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  bool _isOverdue() {
    return widget.loan.nextDueDate.isBefore(DateTime.now());
  }

  double _getPaymentAmount() {
    final amount = double.tryParse(_amountController.text);
    return amount ?? 0.0;
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final paymentService = Provider.of<PaymentService>(context, listen: false);
      final amount = double.parse(_amountController.text);
      
      final result = await paymentService.makeRepayment(
        loanId: widget.loan.id,
        amount: amount,
        paymentMethod: _selectedPaymentMethod,
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      );

      if (mounted) {
        if (result['success']) {
          Navigator.pop(context);
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Payment processed successfully'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
          
          widget.onPaymentSuccess();
        } else {
          widget.onPaymentError(result['message'] ?? 'Payment failed');
        }
      }
    } catch (e) {
      if (mounted) {
        widget.onPaymentError('An error occurred: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}