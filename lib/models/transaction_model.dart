import 'package:cloud_firestore/cloud_firestore.dart';

class Transaction {
  final String id;
  final String loanId;
  final double amount;
  final String type; // DISBURSEMENT/REPAYMENT
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.loanId,
    required this.amount,
    required this.type,
    required this.createdAt,
  });

  factory Transaction.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Transaction(
      id: doc.id,
      loanId: data['loanId'],
      amount: data['amount'].toDouble(),
      type: data['type'],
      createdAt: data['createdAt'].toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'loanId': loanId,
      'amount': amount,
      'type': type,
      'createdAt': createdAt,
    };
  }
}