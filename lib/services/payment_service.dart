import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fintech_bridge/models/loan_model.dart';
import 'package:fintech_bridge/models/transaction_model.dart';

class PaymentService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  // Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  
  // Get current user
  User? get currentUser => _auth.currentUser;

  // Make loan repayment
  Future<Map<String, dynamic>> makeRepayment({
    required String loanId,
    required double amount,
  }) async {
    _setLoading(true);
    try {
      if (currentUser == null) {
        return {'success': false, 'message': 'No user signed in'};
      }
      
      // Get loan document
      DocumentSnapshot loanDoc = await _firestore.collection('loans').doc(loanId).get();
      if (!loanDoc.exists) {
        return {'success': false, 'message': 'Loan not found'};
      }
      
      Loan loan = Loan.fromFirestore(loanDoc);
      
      // Verify user is the loan student
      if (loan.studentId != currentUser!.uid) {
        return {'success': false, 'message': 'Only the borrower can make repayments'};
      }
      
      // Verify loan is in approved status
      if (loan.status != 'APPROVED') {
        return {'success': false, 'message': 'Cannot make payment for a loan that is not approved'};
      }
      
      // Create repayment transaction
      Transaction transaction = Transaction(
        id: '', // Firestore will generate this
        loanId: loanId,
        amount: amount,
        type: 'REPAYMENT',
        createdAt: DateTime.now(),
      );
      
      DocumentReference transactionRef = await _firestore.collection('transactions').add(transaction.toMap());
      
      // Calculate total repaid amount
      final transactionDocs = await _firestore.collection('transactions')
          .where('loanId', isEqualTo: loanId)
          .where('type', isEqualTo: 'REPAYMENT')
          .get();
      
      double totalRepaid = 0;
      for (var doc in transactionDocs.docs) {
        Transaction t = Transaction.fromFirestore(doc);
        totalRepaid += t.amount;
      }
      
      // If total repaid equals or exceeds loan amount, update loan status to PAID
      if (totalRepaid >= loan.amount) {
        await _firestore.collection('loans').doc(loanId).update({
          'status': 'PAID',
          'updatedAt': DateTime.now(),
        });
        
        return {
          'success': true, 
          'message': 'Payment successful. Your loan has been fully repaid.',
          'transaction': Transaction(
            id: transactionRef.id,
            loanId: transaction.loanId,
            amount: transaction.amount,
            type: transaction.type,
            createdAt: transaction.createdAt,
          ),
          'loanPaid': true
        };
      }
      
      return {
        'success': true, 
        'message': 'Payment successful',
        'transaction': Transaction(
          id: transactionRef.id,
          loanId: transaction.loanId,
          amount: transaction.amount,
          type: transaction.type,
          createdAt: transaction.createdAt,
        ),
        'loanPaid': false,
        'remainingAmount': loan.amount - totalRepaid
      };
    } catch (e) {
      return {'success': false, 'message': 'Payment failed. Please try again.'};
    } finally {
      _setLoading(false);
    }
  }
  
  // Get all transactions for a student
  Future<Map<String, dynamic>> getStudentTransactions() async {
    _setLoading(true);
    try {
      if (currentUser == null) {
        return {'success': false, 'message': 'No user signed in'};
      }
      
      // Verify user is a student
      DocumentSnapshot studentDoc = await _firestore.collection('students').doc(currentUser!.uid).get();
      if (!studentDoc.exists) {
        return {'success': false, 'message': 'User is not a student'};
      }
      
      // Get all loans for the student
      final loanDocs = await _firestore.collection('loans')
          .where('studentId', isEqualTo: currentUser!.uid)
          .get();
      
      List<String> loanIds = loanDocs.docs.map((doc) => doc.id).toList();
      
      // If no loans found
      if (loanIds.isEmpty) {
        return {'success': true, 'data': <Transaction>[]};
      }
      
      // Get all transactions for those loans
      // Using multiple queries since Firestore doesn't support array contains any with other conditions
      List<Transaction> allTransactions = [];
      
      for (String loanId in loanIds) {
        final transactionDocs = await _firestore.collection('transactions')
            .where('loanId', isEqualTo: loanId)
            .get();
        
        for (var doc in transactionDocs.docs) {
          allTransactions.add(Transaction.fromFirestore(doc));
        }
      }
      
      return {'success': true, 'data': allTransactions};
    } catch (e) {
      return {'success': false, 'message': 'Failed to retrieve transactions'};
    } finally {
      _setLoading(false);
    }
  }
  
  // Get all transactions for a provider
  Future<Map<String, dynamic>> getProviderTransactions() async {
    _setLoading(true);
    try {
      if (currentUser == null) {
        return {'success': false, 'message': 'No user signed in'};
      }
      
      // Verify user is a provider
      DocumentSnapshot providerDoc = await _firestore.collection('providers').doc(currentUser!.uid).get();
      if (!providerDoc.exists) {
        return {'success': false, 'message': 'User is not a provider'};
      }
      
      // Get all loans for the provider
      final loanDocs = await _firestore.collection('loans')
          .where('providerId', isEqualTo: currentUser!.uid)
          .get();
      
      List<String> loanIds = loanDocs.docs.map((doc) => doc.id).toList();
      
      // If no loans found
      if (loanIds.isEmpty) {
        return {'success': true, 'data': <Transaction>[]};
      }
      
      // Get all transactions for those loans
      List<Transaction> allTransactions = [];
      
      for (String loanId in loanIds) {
        final transactionDocs = await _firestore.collection('transactions')
            .where('loanId', isEqualTo: loanId)
            .get();
        
        for (var doc in transactionDocs.docs) {
          allTransactions.add(Transaction.fromFirestore(doc));
        }
      }
      
      return {'success': true, 'data': allTransactions};
    } catch (e) {
      return {'success': false, 'message': 'Failed to retrieve transactions'};
    } finally {
      _setLoading(false);
    }
  }
  
  // Calculate remaining balance for a loan
  Future<Map<String, dynamic>> getRemainingBalance(String loanId) async {
    _setLoading(true);
    try {
      if (currentUser == null) {
        return {'success': false, 'message': 'No user signed in'};
      }
      
      // Get loan document
      DocumentSnapshot loanDoc = await _firestore.collection('loans').doc(loanId).get();
      if (!loanDoc.exists) {
        return {'success': false, 'message': 'Loan not found'};
      }
      
      Loan loan = Loan.fromFirestore(loanDoc);
      
      // Verify user is authorized (student, provider, or admin)
      bool isStudent = loan.studentId == currentUser!.uid;
      bool isProvider = loan.providerId == currentUser!.uid;
      DocumentSnapshot adminDoc = await _firestore.collection('admins').doc(currentUser!.uid).get();
      bool isAdmin = adminDoc.exists;
      
      if (!isStudent && !isProvider && !isAdmin) {
        return {'success': false, 'message': 'Unauthorized to view this loan\'s balance'};
      }
      
      // Get all repayment transactions
      final transactionDocs = await _firestore.collection('transactions')
          .where('loanId', isEqualTo: loanId)
          .where('type', isEqualTo: 'REPAYMENT')
          .get();
      
      double totalRepaid = 0;
      for (var doc in transactionDocs.docs) {
        Transaction t = Transaction.fromFirestore(doc);
        totalRepaid += t.amount;
      }
      
      double remainingBalance = loan.amount - totalRepaid;
      
      return {
        'success': true, 
        'data': {
          'loanAmount': loan.amount,
          'totalRepaid': totalRepaid,
          'remainingBalance': remainingBalance > 0 ? remainingBalance : 0,
          'isFullyPaid': remainingBalance <= 0
        }
      };
    } catch (e) {
      return {'success': false, 'message': 'Failed to calculate remaining balance'};
    } finally {
      _setLoading(false);
    }
  }
  
  // Get transaction by ID
  Future<Map<String, dynamic>> getTransactionById(String transactionId) async {
    _setLoading(true);
    try {
      if (currentUser == null) {
        return {'success': false, 'message': 'No user signed in'};
      }
      
      // Get transaction document
      DocumentSnapshot transactionDoc = await _firestore.collection('transactions').doc(transactionId).get();
      if (!transactionDoc.exists) {
        return {'success': false, 'message': 'Transaction not found'};
      }
      
      Transaction transaction = Transaction.fromFirestore(transactionDoc);
      
      // Get loan document to verify authorization
      DocumentSnapshot loanDoc = await _firestore.collection('loans').doc(transaction.loanId).get();
      if (!loanDoc.exists) {
        return {'success': false, 'message': 'Associated loan not found'};
      }
      
      Loan loan = Loan.fromFirestore(loanDoc);
      
      // Verify user is authorized (student, provider, or admin)
      bool isStudent = loan.studentId == currentUser!.uid;
      bool isProvider = loan.providerId == currentUser!.uid;
      DocumentSnapshot adminDoc = await _firestore.collection('admins').doc(currentUser!.uid).get();
      bool isAdmin = adminDoc.exists;
      
      if (!isStudent && !isProvider && !isAdmin) {
        return {'success': false, 'message': 'Unauthorized to view this transaction'};
      }
      
      return {'success': true, 'data': transaction};
    } catch (e) {
      return {'success': false, 'message': 'Failed to retrieve transaction information'};
    } finally {
      _setLoading(false);
    }
  }
  
  // Get all transactions - admin only
  Future<Map<String, dynamic>> getAllTransactions() async {
    _setLoading(true);
    try {
      if (currentUser == null) {
        return {'success': false, 'message': 'No user signed in'};
      }
      
      // Verify user is an admin
      DocumentSnapshot adminDoc = await _firestore.collection('admins').doc(currentUser!.uid).get();
      if (!adminDoc.exists) {
        return {'success': false, 'message': 'Unauthorized access'};
      }
      
      final transactionDocs = await _firestore.collection('transactions').get();
      
      List<Transaction> transactions = [];
      for (var doc in transactionDocs.docs) {
        transactions.add(Transaction.fromFirestore(doc));
      }
      
      return {'success': true, 'data': transactions};
    } catch (e) {
      return {'success': false, 'message': 'Failed to retrieve transactions'};
    } finally {
      _setLoading(false);
    }
  }
}