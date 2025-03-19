import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fintech_bridge/models/loan_model.dart';
import 'package:fintech_bridge/models/transaction_model.dart' as tm;

class LoanService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  User? get currentUser => _auth.currentUser;

  Future<Map<String, dynamic>> createLoanRequest({
    required String providerId,
    required double amount,
    required String purpose,
    required DateTime dueDate,
  }) async {
    _setLoading(true);
    try {
      if (currentUser == null) {
        return {'success': false, 'message': 'Please sign in to request a loan'};
      }

      final studentDoc = await _firestore.collection('students').doc(currentUser!.uid).get();
      if (!studentDoc.exists) {
        return {'success': false, 'message': 'Only verified students can request loans'};
      }

      final loan = Loan(
        id: '',
        studentId: currentUser!.uid,
        providerId: providerId,
        amount: amount,
        status: 'PENDING',
        purpose: purpose,
        dueDate: dueDate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final loanRef = await _firestore.collection('loans').add(loan.toMap());

      return {
        'success': true,
        'message': 'Loan request submitted for review',
        'loan': loan.copyWith(id: loanRef.id)
      };
    } catch (e) {
      return {'success': false, 'message': 'Failed to submit loan request. Please try again.'};
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> getLoanById(String loanId) async {
    _setLoading(true);
    try {
      final doc = await _firestore.collection('loans').doc(loanId).get();
      return doc.exists
          ? {'success': true, 'data': Loan.fromFirestore(doc)}
          : {'success': false, 'message': 'Loan not found'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to load loan details'};
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> getStudentLoans() async {
    _setLoading(true);
    try {
      if (currentUser == null) {
        return {'success': false, 'message': 'Authentication required'};
      }

      final studentDoc = await _firestore.collection('students').doc(currentUser!.uid).get();
      if (!studentDoc.exists) {
        return {'success': false, 'message': 'Student account not found'};
      }

      final loanDocs = await _firestore.collection('loans')
          .where('studentId', isEqualTo: currentUser!.uid)
          .get();

      return {
        'success': true,
        'data': loanDocs.docs.map((doc) => Loan.fromFirestore(doc)).toList()
      };
    } catch (e) {
      return {'success': false, 'message': 'Failed to load your loans'};
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> getProviderLoans() async {
    _setLoading(true);
    try {
      if (currentUser == null) {
        return {'success': false, 'message': 'Authentication required'};
      }

      final providerDoc = await _firestore.collection('providers').doc(currentUser!.uid).get();
      if (!providerDoc.exists) {
        return {'success': false, 'message': 'Provider account not found'};
      }

      final loanDocs = await _firestore.collection('loans')
          .where('providerId', isEqualTo: currentUser!.uid)
          .get();

      return {
        'success': true,
        'data': loanDocs.docs.map((doc) => Loan.fromFirestore(doc)).toList()
      };
    } catch (e) {
      return {'success': false, 'message': 'Failed to load provider loans'};
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> updateLoanStatus(String loanId, String status) async {
    _setLoading(true);
    try {
      if (currentUser == null) {
        return {'success': false, 'message': 'Authentication required'};
      }

      if (!['APPROVED', 'REJECTED', 'PAID'].contains(status)) {
        return {'success': false, 'message': 'Invalid status update'};
      }

      final loanDoc = await _firestore.collection('loans').doc(loanId).get();
      if (!loanDoc.exists) {
        return {'success': false, 'message': 'Loan not found'};
      }

      final loan = Loan.fromFirestore(loanDoc);
      final isAdmin = (await _firestore.collection('admins').doc(currentUser!.uid).get()).exists;

      if (loan.providerId != currentUser!.uid && !isAdmin) {
        return {'success': false, 'message': 'Unauthorized action'};
      }

      await _firestore.collection('loans').doc(loanId).update({
        'status': status,
        'updatedAt': DateTime.now(),
      });

      if (status == 'APPROVED') {
        final transaction = tm.Transaction(
          id: '',
          loanId: loanId,
          amount: loan.amount,
          type: 'DISBURSEMENT',
          createdAt: DateTime.now(),
        );
        await _firestore.collection('transactions').add(transaction.toMap());
      }

      return {
        'success': true,
        'message': 'Loan status updated to ${status.toLowerCase()}'
      };
    } catch (e) {
      return {'success': false, 'message': 'Failed to update loan status'};
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> getAllLoans() async {
    _setLoading(true);
    try {
      if (currentUser == null) {
        return {'success': false, 'message': 'Authentication required'};
      }

      final adminDoc = await _firestore.collection('admins').doc(currentUser!.uid).get();
      if (!adminDoc.exists) {
        return {'success': false, 'message': 'Admin access required'};
      }

      final loanDocs = await _firestore.collection('loans').get();
      return {
        'success': true,
        'data': loanDocs.docs.map((doc) => Loan.fromFirestore(doc)).toList()
      };
    } catch (e) {
      return {'success': false, 'message': 'Failed to load all loans'};
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> getLoansByStatus(String status) async {
    _setLoading(true);
    try {
      if (!['PENDING', 'APPROVED', 'REJECTED', 'PAID'].contains(status)) {
        return {'success': false, 'message': 'Invalid status filter'};
      }

      final loanDocs = await _firestore.collection('loans')
          .where('status', isEqualTo: status)
          .get();

      return {
        'success': true,
        'data': loanDocs.docs.map((doc) => Loan.fromFirestore(doc)).toList()
      };
    } catch (e) {
      return {'success': false, 'message': 'Failed to filter loans'};
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> getLoanTransactions(String loanId) async {
    _setLoading(true);
    try {
      final loanDoc = await _firestore.collection('loans').doc(loanId).get();
      if (!loanDoc.exists) {
        return {'success': false, 'message': 'Loan not found'};
      }

      final loan = Loan.fromFirestore(loanDoc);
      final isAdmin = (await _firestore.collection('admins').doc(currentUser!.uid).get()).exists;

      if (loan.studentId != currentUser!.uid &&
          loan.providerId != currentUser!.uid &&
          !isAdmin) {
        return {'success': false, 'message': 'Access denied'};
      }

      final transactionDocs = await _firestore.collection('transactions')
          .where('loanId', isEqualTo: loanId)
          .get();

      return {
        'success': true,
        'data': transactionDocs.docs.map((doc) => tm.Transaction.fromFirestore(doc)).toList()
      };
    } catch (e) {
      return {'success': false, 'message': 'Failed to load transactions'};
    } finally {
      _setLoading(false);
    }
  }
}