import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fintech_bridge/services/cloudinary.dart';
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
          'verified': provider.verified
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

      // Query providers that need verification
      final pendingProvidersDocs = await _firestore
          .collection('providers')
          .where('verified', isEqualTo: false)
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
      String providerId, bool isVerified) async {
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
        'verified': isVerified,
        'verifiedAt': isVerified ? DateTime.now() : null,
        'updatedAt': DateTime.now(),
      });

      // Also update in the users collection
      await _firestore.collection('users').doc(providerId).update({
        'verified': isVerified,
      });

      return {
        'success': true,
        'message':
            isVerified ? 'Provider verified successfully' : 'Provider rejected'
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

  // Get providers filtered by loan type
  Future<Map<String, dynamic>> getProvidersByLoanType(String loanType) async {
    _setLoading(true);
    try {
      final providerDocs = await _firestore
          .collection('providers')
          .where('verified', isEqualTo: true)
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

  // Update user profile (works for both students and providers)
  Future<Map<String, dynamic>> updateUserProfile(
      Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      if (currentUser == null) {
        return {'success': false, 'message': 'No user signed in'};
      }

      // Get current user profile to determine role
      final profileResult = await getCurrentUserProfile();
      if (!profileResult['success']) {
        return profileResult;
      }

      String role = profileResult['role'];
      String userId = currentUser!.uid;

      // Update the appropriate collection based on user role
      if (role == 'student') {
        await _firestore.collection('students').doc(userId).update({
          ...data,
          'updatedAt': DateTime.now(),
        });

        // If fullName is updated, also update it in users collection
        if (data.containsKey('fullName')) {
          await _firestore
              .collection('users')
              .doc(userId)
              .update({'fullName': data['fullName']});
        }
      } else if (role == 'provider') {
        await _firestore.collection('providers').doc(userId).update({
          ...data,
          'updatedAt': DateTime.now(),
        });

        // If businessName is updated, also update it in users collection
        if (data.containsKey('businessName')) {
          await _firestore
              .collection('users')
              .doc(userId)
              .update({'fullName': data['businessName']});
        }
      } else {
        return {'success': false, 'message': 'Invalid user role'};
      }

      return {'success': true, 'message': 'Profile updated successfully'};
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {'success': false, 'message': 'Failed to update profile'};
    } finally {
      _setLoading(false);
    }
  }

  // Alternative version using batch upload for better performance
  Future<Map<String, dynamic>> uploadIdentificationImages({
    required File nationalIdFront,
    required File nationalIdBack,
    required File studentIdFront,
    required File studentIdBack,
  }) async {
    _setLoading(true);
    try {
      if (currentUser == null) {
        return {'success': false, 'message': 'No user signed in'};
      }

      // Get current user profile to determine role
      final profileResult = await getCurrentUserProfile();
      if (!profileResult['success']) {
        return profileResult;
      }

      String role = profileResult['role'];
      String userId = currentUser!.uid;

      // Upload all images using batch upload
      final uploadResults = await Cloudinary.uploadIdentificationImages(
        userId: userId,
        nationalIdFront: nationalIdFront,
        nationalIdBack: nationalIdBack,
        studentIdFront: studentIdFront,
        studentIdBack: studentIdBack,
      );

      // Check if all uploads were successful
      final failedUploads = uploadResults.entries
          .where((entry) => entry.value == null)
          .map((entry) => entry.key)
          .toList();

      if (failedUploads.isNotEmpty) {
        return {
          'success': false,
          'message': 'Failed to upload: ${failedUploads.join(', ')}'
        };
      }

      // Prepare identification images data with Cloudinary URLs
      Map<String, dynamic> identificationData = {
        'nationalIdFront': uploadResults['nationalIdFront']!,
        'nationalIdBack': uploadResults['nationalIdBack']!,
        'studentIdFront': uploadResults['studentIdFront']!,
        'studentIdBack': uploadResults['studentIdBack']!,
        'uploadedAt': DateTime.now(),
      };

      // Update the appropriate collection based on user role
      if (role == 'student') {
        await _firestore.collection('students').doc(userId).update({
          'identificationImages': identificationData,
          'updatedAt': DateTime.now(),
        });
      } else if (role == 'provider') {
        await _firestore.collection('providers').doc(userId).update({
          'identificationImages': identificationData,
          'updatedAt': DateTime.now(),
        });
      } else {
        return {'success': false, 'message': 'Invalid user role'};
      }

      return {
        'success': true,
        'message': 'Documents uploaded successfully',
        'imageUrls': identificationData,
      };
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {
        'success': false,
        'message': 'Failed to upload documents: ${e.toString()}'
      };
    } finally {
      _setLoading(false);
    }
  }

  // NEW: Method for uploading provider identification images
  Future<Map<String, dynamic>> uploadProviderIdentificationImages({
    required File businessLicenseFront,
    required File businessLicenseBack,
    required File taxCertificate,
    required File bankStatement,
  }) async {
    _setLoading(true);
    try {
      if (currentUser == null) {
        return {'success': false, 'message': 'No user signed in'};
      }

      // Get current user profile to determine role
      final profileResult = await getCurrentUserProfile();
      if (!profileResult['success']) {
        return profileResult;
      }

      String role = profileResult['role'];
      String userId = currentUser!.uid;

      // Verify user is a provider
      if (role != 'provider') {
        return {
          'success': false,
          'message': 'This method is only for providers'
        };
      }

      // Upload all images using batch upload for providers
      final uploadResults = await Cloudinary.uploadProviderIdentificationImages(
        userId: userId,
        businessLicenseFront: businessLicenseFront,
        businessLicenseBack: businessLicenseBack,
        taxCertificate: taxCertificate,
        bankStatement: bankStatement,
      );

      // Check if all uploads were successful
      final failedUploads = uploadResults.entries
          .where((entry) => entry.value == null)
          .map((entry) => entry.key)
          .toList();

      if (failedUploads.isNotEmpty) {
        return {
          'success': false,
          'message': 'Failed to upload: ${failedUploads.join(', ')}'
        };
      }

      // Prepare provider identification images data with Cloudinary URLs
      Map<String, dynamic> providerIdentificationData = {
        'businessLicenseFront': uploadResults['businessLicenseFront']!,
        'businessLicenseBack': uploadResults['businessLicenseBack']!,
        'taxCertificate': uploadResults['taxCertificate']!,
        'bankStatement': uploadResults['bankStatement']!,
        'uploadedAt': DateTime.now(),
      };

      // Update the providers collection
      await _firestore.collection('providers').doc(userId).update({
        'identificationImages': providerIdentificationData,
        'updatedAt': DateTime.now(),
      });

      return {
        'success': true,
        'message': 'Provider documents uploaded successfully',
        'imageUrls': providerIdentificationData,
      };
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {
        'success': false,
        'message': 'Failed to upload provider documents: ${e.toString()}'
      };
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

      if (!updatedDoc.exists) {
        return {'success': false, 'message': 'Provider not found'};
      }

      Provider updatedProvider = Provider.fromFirestore(updatedDoc);

      return {
        'success': true,
        'message': 'Profile updated successfully',
        'data': updatedProvider
      };
    } catch (e) {
      print('Error updating provider profile: $e'); // Add logging
      if (e is FirebaseException && e.code == 'unavailable') {
        return {'success': false, 'message': 'No internet connection'};
      }
      return {
        'success': false,
        'message': 'Failed to update profile: ${e.toString()}'
      };
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

      Map<String, dynamic> statistics = {
        'totalProviders': allProvidersDocs.docs.length,
        'verifiedProviders': verifiedProvidersDocs.docs.length,
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
      print('DEBUG: Starting getFeaturedLoanProviders...');

      // Query all loans
      final loanDocs = await _firestore.collection('loans').get();
      print('DEBUG: Found ${loanDocs.docs.length} loans');

      // Map to track provider selection frequency
      Map<String, int> providerFrequency = {};

      // Count how many times each provider has been selected
      for (var doc in loanDocs.docs) {
        final Map data = doc.data();
        final String providerId = data['providerId'] ?? '';

        if (providerId.isNotEmpty) {
          providerFrequency[providerId] =
              (providerFrequency[providerId] ?? 0) + 1;
          print(
              'DEBUG: Provider $providerId has ${providerFrequency[providerId]} loans');
        }
      }

      print('DEBUG: Provider frequency map: $providerFrequency');

      List<Provider> featuredProviders = [];

      // If loans exist, get providers based on frequency
      if (providerFrequency.isNotEmpty) {
        print('DEBUG: Processing providers by frequency...');

        // Sort providers by frequency (most selected first)
        List<MapEntry<String, int>> sortedProviders = providerFrequency.entries
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        // Get the top 5 provider IDs
        List<String> topProviderIds =
            sortedProviders.take(5).map((entry) => entry.key).toList();

        // Fetch the actual provider data for these IDs
        for (String providerId in topProviderIds) {
          try {
            DocumentSnapshot providerDoc =
                await _firestore.collection('providers').doc(providerId).get();

            if (providerDoc.exists) {
              Provider provider = Provider.fromFirestore(providerDoc);

              if (provider.verified) {
                featuredProviders.add(provider);
              }
            }
          } catch (e) {
            print('DEBUG: Error fetching provider $providerId: $e');
          }
        }
      }

      print(
          'DEBUG: Featured providers from frequency: ${featuredProviders.length}');

      // If we need more providers or have none, get additional ones
      if (featuredProviders.length < 3) {
        // Reduced threshold from 5 to 3
        print('DEBUG: Getting additional providers...');

        // Get IDs of already added providers to avoid duplicates
        Set<String> existingIds = featuredProviders.map((p) => p.id).toSet();

        try {
          // First try: Get verified providers
          QuerySnapshot additionalDocs;
          try {
            additionalDocs = await _firestore
                .collection('providers')
                .where('verified', isEqualTo: true)
                .orderBy('interestRate', descending: false)
                .limit(5 - featuredProviders.length)
                .get();
          } catch (e) {
            print('DEBUG: Compound query failed, trying simpler approach: $e');

            // Fallback: Get all providers and filter in code
            additionalDocs = await _firestore
                .collection('providers')
                .orderBy('interestRate', descending: false)
                .get();
            print(
                'DEBUG: Got ${additionalDocs.docs.length} total providers for manual filtering');
          }

          // Process additional providers
          for (var doc in additionalDocs.docs) {
            if (featuredProviders.length >= 5) break; // Stop if we have enough

            if (!existingIds.contains(doc.id)) {
              try {
                Provider provider = Provider.fromFirestore(doc);

                // More lenient filtering for additional providers
                if (provider.verified) {
                  featuredProviders.add(provider);
                  existingIds.add(doc.id);
                  print(
                      'DEBUG: Added additional provider: ${provider.businessName}');
                }
              } catch (e) {
                print(
                    'DEBUG: Error processing provider document ${doc.id}: $e');
              }
            }
          }

          // If still no providers, get ANY providers as last resort
          if (featuredProviders.isEmpty) {
            final anyProviderDocs =
                await _firestore.collection('providers').limit(3).get();

            for (var doc in anyProviderDocs.docs) {
              try {
                Provider provider = Provider.fromFirestore(doc);
                featuredProviders.add(provider);
                print(
                    'DEBUG: Added fallback provider: ${provider.businessName}');
              } catch (e) {
                print(
                    'DEBUG: Error processing fallback provider ${doc.id}: $e');
              }
            }
          }
        } catch (e) {
          print('DEBUG: Error getting additional providers: $e');
        }
      }

      print(
          'DEBUG: Final featured providers count: ${featuredProviders.length}');
      for (var provider in featuredProviders) {
        print('DEBUG: - ${provider.businessName} (${provider.interestRate}%)');
      }

      if (featuredProviders.isEmpty) {
        return {
          'success': false,
          'message': 'No loan providers found in database'
        };
      }

      return {'success': true, 'data': featuredProviders};
    } catch (e) {
      print('DEBUG: Main error in getFeaturedLoanProviders: $e');

      if (e is FirebaseException) {
        print('DEBUG: Firebase error code: ${e.code}, message: ${e.message}');
        if (e.code == 'unavailable') {
          return {'success': false, 'message': 'No internet connection'};
        } else if (e.code == 'failed-precondition') {
          return {'success': false, 'message': 'Database index required'};
        }
      }

      return {
        'success': false,
        'message': 'Failed to retrieve featured loan providers: $e'
      };
    } finally {
      _setLoading(false);
    }
  }

  // Get specific user profiles
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      // Try students collection first
      DocumentSnapshot studentDoc =
          await _firestore.collection('students').doc(userId).get();

      if (studentDoc.exists) {
        return {
          'success': true,
          'data': studentDoc.data(),
          'userType': 'student',
          'message': 'Student profile fetched successfully',
        };
      }

      // Try providers collection
      DocumentSnapshot providerDoc =
          await _firestore.collection('providers').doc(userId).get();

      if (providerDoc.exists) {
        return {
          'success': true,
          'data': providerDoc.data(),
          'userType': 'provider',
          'message': 'Provider profile fetched successfully',
        };
      }

      return {
        'success': false,
        'data': null,
        'userType': null,
        'message': 'User not found',
      };
    } catch (e) {
      print('Error fetching user profile: $e');
      return {
        'success': false,
        'data': null,
        'userType': null,
        'message': 'Failed to fetch user profile: ${e.toString()}',
      };
    }
  }

  Future<String> getUserDisplayName(String userId) async {
    final result = await getUserProfile(userId);
    if (result['success'] != true) return 'Unknown User';

    final data = result['data'] as Map<String, dynamic>? ?? {};

    switch (result['userType']) {
      case 'student':
        return data['fullName']?.toString() ?? 'Unknown Student';
      case 'provider':
        return data['businessName']?.toString() ?? 'Unknown Provider';
      default:
        return 'Unknown User';
    }
  }

  // Update Student Verification
  Future<Map<String, dynamic>> updateStudentVerification(
    String studentId,
    bool verified, {
    String? reason,
  }) async {
    try {
      final Map<String, dynamic> updateData = {
        'verified': verified,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (verified) {
        // If verifying, add verification timestamp
        updateData['verifiedAt'] = FieldValue.serverTimestamp();
      } else {
        // If unverifying, remove verification timestamp and add reason
        updateData['verifiedAt'] = null;
        if (reason != null && reason.isNotEmpty) {
          updateData['unverificationReason'] = reason;
          updateData['unverifiedAt'] = FieldValue.serverTimestamp();
        }
      }

      await _firestore.collection('students').doc(studentId).update(updateData);

      return {
        'success': true,
        'message': verified
            ? 'Student verified successfully'
            : 'Student unverified successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to update verification status: ${e.toString()}',
      };
    }
  }
}
