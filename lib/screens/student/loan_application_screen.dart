import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fintech_bridge/services/loan_service.dart';
import 'package:fintech_bridge/utils/constants.dart';

class LoanApplicationScreen extends StatefulWidget {
  final String loanType;

  const LoanApplicationScreen({super.key, required this.loanType});

  @override
  State<LoanApplicationScreen> createState() => _LoanApplicationScreenState();
}

class _LoanApplicationScreenState extends State<LoanApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _purposeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final loanService = Provider.of<LoanService>(context);

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: Text('Apply for ${widget.loanType}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _amountController,
                decoration: AppConstants.inputDecoration(
                  labelText: 'Loan Amount',
                  prefixIcon: Icons.attach_money_rounded,
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _purposeController,
                decoration: AppConstants.inputDecoration(
                  labelText: 'Loan Purpose',
                  prefixIcon: Icons.description_rounded,
                ),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 30),
              AppConstants.gradientButton(
                text: 'Submit Application',
                onPressed: () => _submitApplication(loanService),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitApplication(LoanService loanService) async {
    if (_formKey.currentState!.validate()) {
      final result = await loanService.createLoanRequest(
        providerId: 'selected_provider_id', // Implement provider selection
        amount: double.parse(_amountController.text),
        purpose: _purposeController.text,
        dueDate: DateTime.now().add(const Duration(days: 90)),
      );

      if (result['success']) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
      }
    }
  }
}
