import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fintech_bridge/models/student_model.dart';
import 'package:fintech_bridge/models/provider_model.dart';
import 'package:fintech_bridge/models/admin_model.dart';
import 'package:fintech_bridge/services/notification_service.dart';

class DatabaseService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();
  
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
      await _firestore.collection('providers').doc(providerId).update({
        'approved': isApproved,
        'updatedAt': DateTime.now(),
      });
      
      // Send notification to provider about approval status
      await _notificationService.createNotification(
        userId: providerId,
        title: isApproved ? 'Account Approved' : 'Account Rejected',
        message: isApproved 
          ? 'Your provider account has been approved. You can now offer loans on the platform.' 
          : 'Your provider account has been rejected. Please contact support for more information.',
        relatedEntityId: providerId,
        type: 'ACCOUNT_STATUS',
      );
      
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

  // Update student profile
  Future<Map<String, dynamic>> updateStudentProfile(String studentId, Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      // Check if current user is the student or an admin
      if (currentUser == null) {
        return {'success': false, 'message': 'No user signed in'};
      }
      
      bool isAdmin = (await _firestore.collection('admins').doc(currentUser!.uid).get()).exists;
      
      if (currentUser!.uid != studentId && !isAdmin) {
        return {'success': false, 'message': 'Unauthorized access'};
      }
      
      // Update student profile
      await _firestore.collection('students').doc(studentId).update({
        ...data,
        'updatedAt': DateTime.now(),
      });
      
      // Send notification to the student
      await _notificationService.createNotification(
        userId: studentId,
        title: 'Profile Updated',
        message: 'Your profile information has been updated successfully.',
        relatedEntityId: studentId,
        type: 'PROFILE_UPDATE',
      );
      
      return {'success': true, 'message': 'Profile updated successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to update profile'};
    } finally {
      _setLoading(false);
    }
  }

  // Update provider profile
  Future<Map<String, dynamic>> updateProviderProfile(String providerId, Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      // Check if current user is the provider or an admin
      if (currentUser == null) {
        return {'success': false, 'message': 'No user signed in'};
      }
      
      bool isAdmin = (await _firestore.collection('admins').doc(currentUser!.uid).get()).exists;
      
      if (currentUser!.uid != providerId && !isAdmin) {
        return {'success': false, 'message': 'Unauthorized access'};
      }
      
      // Update provider profile
      await _firestore.collection('providers').doc(providerId).update({
        ...data,
        'updatedAt': DateTime.now(),
      });
      
      // Send notification to the provider
      await _notificationService.createNotification(
        userId: providerId,
        title: 'Profile Updated',
        message: 'Your provider profile has been updated successfully.',
        relatedEntityId: providerId,
        type: 'PROFILE_UPDATE',
      );
      
      return {'success': true, 'message': 'Profile updated successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to update profile'};
    } finally {
      _setLoading(false);
    }
  }
  
  // Verify student account
  Future<Map<String, dynamic>> verifyStudentAccount(String studentId) async {
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
      
      // Get student document
      DocumentSnapshot studentDoc = await _firestore.collection('students').doc(studentId).get();
      if (!studentDoc.exists) {
        return {'success': false, 'message': 'Student not found'};
      }
      
      // Update verification status
      await _firestore.collection('students').doc(studentId).update({
        'verified': true,
        'verifiedAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      });
      
      // Send notification to the student
      await _notificationService.createNotification(
        userId: studentId,
        title: 'Account Verified',
        message: 'Your student account has been verified. You can now request loans on the platform.',
        relatedEntityId: studentId,
        type: 'ACCOUNT_STATUS',
      );
      
      return {'success': true, 'message': 'Student account verified successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to verify student account'};
    } finally {
      _setLoading(false);
    }
  }
}
