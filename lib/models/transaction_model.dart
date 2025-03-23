import 'package:cloud_firestore/cloud_firestore.dart';

class Transaction {
  final String id;
  final String loanId;
  final double amount;
  final String type; // DISBURSEMENT/REPAYMENT
  final DateTime createdAt;
  final String status;
  final String description;

  Transaction({
    required this.id,
    required this.loanId,
    required this.amount,
    required this.type,
    required this.createdAt,
    required this.status,
    required this.description,
  });

  factory Transaction.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Transaction(
      id: doc.id,
      loanId: data['loanId'],
      amount: data['amount'].toDouble(),
      type: data['type'],
      createdAt: data['createdAt'].toDate(),
      status: data['status'] ?? '',
      description: data['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'loanId': loanId,
      'amount': amount,
      'type': type,
      'createdAt': createdAt,
      'status': status,
      'description': description,
    };
  }

  Transaction copyWith({
    String? id,
    String? loanId,
    double? amount,
    String? type,
    DateTime? createdAt,
    String? status,
    String? description,
  }) {
    return Transaction(
      id: id ?? this.id,
      loanId: loanId ?? this.loanId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      description: description ?? this.description,
    );
  }
}
