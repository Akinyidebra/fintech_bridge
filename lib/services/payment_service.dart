import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fintech_bridge/models/loan_model.dart';
import 'package:fintech_bridge/models/transaction_model.dart' as tm;

class PaymentService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  User? get currentUser => _auth.currentUser;

  Future<Map<String, dynamic>> makeRepayment({
    required String loanId,
    required double amount,
  }) async {
    _setLoading(true);
    try {
      if (currentUser == null) {
        return {'success': false, 'message': 'Authentication required. Please sign in.'};
      }

      final loanDoc = await _firestore.collection('loans').doc(loanId).get();
      if (!loanDoc.exists) {
        return {'success': false, 'message': 'Loan not found'};
      }

      final loan = Loan.fromFirestore(loanDoc);

      if (loan.studentId != currentUser!.uid) {
        return {'success': false, 'message': 'Only the loan borrower can make repayments'};
      }

      if (loan.status != 'APPROVED') {
        return {'success': false, 'message': 'Payments only allowed for approved loans'};
      }

      final transaction = tm.Transaction(
        id: '',
        loanId: loanId,
        amount: amount,
        type: 'REPAYMENT',
        createdAt: DateTime.now(),
      );

      final transactionRef = await _firestore.collection('transactions').add(transaction.toMap());

      final transactionDocs = await _firestore.collection('transactions')
          .where('loanId', isEqualTo: loanId)
          .where('type', isEqualTo: 'REPAYMENT')
          .get();

      double totalRepaid = transactionDocs.docs.fold(0, (sum, doc) => sum + (tm.Transaction.fromFirestore(doc).amount));

      final updateData = <String, dynamic>{};
      if (totalRepaid >= loan.amount) {
        updateData['status'] = 'PAID';
        updateData['updatedAt'] = DateTime.now();
      }

      if (updateData.isNotEmpty) {
        await _firestore.collection('loans').doc(loanId).update(updateData);
      }

      return {
        'success': true,
        'message': totalRepaid >= loan.amount
            ? 'Loan fully repaid! Thank you!'
            : 'Payment processed successfully',
        'transaction': transaction.copyWith(id: transactionRef.id),
        'loanPaid': totalRepaid >= loan.amount,
        'remainingAmount': (loan.amount - totalRepaid).clamp(0, double.infinity)
      };
    } catch (e) {
      return {'success': false, 'message': 'Payment processing failed. Please check your connection.'};
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> getStudentTransactions() async {
    _setLoading(true);
    try {
      if (currentUser == null) {
        return {'success': false, 'message': 'Authentication required. Please sign in.'};
      }

      final studentDoc = await _firestore.collection('students').doc(currentUser!.uid).get();
      if (!studentDoc.exists) {
        return {'success': false, 'message': 'Student account not found'};
      }

      final loanDocs = await _firestore.collection('loans')
          .where('studentId', isEqualTo: currentUser!.uid)
          .get();

      if (loanDocs.docs.isEmpty) {
        return {'success': true, 'data': <tm.Transaction>[]};
      }

      List<tm.Transaction> allTransactions = [];
      for (var loanDoc in loanDocs.docs) {
        final transactionDocs = await _firestore.collection('transactions')
            .where('loanId', isEqualTo: loanDoc.id)
            .get();

        allTransactions.addAll(transactionDocs.docs.map((doc) => tm.Transaction.fromFirestore(doc)));
      }

      return {'success': true, 'data': allTransactions};
    } catch (e) {
      return {'success': false, 'message': 'Failed to retrieve payment history'};
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> getRemainingBalance(String loanId) async {
    _setLoading(true);
    try {
      if (currentUser == null) {
        return {'success': false, 'message': 'Authentication required. Please sign in.'};
      }

      final loanDoc = await _firestore.collection('loans').doc(loanId).get();
      if (!loanDoc.exists) {
        return {'success': false, 'message': 'Loan not found'};
      }

      final loan = Loan.fromFirestore(loanDoc);
      final adminDoc = await _firestore.collection('admins').doc(currentUser!.uid).get();

      final isAuthorized = loan.studentId == currentUser!.uid
          || loan.providerId == currentUser!.uid
          || adminDoc.exists;

      if (!isAuthorized) {
        return {'success': false, 'message': 'Unauthorized to view this loan'};
      }

      final transactionDocs = await _firestore.collection('transactions')
          .where('loanId', isEqualTo: loanId)
          .where('type', isEqualTo: 'REPAYMENT')
          .get();

      final totalRepaid = transactionDocs.docs.fold(0.0, (sum, doc) => sum + tm.Transaction.fromFirestore(doc).amount);
      final remainingBalance = (loan.amount - totalRepaid).clamp(0, loan.amount);

      return {
        'success': true,
        'data': {
          'loanAmount': loan.amount,
          'totalRepaid': totalRepaid,
          'remainingBalance': remainingBalance,
          'isFullyPaid': remainingBalance <= 0
        }
      };
    } catch (e) {
      return {'success': false, 'message': 'Failed to calculate balance. Please try again.'};
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> getTransactionById(String transactionId) async {
    _setLoading(true);
    try {
      if (currentUser == null) {
        return {'success': false, 'message': 'Authentication required. Please sign in.'};
      }

      final transactionDoc = await _firestore.collection('transactions').doc(transactionId).get();
      if (!transactionDoc.exists) {
        return {'success': false, 'message': 'Transaction not found'};
      }

      final transaction = tm.Transaction.fromFirestore(transactionDoc);
      final loanDoc = await _firestore.collection('loans').doc(transaction.loanId).get();

      if (!loanDoc.exists) {
        return {'success': false, 'message': 'Associated loan not found'};
      }

      final loan = Loan.fromFirestore(loanDoc);
      final adminDoc = await _firestore.collection('admins').doc(currentUser!.uid).get();

      final isAuthorized = loan.studentId == currentUser!.uid
          || loan.providerId == currentUser!.uid
          || adminDoc.exists;

      if (!isAuthorized) {
        return {'success': false, 'message': 'Unauthorized to view this transaction'};
      }

      return {'success': true, 'data': transaction};
    } catch (e) {
      return {'success': false, 'message': 'Failed to retrieve transaction details'};
    } finally {
      _setLoading(false);
    }
  }
}