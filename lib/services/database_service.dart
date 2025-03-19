import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fintech_bridge/models/student_model.dart';
import 'package:fintech_bridge/models/provider_model.dart';
import 'package:fintech_bridge/models/admin_model.dart';

class DatabaseService extends ChangeNotifier {
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
  
  // Get all students
  Future<Map<String, dynamic>> getAllStudents() async {
    _setLoading(true);
    try {
      final studentDocs = await _firestore.collection('students').get();
      
      List<Student> students = [];
      for (var doc in studentDocs.docs) {
        students.add(Student.fromFirestore(doc));
      }
      
      return {'success': true, 'data': students};
    } catch (e) {
      return {'success': false, 'message': 'Failed to retrieve students data'};
    } finally {
      _setLoading(false);
    }
  }

  // Get all providers
  Future<Map<String, dynamic>> getAllProviders() async {
    _setLoading(true);
    try {
      final providerDocs = await _firestore.collection('providers').get();
      
      List<Provider> providers = [];
      for (var doc in providerDocs.docs) {
        providers.add(Provider.fromFirestore(doc));
      }
      
      return {'success': true, 'data': providers};
    } catch (e) {
      return {'success': false, 'message': 'Failed to retrieve providers data'};
    } finally {
      _setLoading(false);
    }
  }

  // Get student by ID
  Future<Map<String, dynamic>> getStudentById(String studentId) async {
    _setLoading(true);
    try {
      DocumentSnapshot doc = await _firestore.collection('students').doc(studentId).get();
      
      if (doc.exists) {
        return {'success': true, 'data': Student.fromFirestore(doc)};
      } else {
        return {'success': false, 'message': 'Student not found'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Failed to retrieve student data'};
    } finally {
      _setLoading(false);
    }
  }

  // Get provider by ID
  Future<Map<String, dynamic>> getProviderById(String providerId) async {
    _setLoading(true);
    try {
      DocumentSnapshot doc = await _firestore.collection('providers').doc(providerId).get();
      
      if (doc.exists) {
        return {'success': true, 'data': Provider.fromFirestore(doc)};
      } else {
        return {'success': false, 'message': 'Provider not found'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Failed to retrieve provider data'};
    } finally {
      _setLoading(false);
    }
  }

  // Get admin by ID
  Future<Map<String, dynamic>> getAdminById(String adminId) async {
    _setLoading(true);
    try {
      DocumentSnapshot doc = await _firestore.collection('admins').doc(adminId).get();
      
      if (doc.exists) {
        return {'success': true, 'data': Admin.fromFirestore(doc)};
      } else {
        return {'success': false, 'message': 'Admin not found'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Failed to retrieve admin data'};
    } finally {
      _setLoading(false);
    }
  }

  // Admin: Get all pending provider approvals - assuming you have a field to track approval status
  Future<Map<String, dynamic>> getPendingProviders() async {
    _setLoading(true);
    try {
      // Check if current user is admin
      if (currentUser == null) {
        return {'success': false, 'message': 'No user signed in'};
      }
      
      // Verify admin role
      DocumentSnapshot adminDoc = await _firestore.collection('admins').doc(currentUser!.uid).get();
      if (!adminDoc.exists) {
        return {'success': false, 'message': 'Unauthorized access'};
      }
      
      // Query providers that need approval
      // Note: You might need to add an "approved" field to your Provider model
      // This is an example query - adjust according to your actual implementation
      final pendingProvidersDocs = await _firestore.collection('providers')
          .where('approved', isEqualTo: false)
          .get();
      
      List<Provider> pendingProviders = [];
      for (var doc in pendingProvidersDocs.docs) {
        pendingProviders.add(Provider.fromFirestore(doc));
      }
      
      return {'success': true, 'data': pendingProviders};
    } catch (e) {
      return {'success': false, 'message': 'Failed to retrieve pending providers'};
    } finally {
      _setLoading(false);
    }
  }

  // Admin: Approve or reject provider
  Future<Map<String, dynamic>> updateProviderApprovalStatus(String providerId, bool isApproved) async {
    _setLoading(true);
    try {
      // Check if current user is admin
      if (currentUser == null) {
        return {'success': false, 'message': 'No user signed in'};
      }
      
      // Verify admin role
      DocumentSnapshot adminDoc = await _firestore.collection('admins').doc(currentUser!.uid).get();
      if (!adminDoc.exists) {
        return {'success': false, 'message': 'Unauthorized access'};
      }
      
      // Get provider document
      DocumentSnapshot providerDoc = await _firestore.collection('providers').doc(providerId).get();
      if (!providerDoc.exists) {
        return {'success': false, 'message': 'Provider not found'};
      }
      
      // Update approval status
      // Note: You might need to add an "approved" field to your Provider model
      await _firestore.collection('providers').doc(providerId).update({
        'approved': isApproved,
        'updatedAt': DateTime.now(),
      });
      
      return {
        'success': true, 
        'message': isApproved ? 'Provider approved successfully' : 'Provider rejected'
      };
    } catch (e) {
      return {'success': false, 'message': 'Failed to update provider status'};
    } finally {
      _setLoading(false);
    }
  }

  // Get providers filtered by loan type
  Future<Map<String, dynamic>> getProvidersByLoanType(String loanType) async {
    _setLoading(true);
    try {
      final providerDocs = await _firestore.collection('providers')
          .where('loanTypes', arrayContains: loanType)
          .get();
      
      List<Provider> providers = [];
      for (var doc in providerDocs.docs) {
        providers.add(Provider.fromFirestore(doc));
      }
      
      return {'success': true, 'data': providers};
    } catch (e) {
      return {'success': false, 'message': 'Failed to retrieve providers data'};
    } finally {
      _setLoading(false);
    }
  }

  // Get providers sorted by interest rate
  Future<Map<String, dynamic>> getProvidersSortedByInterestRate() async {
    _setLoading(true);
    try {
      final providerDocs = await _firestore.collection('providers')
          .orderBy('interestRate', descending: false)
          .get();
      
      List<Provider> providers = [];
      for (var doc in providerDocs.docs) {
        providers.add(Provider.fromFirestore(doc));
      }
      
      return {'success': true, 'data': providers};
    } catch (e) {
      return {'success': false, 'message': 'Failed to retrieve providers data'};
    } finally {
      _setLoading(false);
    }
  }
}