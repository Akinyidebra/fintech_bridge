import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fintech_bridge/models/loan_model.dart';
import 'package:fintech_bridge/models/transaction_model.dart';

class LoanService extends ChangeNotifier {
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

  // Create loan request
  Future<Map<String, dynamic>> createLoanRequest({
    required String providerId,
    required double amount,
    required String purpose,
    required DateTime dueDate,
  }) async {
    _setLoading(true);
    try {
      if (currentUser == null) {
        return {'success': false, 'message': 'No user signed in'};
      }
      
      // Verify user is a student
      DocumentSnapshot studentDoc = await _firestore.collection('students').doc(currentUser!.uid).get();
      if (!studentDoc.exists) {
        return {'success': false, 'message': 'Only students can request loans'};
      }
      
      // Create loan document
      Loan loan = Loan(
        id: '', // Firestore will generate this
        studentId: currentUser!.uid,
        providerId: providerId,
        amount: amount,
        status: 'PENDING',
        purpose: purpose,
        dueDate: dueDate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Add loan to Firestore
      DocumentReference loanRef = await _firestore.collection('loans').add(loan.toMap());
      
      // Get the loan with generated ID
      Loan createdLoan = Loan(
        id: loanRef.id,
        studentId: loan.studentId,
        providerId: loan.providerId,
        amount: loan.amount,
        status: loan.status,
        purpose: loan.purpose,
        dueDate: loan.dueDate,
        createdAt: loan.createdAt,
        updatedAt: loan.updatedAt,
      );
      
      return {'success': true, 'message': 'Loan request submitted successfully', 'loan': createdLoan};
    } catch (e) {
      return {'success': false, 'message': 'Failed to create loan request. Please try again.'};
    } finally {
      _setLoading(false);
    }
  }
  
  // Get loan by ID
  Future<Map<String, dynamic>> getLoanById(String loanId) async {
    _setLoading(true);
    try {
      DocumentSnapshot doc = await _firestore.collection('loans').doc(loanId).get();
      
      if (doc.exists) {
        return {'success': true, 'data': Loan.fromFirestore(doc)};
      } else {
        return {'success': false, 'message': 'Loan not found'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Failed to retrieve loan information'};
    } finally {
      _setLoading(false);
    }
  }
  
  // Get loans for student
  Future<Map<String, dynamic>> getStudentLoans() async {
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
      
      final loanDocs = await _firestore.collection('loans')
          .where('studentId', isEqualTo: currentUser!.uid)
          .get();
      
      List<Loan> loans = [];
      for (var doc in loanDocs.docs) {
        loans.add(Loan.fromFirestore(doc));
      }
      
      return {'success': true, 'data': loans};
    } catch (e) {
      return {'success': false, 'message': 'Failed to retrieve loan information'};
    } finally {
      _setLoading(false);
    }
  }
  
  // Get loans for provider
  Future<Map<String, dynamic>> getProviderLoans() async {
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
      
      final loanDocs = await _firestore.collection('loans')
          .where('providerId', isEqualTo: currentUser!.uid)
          .get();
      
      List<Loan> loans = [];
      for (var doc in loanDocs.docs) {
        loans.add(Loan.fromFirestore(doc));
      }
      
      return {'success': true, 'data': loans};
    } catch (e) {
      return {'success': false, 'message': 'Failed to retrieve loan information'};
    } finally {
      _setLoading(false);
    }
  }
  
  // Update loan status - for providers
  Future<Map<String, dynamic>> updateLoanStatus(String loanId, String status) async {
    _setLoading(true);
    try {
      if (currentUser == null) {
        return {'success': false, 'message': 'No user signed in'};
      }
      
      // Verify status is valid
      if (!['APPROVED', 'REJECTED', 'PAID'].contains(status)) {
        return {'success': false, 'message': 'Invalid loan status'};
      }
      
      // Get loan document
      DocumentSnapshot loanDoc = await _firestore.collection('loans').doc(loanId).get();
      if (!loanDoc.exists) {
        return {'success': false, 'message': 'Loan not found'};
      }
      
      Loan loan = Loan.fromFirestore(loanDoc);
      
      // Verify user is the loan provider or an admin
      bool isProvider = loan.providerId == currentUser!.uid;
      DocumentSnapshot adminDoc = await _firestore.collection('admins').doc(currentUser!.uid).get();
      bool isAdmin = adminDoc.exists;
      
      if (!isProvider && !isAdmin) {
        return {'success': false, 'message': 'Unauthorized to update this loan'};
      }
      
      // Update loan status
      await _firestore.collection('loans').doc(loanId).update({
        'status': status,
        'updatedAt': DateTime.now(),
      });
      
      // If loan is approved, create a disbursement transaction
      if (status == 'APPROVED') {
        Transaction transaction = Transaction(
          id: '', // Firestore will generate this
          loanId: loanId,
          amount: loan.amount,
          type: 'DISBURSEMENT',
          createdAt: DateTime.now(),
        );
        
        await _firestore.collection('transactions').add(transaction.toMap());
      }
      
      String message;
      switch (status) {
        case 'APPROVED':
          message = 'Loan approved successfully';
          break;
        case 'REJECTED':
          message = 'Loan rejected';
          break;
        case 'PAID':
          message = 'Loan marked as paid';
          break;
        default:
          message = 'Loan status updated';
      }
      
      return {'success': true, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'Failed to update loan status. Please try again.'};
    } finally {
      _setLoading(false);
    }
  }
  
  // Get all loans - for admin
  Future<Map<String, dynamic>> getAllLoans() async {
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
      
      final loanDocs = await _firestore.collection('loans').get();
      
      List<Loan> loans = [];
      for (var doc in loanDocs.docs) {
        loans.add(Loan.fromFirestore(doc));
      }
      
      return {'success': true, 'data': loans};
    } catch (e) {
      return {'success': false, 'message': 'Failed to retrieve loans'};
    } finally {
      _setLoading(false);
    }
  }
  
  // Get loans with specific status
  Future<Map<String, dynamic>> getLoansByStatus(String status) async {
    _setLoading(true);
    try {
      if (currentUser == null) {
        return {'success': false, 'message': 'No user signed in'};
      }
      
      // Verify status is valid
      if (!['PENDING', 'APPROVED', 'REJECTED', 'PAID'].contains(status)) {
        return {'success': false, 'message': 'Invalid loan status'};
      }
      
      final loanDocs = await _firestore.collection('loans')
          .where('status', isEqualTo: status)
          .get();
      
      List<Loan> loans = [];
      for (var doc in loanDocs.docs) {
        loans.add(Loan.fromFirestore(doc));
      }
      
      return {'success': true, 'data': loans};
    } catch (e) {
      return {'success': false, 'message': 'Failed to retrieve loans'};
    } finally {
      _setLoading(false);
    }
  }
  
  // Get overdue loans
  Future<Map<String, dynamic>> getOverdueLoans() async {
    _setLoading(true);
    try {
      if (currentUser == null) {
        return {'success': false, 'message': 'No user signed in'};
      }
      
      final now = DateTime.now();
      
      // Get loans with APPROVED status and due date before now
      final loanDocs = await _firestore.collection('loans')
          .where('status', isEqualTo: 'APPROVED')
          .where('dueDate', isLessThan: now)
          .get();
      
      List<Loan> loans = [];
      for (var doc in loanDocs.docs) {
        loans.add(Loan.fromFirestore(doc));
      }
      
      return {'success': true, 'data': loans};
    } catch (e) {
      return {'success': false, 'message': 'Failed to retrieve overdue loans'};
    } finally {
      _setLoading(false);
    }
  }
  
  // Get loan transactions
  Future<Map<String, dynamic>> getLoanTransactions(String loanId) async {
    _setLoading(true);
    try {
      if (currentUser == null) {
        return {'success': false, 'message': 'No user signed in'};
      }
      
      // Get loan document to verify authorization
      DocumentSnapshot loanDoc = await _firestore.collection('loans').doc(loanId).get();
      if (!loanDoc.exists) {
        return {'success': false, 'message': 'Loan not found'};
      }
      
      Loan loan = Loan.fromFirestore(loanDoc);
      
      // Verify user is the loan student, provider, or an admin
      bool isStudent = loan.studentId == currentUser!.uid;
      bool isProvider = loan.providerId == currentUser!.uid;
      DocumentSnapshot adminDoc = await _firestore.collection('admins').doc(currentUser!.uid).get();
      bool isAdmin = adminDoc.exists;
      
      if (!isStudent && !isProvider && !isAdmin) {
        return {'success': false, 'message': 'Unauthorized to view this loan\'s transactions'};
      }
      
      // Get transactions for the loan
      final transactionDocs = await _firestore.collection('transactions')
          .where('loanId', isEqualTo: loanId)
          .get();
      
      List<Transaction> transactions = [];
      for (var doc in transactionDocs.docs) {
        transactions.add(Transaction.fromFirestore(doc));
      }
      
      return {'success': true, 'data': transactions};
    } catch (e) {
      return {'success': false, 'message': 'Failed to retrieve loan transactions'};
    } finally {
      _setLoading(false);
    }
  }
}