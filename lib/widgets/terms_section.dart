import 'package:flutter/material.dart';
import 'package:fintech_bridge/utils/constants.dart';
import 'package:flutter/gestures.dart';

class TermsSection extends StatefulWidget {
  const TermsSection({Key? key}) : super(key: key);

  @override
  State<TermsSection> createState() => _TermsSectionState();
}

class _TermsSectionState extends State<TermsSection> {
  bool _agreeToTerms = false;

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
          const Text(
            'Terms & Conditions',
            style: AppConstants.headlineSmall,
          ),
          const SizedBox(height: 16),
          
          // Terms content - styled like the dashboard card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppConstants.cardGradient,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppConstants.primaryColor.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTermItem(
                  icon: Icons.description_outlined,
                  title: 'Loan Agreement',
                  description: 'By proceeding, you agree to the loan terms and conditions set by the provider.',
                ),
                const SizedBox(height: 16),
                _buildTermItem(
                  icon: Icons.lock_outlined,
                  title: 'Privacy Policy',
                  description: 'Your personal information will be handled according to our privacy policy.',
                ),
                const SizedBox(height: 16),
                _buildTermItem(
                  icon: Icons.verified_user_outlined,
                  title: 'Eligibility',
                  description: 'You confirm that you meet all eligibility requirements for this loan.',
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Agreement checkbox
          InkWell(
            onTap: () {
              setState(() {
                _agreeToTerms = !_agreeToTerms;
              });
            },
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _agreeToTerms,
                    onChanged: (bool? value) {
                      setState(() {
                        _agreeToTerms = value ?? false;
                      });
                    },
                    activeColor: AppConstants.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        color: AppConstants.textColor,
                      ),
                      children: [
                        const TextSpan(
                          text: 'I agree to the ',
                        ),
                        TextSpan(
                          text: 'Terms & Conditions',
                          style: const TextStyle(
                            color: AppConstants.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // Show terms and conditions dialog
                              _showTermsDialog(context);
                            },
                        ),
                        const TextSpan(
                          text: ' and ',
                        ),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: const TextStyle(
                            color: AppConstants.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // Show privacy policy dialog
                              _showPrivacyDialog(context);
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 12,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Terms & Conditions',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
              color: AppConstants.primaryColor,
            ),
          ),
          content: SingleChildScrollView(
            child: Text(
              'This loan agreement ("Agreement") is entered into between you ("Borrower") and the selected financial institution ("Lender").\n\n'
              '1. LOAN AMOUNT AND TERMS: The Lender agrees to lend the specified amount to the Borrower, who agrees to repay the loan with interest according to the terms specified in this Agreement.\n\n'
              '2. INTEREST RATE: The interest rate for this loan is fixed at the rate specified by the Lender at the time of approval.\n\n'
              '3. REPAYMENT: The Borrower agrees to repay the loan in monthly installments until the loan is fully repaid.\n\n'
              '4. PREPAYMENT: The Borrower may prepay the loan in part or in full without penalty.\n\n'
              '5. DEFAULT: If the Borrower fails to make any payment when due, the Lender may declare the entire unpaid balance immediately due and payable.\n\n'
              '6. GOVERNING LAW: This Agreement shall be governed by and construed in accordance with the laws of the jurisdiction where the Lender is located.',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Poppins',
                color: AppConstants.textColor,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Close',
                style: TextStyle(
                  color: AppConstants.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Privacy Policy',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
              color: AppConstants.primaryColor,
            ),
          ),
          content: SingleChildScrollView(
            child: Text(
              'PRIVACY POLICY\n\n'
              'At FinTech Bridge, we take your privacy seriously. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our application.\n\n'
              '1. INFORMATION WE COLLECT: We collect personal information that you provide to us, including but not limited to your name, contact information, financial information, and identification documents.\n\n'
              '2. HOW WE USE YOUR INFORMATION: We use your information to process your loan application, communicate with you, improve our services, and comply with legal obligations.\n\n'
              '3. DISCLOSURE OF YOUR INFORMATION: We may share your information with loan providers, credit bureaus, service providers, and as required by law.\n\n'
              '4. DATA SECURITY: We implement appropriate security measures to protect your personal information.\n\n'
              '5. YOUR RIGHTS: You have the right to access, correct, or delete your personal information.\n\n'
              '6. CHANGES TO THIS POLICY: We may update this policy from time to time. Please review it periodically.',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Poppins',
                color: AppConstants.textColor,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Close',
                style: TextStyle(
                  color: AppConstants.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }
}