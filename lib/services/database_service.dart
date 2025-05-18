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
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
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
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {'success': false, 'message': 'Failed to retrieve providers data'};
    } finally {
      _setLoading(false);
    }
  }

  // Get student by ID
  Future<Map<String, dynamic>> getStudentById(String studentId) async {
    _setLoading(true);
    try {
      DocumentSnapshot doc =
          await _firestore.collection('students').doc(studentId).get();

      if (doc.exists) {
        return {'success': true, 'data': Student.fromFirestore(doc)};
      } else {
        return {'success': false, 'message': 'Student not found'};
      }
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {'success': false, 'message': 'Failed to retrieve student data'};
    } finally {
      _setLoading(false);
    }
  }

  // Get provider by ID
  Future<Map<String, dynamic>> getProviderById(String providerId) async {
    _setLoading(true);
    try {
      DocumentSnapshot doc =
          await _firestore.collection('providers').doc(providerId).get();

      if (doc.exists) {
        return {'success': true, 'data': Provider.fromFirestore(doc)};
      } else {
        return {'success': false, 'message': 'Provider not found'};
      }
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {'success': false, 'message': 'Failed to retrieve provider data'};
    } finally {
      _setLoading(false);
    }
  }

  // Get admin by ID
  Future<Map<String, dynamic>> getAdminById(String adminId) async {
    _setLoading(true);
    try {
      DocumentSnapshot doc =
          await _firestore.collection('admins').doc(adminId).get();

      if (doc.exists) {
        return {'success': true, 'data': Admin.fromFirestore(doc)};
      } else {
        return {'success': false, 'message': 'Admin not found'};
      }
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {'success': false, 'message': 'Failed to retrieve admin data'};
    } finally {
      _setLoading(false);
    }
  }

  // Get current user profile
  Future<Map<String, dynamic>> getCurrentUserProfile() async {
    _setLoading(true);
    try {
      if (currentUser == null) {
        return {'success': false, 'message': 'No user is currently signed in'};
      }

      // Check if admin
      DocumentSnapshot adminDoc =
          await _firestore.collection('admins').doc(currentUser!.uid).get();
      if (adminDoc.exists) {
        return {
          'success': true,
          'data': Admin.fromFirestore(adminDoc),
          'role': 'admin'
        };
      }

      // Check if student
      DocumentSnapshot studentDoc =
          await _firestore.collection('students').doc(currentUser!.uid).get();
      if (studentDoc.exists) {
        Student student = Student.fromFirestore(studentDoc);
        return {
          'success': true,
          'data': student,
          'role': 'student',
          'verified': student.verified
        };
      }

      // Check if provider
      DocumentSnapshot providerDoc =
          await _firestore.collection('providers').doc(currentUser!.uid).get();
      if (providerDoc.exists) {
        Provider provider = Provider.fromFirestore(providerDoc);
        return {
          'success': true,
          'data': provider,
          'role': 'provider',
          'verified': provider.verified,
          'approved': provider.approved
        };
      }

      return {'success': false, 'message': 'User profile not found'};
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {'success': false, 'message': 'Failed to retrieve user profile'};
    } finally {
      _setLoading(false);
    }
  }

  // Admin: Get all pending student verifications
  Future<Map<String, dynamic>> getPendingStudentVerifications() async {
    _setLoading(true);
    try {
      // Check if current user is admin
      if (currentUser == null) {
        return {'success': false, 'message': 'No user signed in'};
      }

      // Verify admin role
      DocumentSnapshot adminDoc =
          await _firestore.collection('admins').doc(currentUser!.uid).get();
      if (!adminDoc.exists) {
        return {'success': false, 'message': 'Unauthorized access'};
      }

      // Query students that need verification and have uploaded documents
      final pendingStudentsDocs = await _firestore
          .collection('students')
          .where('verified', isEqualTo: false)
          .where('identificationImages',
              isNull: false) // Only students who uploaded documents
          .get();

      List<Student> pendingStudents = [];
      for (var doc in pendingStudentsDocs.docs) {
        // Additional check to ensure identificationImages is not empty
        Map<String, dynamic> data = doc.data();
        if (data['identificationImages'] != null &&
            (data['identificationImages'] as List).isNotEmpty) {
          pendingStudents.add(Student.fromFirestore(doc));
        }
      }

      return {'success': true, 'data': pendingStudents};
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {
        'success': false,
        'message': 'Failed to retrieve pending student verifications'
      };
    } finally {
      _setLoading(false);
    }
  }

  // Admin: Get all pending provider approvals
  Future<Map<String, dynamic>> getPendingProviders() async {
    _setLoading(true);
    try {
      // Check if current user is admin
      if (currentUser == null) {
        return {'success': false, 'message': 'No user signed in'};
      }

      // Verify admin role
      DocumentSnapshot adminDoc =
          await _firestore.collection('admins').doc(currentUser!.uid).get();
      if (!adminDoc.exists) {
        return {'success': false, 'message': 'Unauthorized access'};
      }

      // Query providers that need approval and verification
      final pendingProvidersDocs = await _firestore
          .collection('providers')
          .where('approved', isEqualTo: false)
          .where('identificationImages',
              isNull: false) // Only providers who uploaded documents
          .get();

      List<Provider> pendingProviders = [];
      for (var doc in pendingProvidersDocs.docs) {
        // Additional check to ensure identificationImages is not empty
        Map<String, dynamic> data = doc.data();
        if (data['identificationImages'] != null &&
            (data['identificationImages'] as List).isNotEmpty) {
          pendingProviders.add(Provider.fromFirestore(doc));
        }
      }

      return {'success': true, 'data': pendingProviders};
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {
        'success': false,
        'message': 'Failed to retrieve pending providers'
      };
    } finally {
      _setLoading(false);
    }
  }

  // Admin: Verify student account
  Future<Map<String, dynamic>> verifyStudentAccount(String studentId) async {
    _setLoading(true);
    try {
      // Check if current user is admin
      if (currentUser == null) {
        return {'success': false, 'message': 'No user signed in'};
      }

      // Verify admin role
      DocumentSnapshot adminDoc =
          await _firestore.collection('admins').doc(currentUser!.uid).get();
      if (!adminDoc.exists) {
        return {'success': false, 'message': 'Unauthorized access'};
      }

      // Get student document
      DocumentSnapshot studentDoc =
          await _firestore.collection('students').doc(studentId).get();
      if (!studentDoc.exists) {
        return {'success': false, 'message': 'Student not found'};
      }

      // Update verification status
      await _firestore.collection('students').doc(studentId).update({
        'verified': true,
        'verifiedAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      });

      // Also update in the users collection
      await _firestore.collection('users').doc(studentId).update({
        'verified': true,
      });

      return {
        'success': true,
        'message': 'Student account verified successfully'
      };
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {'success': false, 'message': 'Failed to verify student account'};
    } finally {
      _setLoading(false);
    }
  }

  // Admin: Approve or reject provider
  Future<Map<String, dynamic>> updateProviderApprovalStatus(
      String providerId, bool isApproved) async {
    _setLoading(true);
    try {
      // Check if current user is admin
      if (currentUser == null) {
        return {'success': false, 'message': 'No user signed in'};
      }

      // Verify admin role
      DocumentSnapshot adminDoc =
          await _firestore.collection('admins').doc(currentUser!.uid).get();
      if (!adminDoc.exists) {
        return {'success': false, 'message': 'Unauthorized access'};
      }

      // Get provider document
      DocumentSnapshot providerDoc =
          await _firestore.collection('providers').doc(providerId).get();
      if (!providerDoc.exists) {
        return {'success': false, 'message': 'Provider not found'};
      }

      // Update approval status
      await _firestore.collection('providers').doc(providerId).update({
        'approved': isApproved,
        'verified': isApproved, // Also set verified to true if approved
        'verifiedAt': isApproved ? DateTime.now() : null,
        'updatedAt': DateTime.now(),
      });

      // Also update in the users collection
      await _firestore.collection('users').doc(providerId).update({
        'approved': isApproved,
        'verified': isApproved,
      });

      return {
        'success': true,
        'message':
            isApproved ? 'Provider approved successfully' : 'Provider rejected'
      };
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {'success': false, 'message': 'Failed to update provider status'};
    } finally {
      _setLoading(false);
    }
  }

  // Get verified providers
  Future<Map<String, dynamic>> getVerifiedProviders() async {
    _setLoading(true);
    try {
      final providerDocs = await _firestore
          .collection('providers')
          .where('verified', isEqualTo: true)
          .where('approved', isEqualTo: true)
          .get();

      List<Provider> providers = [];
      for (var doc in providerDocs.docs) {
        providers.add(Provider.fromFirestore(doc));
      }

      return {'success': true, 'data': providers};
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {
        'success': false,
        'message': 'Failed to retrieve verified providers'
      };
    } finally {
      _setLoading(false);
    }
  }

  // Get providers filtered by loan type
  Future<Map<String, dynamic>> getProvidersByLoanType(String loanType) async {
    _setLoading(true);
    try {
      final providerDocs = await _firestore
          .collection('providers')
          .where('verified', isEqualTo: true)
          .where('approved', isEqualTo: true)
          .where('loanTypes', arrayContains: loanType)
          .get();

      List<Provider> providers = [];
      for (var doc in providerDocs.docs) {
        providers.add(Provider.fromFirestore(doc));
      }

      return {'success': true, 'data': providers};
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {'success': false, 'message': 'Failed to retrieve providers data'};
    } finally {
      _setLoading(false);
    }
  }

  // Get providers sorted by interest rate
  Future<Map<String, dynamic>> getProvidersSortedByInterestRate() async {
    _setLoading(true);
    try {
      final providerDocs = await _firestore
          .collection('providers')
          .where('verified', isEqualTo: true)
          .where('approved', isEqualTo: true)
          .orderBy('interestRate', descending: false)
          .get();

      List<Provider> providers = [];
      for (var doc in providerDocs.docs) {
        providers.add(Provider.fromFirestore(doc));
      }

      return {'success': true, 'data': providers};
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {'success': false, 'message': 'Failed to retrieve providers data'};
    } finally {
      _setLoading(false);
    }
  }

  // Update student profile
  Future<Map<String, dynamic>> updateStudentProfile(
      String studentId, Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      // Check if current user is the student or an admin
      if (currentUser == null) {
        return {'success': false, 'message': 'No user signed in'};
      }

      bool isAdmin =
          (await _firestore.collection('admins').doc(currentUser!.uid).get())
              .exists;

      if (currentUser!.uid != studentId && !isAdmin) {
        return {'success': false, 'message': 'Unauthorized access'};
      }

      // Update student profile
      await _firestore.collection('students').doc(studentId).update({
        ...data,
        'updatedAt': DateTime.now(),
      });

      // If fullName is updated, also update it in users collection
      if (data.containsKey('fullName')) {
        await _firestore
            .collection('users')
            .doc(studentId)
            .update({'fullName': data['fullName']});
      }

      // Get updated student
      DocumentSnapshot updatedDoc =
          await _firestore.collection('students').doc(studentId).get();
      Student updatedStudent = Student.fromFirestore(updatedDoc);

      return {
        'success': true,
        'message': 'Profile updated successfully',
        'data': updatedStudent
      };
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {'success': false, 'message': 'Failed to update profile'};
    } finally {
      _setLoading(false);
    }
  }

  // Update provider profile
  Future<Map<String, dynamic>> updateProviderProfile(
      String providerId, Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      // Check if current user is the provider or an admin
      if (currentUser == null) {
        return {'success': false, 'message': 'No user signed in'};
      }

      bool isAdmin =
          (await _firestore.collection('admins').doc(currentUser!.uid).get())
              .exists;

      if (currentUser!.uid != providerId && !isAdmin) {
        return {'success': false, 'message': 'Unauthorized access'};
      }

      // Update provider profile
      await _firestore.collection('providers').doc(providerId).update({
        ...data,
        'updatedAt': DateTime.now(),
      });

      // If businessName is updated, also update it in users collection
      if (data.containsKey('businessName')) {
        await _firestore
            .collection('users')
            .doc(providerId)
            .update({'fullName': data['businessName']});
      }

      // Get updated provider
      DocumentSnapshot updatedDoc =
          await _firestore.collection('providers').doc(providerId).get();
      Provider updatedProvider = Provider.fromFirestore(updatedDoc);

      return {
        'success': true,
        'message': 'Profile updated successfully',
        'data': updatedProvider
      };
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {'success': false, 'message': 'Failed to update profile'};
    } finally {
      _setLoading(false);
    }
  }

  // Get all available loan types (unique loan types from all providers)
  Future<Map<String, dynamic>> getAllLoanTypes() async {
    _setLoading(true);
    try {
      final providerDocs = await _firestore
          .collection('providers')
          .where('verified', isEqualTo: true)
          .where('approved', isEqualTo: true)
          .get();

      Set<String> loanTypes = {};
      for (var doc in providerDocs.docs) {
        Provider provider = Provider.fromFirestore(doc);
        if (provider.loanTypes.isNotEmpty) {
          loanTypes.addAll(provider.loanTypes);
        }
      }

      return {'success': true, 'data': loanTypes.toList()};
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {'success': false, 'message': 'Failed to retrieve loan types'};
    } finally {
      _setLoading(false);
    }
  }

  // Get provider statistics for admin dashboard
  Future<Map<String, dynamic>> getProviderStatistics() async {
    _setLoading(true);
    try {
      // Check if current user is admin
      if (currentUser == null) {
        return {'success': false, 'message': 'No user signed in'};
      }

      // Verify admin role
      DocumentSnapshot adminDoc =
          await _firestore.collection('admins').doc(currentUser!.uid).get();
      if (!adminDoc.exists) {
        return {'success': false, 'message': 'Unauthorized access'};
      }

      // Get all providers
      final allProvidersDocs = await _firestore.collection('providers').get();

      // Get verified providers
      final verifiedProvidersDocs = await _firestore
          .collection('providers')
          .where('verified', isEqualTo: true)
          .get();

      // Get approved providers
      final approvedProvidersDocs = await _firestore
          .collection('providers')
          .where('approved', isEqualTo: true)
          .get();

      // Get pending providers (have documents but not approved)
      final pendingProvidersDocs = await _firestore
          .collection('providers')
          .where('approved', isEqualTo: false)
          .where('identificationImages', isNull: false)
          .get();

      Map<String, dynamic> statistics = {
        'totalProviders': allProvidersDocs.docs.length,
        'verifiedProviders': verifiedProvidersDocs.docs.length,
        'approvedProviders': approvedProvidersDocs.docs.length,
        'pendingProviders': pendingProvidersDocs.docs.length,
      };

      return {'success': true, 'data': statistics};
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {
        'success': false,
        'message': 'Failed to retrieve provider statistics'
      };
    } finally {
      _setLoading(false);
    }
  }

  // Get student statistics for admin dashboard
  Future<Map<String, dynamic>> getStudentStatistics() async {
    _setLoading(true);
    try {
      // Check if current user is admin
      if (currentUser == null) {
        return {'success': false, 'message': 'No user signed in'};
      }

      // Verify admin role
      DocumentSnapshot adminDoc =
          await _firestore.collection('admins').doc(currentUser!.uid).get();
      if (!adminDoc.exists) {
        return {'success': false, 'message': 'Unauthorized access'};
      }

      // Get all students
      final allStudentsDocs = await _firestore.collection('students').get();

      // Get verified students
      final verifiedStudentsDocs = await _firestore
          .collection('students')
          .where('verified', isEqualTo: true)
          .get();

      // Get pending students (have documents but not verified)
      final pendingStudentsDocs = await _firestore
          .collection('students')
          .where('verified', isEqualTo: false)
          .where('identificationImages', isNull: false)
          .get();

      Map<String, dynamic> statistics = {
        'totalStudents': allStudentsDocs.docs.length,
        'verifiedStudents': verifiedStudentsDocs.docs.length,
        'pendingStudents': pendingStudentsDocs.docs.length,
      };

      return {'success': true, 'data': statistics};
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {
        'success': false,
        'message': 'Failed to retrieve student statistics'
      };
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> getFeaturedLoanProviders() async {
  _setLoading(true);
  try {
    // Query all loans
    final loanDocs = await _firestore.collection('loans').get();
    
    // Map to track provider selection frequency
    Map<String, int> providerFrequency = {};
    
    // Count how many times each provider has been selected
    for (var doc in loanDocs.docs) {
      final Map data = doc.data();
      final String providerId = data['providerId'] ?? '';
      
      if (providerId.isNotEmpty) {
        providerFrequency[providerId] = (providerFrequency[providerId] ?? 0) + 1;
      }
    }
    
    // If no loans exist yet
    if (providerFrequency.isEmpty) {
      // Return some default verified and approved providers sorted by interest rate
      final defaultProviderDocs = await _firestore
          .collection('providers')
          .where('verified', isEqualTo: true)
          .where('approved', isEqualTo: true)
          .orderBy('interestRate', descending: false)
          .limit(5)
          .get();
      
      List<Provider> defaultProviders = [];
      for (var doc in defaultProviderDocs.docs) {
        defaultProviders.add(Provider.fromFirestore(doc));
      }
      
      return {'success': true, 'data': defaultProviders};
    }
    
    // Sort providers by frequency (most selected first)
    List<MapEntry<String, int>> sortedProviders = providerFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // Get the top 5 provider IDs
    List<String> topProviderIds = sortedProviders
        .take(5)
        .map((entry) => entry.key)
        .toList();
    
    // Fetch the actual provider data for these IDs
    List<Provider> featuredProviders = [];
    
    for (String providerId in topProviderIds) {
      DocumentSnapshot providerDoc = 
          await _firestore.collection('providers').doc(providerId).get();
      
      if (providerDoc.exists) {
        Provider provider = Provider.fromFirestore(providerDoc);
        
        // Only include verified and approved providers
        if (provider.verified && provider.approved) {
          featuredProviders.add(provider);
        }
      }
    }
    
    // If we couldn't get enough featured providers, supplement with additional providers
    if (featuredProviders.length < 5) {
      // Get IDs of already added providers to avoid duplicates
      Set<String> existingIds = featuredProviders.map((p) => p.id).toSet();
      
      // Query for additional providers
      final additionalProviderDocs = await _firestore
          .collection('providers')
          .where('verified', isEqualTo: true)
          .where('approved', isEqualTo: true)
          .orderBy('interestRate', descending: false)
          .limit(5 - featuredProviders.length)
          .get();
      
      for (var doc in additionalProviderDocs.docs) {
        if (!existingIds.contains(doc.id)) {
          featuredProviders.add(Provider.fromFirestore(doc));
          existingIds.add(doc.id);
        }
      }
    }
    
    return {'success': true, 'data': featuredProviders};
  } catch (e) {
    if (e is FirebaseException && e.code == 'unavailable') {
      return {'success': false, 'message': 'No internet connection'};
    }
    return {'success': false, 'message': 'Failed to retrieve featured loan providers'};
  } finally {
    _setLoading(false);
  }
}
}
