import 'package:fintech_bridge/services/auth_service.dart';
import 'package:fintech_bridge/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Provider.of<AuthService>(context, listen: false).signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 30),
            _buildLoanSection(),
            const SizedBox(height: 20),
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 30, backgroundColor: Colors.white),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Welcome Back,',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              const Text('John Doe',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text('Available Balance: \$2,500',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.9), fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Active Loans',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Card(
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                _buildLoanItem('Tuition Fee Loan', '\$1,500', '60% Paid'),
                const Divider(),
                _buildLoanItem('Equipment Loan', '\$800', '30% Paid'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoanItem(String title, String amount, String status) {
    return ListTile(
      leading: const Icon(Icons.school, color: AppConstants.primaryColor),
      title: Text(title),
      subtitle: Text(amount),
      trailing: Chip(
        label: Text(status),
        backgroundColor: AppConstants.successColor.withOpacity(0.2),
        labelStyle: const TextStyle(color: AppConstants.successColor),
      ),
    );
  }

  Widget _buildQuickActions() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      children: [
        _buildActionButton('Apply Loan', Icons.add_card),
        _buildActionButton('Repayment', Icons.payment),
        _buildActionButton('History', Icons.history),
        _buildActionButton('Documents', Icons.folder),
      ],
    );
  }

  Widget _buildActionButton(String title, IconData icon) {
    return Card(
      elevation: 2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: AppConstants.primaryColor),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}