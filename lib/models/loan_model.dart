import 'package:cloud_firestore/cloud_firestore.dart';

class Loan {
  final String id;
  final String studentId;
  final String providerId;
  final double amount;
  final String status; // PENDING/APPROVED/REJECTED/PAID
  final String purpose;
  final double interestRate;
  final int termMonths;
  final double monthlyPayment;
  final double remainingBalance;
  final DateTime nextDueDate;
  final DateTime dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Loan({
    required this.id,
    required this.studentId,
    required this.providerId,
    required this.amount,
    required this.status,
    required this.purpose,
    required this.interestRate,
    required this.termMonths,
    required this.monthlyPayment,
    required this.remainingBalance,
    required this.nextDueDate,
    required this.dueDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Loan.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Loan(
      id: doc.id,
      studentId: data['studentId'],
      providerId: data['providerId'],
      amount: data['amount'].toDouble(),
      status: data['status'],
      purpose: data['purpose'],
      interestRate: data['interestRate']?.toDouble() ?? 0.0,
      termMonths: data['termMonths'] ?? 12,
      monthlyPayment: data['monthlyPayment']?.toDouble() ?? 0.0,
      remainingBalance: data['remainingBalance']?.toDouble() ?? 0.0,
      nextDueDate: data['nextDueDate']?.toDate() ?? DateTime.now(),
      dueDate: data['dueDate'].toDate(),
      createdAt: data['createdAt'].toDate(),
      updatedAt: data['updatedAt'].toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'providerId': providerId,
      'amount': amount,
      'status': status,
      'purpose': purpose,
      'interestRate': interestRate,
      'termMonths': termMonths,
      'monthlyPayment': monthlyPayment,
      'remainingBalance': remainingBalance,
      'nextDueDate': nextDueDate,
      'dueDate': dueDate,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Loan copyWith({
    String? id,
    String? studentId,
    String? providerId,
    double? amount,
    String? status,
    String? purpose,
    double? interestRate,
    int? termMonths,
    double? monthlyPayment,
    double? remainingBalance,
    DateTime? nextDueDate,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Loan(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      providerId: providerId ?? this.providerId,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      purpose: purpose ?? this.purpose,
      interestRate: interestRate ?? this.interestRate,
      termMonths: termMonths ?? this.termMonths,
      monthlyPayment: monthlyPayment ?? this.monthlyPayment,
      remainingBalance: remainingBalance ?? this.remainingBalance,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}