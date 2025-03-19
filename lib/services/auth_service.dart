import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fintech_bridge/models/student_model.dart';
import 'package:fintech_bridge/models/provider_model.dart';
import 'package:fintech_bridge/models/admin_model.dart';
import 'package:fintech_bridge/services/notification_service.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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

  // User state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register with email and password
  Future<Map<String, dynamic>> registerWithEmailAndPassword({
    required String fullName,
    required String email,
    required String password,
    required String studentId,
    required String phone,
    required String role,
    required String course,
    required int yearOfStudy,
    String? profileImage,
    required bool Function(String) emailValidator,
  }) async {
    _setLoading(true);
    try {
      // Validate inputs
      if (fullName.isEmpty || email.isEmpty || password.isEmpty || studentId.isEmpty || phone.isEmpty) {
        return {'success': false, 'message': 'All fields are required'};
      }
      
      // Check if email is a university email
      if (!emailValidator(email)) {
        return {'success': false, 'message': 'Please use a valid university email'};
      }
      
      // Check if role is valid
      if (!['student', 'provider'].contains(role)) {
        return {'success': false, 'message': 'Invalid role selection'};
      }
      
      // Check if email is already used
      final emailQuery = await _firestore.collection('users')
          .where('email', isEqualTo: email)
          .get();
      
      if (emailQuery.docs.isNotEmpty) {
        return {'success': false, 'message': 'Email already registered'};
      }

      // Create user in Firebase Auth
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await credential.user!.updateDisplayName(fullName);

      // Send email verification (with expiration)
      await credential.user!.sendEmailVerification();

      // Create user based on role
      if (role == 'student') {
        // Create student document
        Student student = Student(
          id: credential.user!.uid,
          fullName: fullName,
          universityEmail: email,
          studentId: studentId,
          phone: phone,
          course: course,
          yearOfStudy: yearOfStudy,
          profileImage: profileImage,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _firestore.collection('students').doc(credential.user!.uid).set(student.toMap());
        
        // Create notification for new student account
        await _notificationService.createNotification(
          userId: credential.user!.uid,
          title: 'Welcome to Fintech Bridge',
          message: 'Your student account has been created. Please verify your email to continue.',
          relatedEntityId: credential.user!.uid,
          type: 'ACCOUNT_CREATION',
        );
        
        return {
          'success': true, 
          'message': 'Registration successful! Please verify your email.',
          'user': student
        };
      } else if (role == 'provider') {
        // Create provider document
        Provider provider = Provider(
          id: credential.user!.uid,
          businessName: fullName,
          businessEmail: email,
          registrationNumber: studentId,
          phone: phone,
          businessType: '',
          loanTypes: [],
          interestRate: 0.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _firestore.collection('providers').doc(credential.user!.uid).set(provider.toMap());
        
        // Create notification for new provider account
        await _notificationService.createNotification(
          userId: credential.user!.uid,
          title: 'Welcome to Fintech Bridge',
          message: 'Your provider account has been created. Please verify your email and complete your profile.',
          relatedEntityId: credential.user!.uid,
          type: 'ACCOUNT_CREATION',
        );
        
        return {
          'success': true, 
          'message': 'Registration successful! Please verify your email.',
          'user': provider
        };
      }
      
      return {'success': false, 'message': 'Invalid role type'};
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'Email already in use';
          break;
        case 'weak-password':
          errorMessage = 'Password is too weak';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email format';
          break;
        default:
          errorMessage = 'Registration failed. Please try again.';
      }
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      return {'success': false, 'message': 'Registration failed. Please try again later.'};
    } finally {
      _setLoading(false);
    }
  }

  // Login with email/password
  Future<Map<String, dynamic>> loginWithEmailAndPassword(
    String email,
    String password,
  ) async {
    _setLoading(true);
    try {
      if (email.isEmpty || password.isEmpty) {
        return {'success': false, 'message': 'Email and password are required'};
      }
      
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check email verification
      if (!credential.user!.emailVerified) {
        await _auth.signOut();
        return {'success': false, 'message': 'Please verify your email before logging in'};
      }

      // Determine user type and get appropriate data
      // First check if admin
      DocumentSnapshot adminDoc = await _firestore.collection('admins').doc(credential.user!.uid).get();
      if (adminDoc.exists) {
        Admin admin = Admin.fromFirestore(adminDoc);
        
        // Create notification for admin login
        await _notificationService.createNotification(
          userId: credential.user!.uid,
          title: 'Login Successful',
          message: 'You have successfully logged in as an administrator.',
          relatedEntityId: credential.user!.uid,
          type: 'AUTH_LOGIN',
        );
        
        return {'success': true, 'message': 'Login successful', 'user': admin, 'role': 'admin'};
      }
      
      // Check if student
      DocumentSnapshot studentDoc = await _firestore.collection('students').doc(credential.user!.uid).get();
      if (studentDoc.exists) {
        Student student = Student.fromFirestore(studentDoc);
        
        // Create notification for student login
        await _notificationService.createNotification(
          userId: credential.user!.uid,
          title: 'Welcome Back',
          message: 'You have successfully logged in to your student account.',
          relatedEntityId: credential.user!.uid,
          type: 'AUTH_LOGIN',
        );
        
        return {'success': true, 'message': 'Login successful', 'user': student, 'role': 'student'};
      }
      
      // Check if provider
      DocumentSnapshot providerDoc = await _firestore.collection('providers').doc(credential.user!.uid).get();
      if (providerDoc.exists) {
        Provider provider = Provider.fromFirestore(providerDoc);
        
        // Create notification for provider login
        await _notificationService.createNotification(
          userId: credential.user!.uid,
          title: 'Welcome Back',
          message: 'You have successfully logged in to your provider account.',
          relatedEntityId: credential.user!.uid,
          type: 'AUTH_LOGIN',
        );
        
        return {'success': true, 'message': 'Login successful', 'user': provider, 'role': 'provider'};
      }
      
      // If we get here, user has auth account but no document in Firestore
      await _auth.signOut();
      return {'success': false, 'message': 'User account not found'};
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email format';
          break;
        default:
          errorMessage = 'Login failed. Please try again.';
      }
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      return {'success': false, 'message': 'Login failed. Please try again later.'};
    } finally {
      _setLoading(false);
    }
  }

  // Check if email is verified
  Future<bool> checkEmailVerified() async {
    try {
      // Reload user to get latest verification status
      await currentUser?.reload();
      return currentUser?.emailVerified ?? false;
    } catch (e) {
      return false;
    }
  }

  // Resend email verification
  Future<Map<String, dynamic>> resendVerificationEmail() async {
    _setLoading(true);
    try {
      if (currentUser == null) {
        return {'success': false, 'message': 'No user is currently signed in'};
      }
      
      await currentUser!.sendEmailVerification();
      
      // Create notification for email verification
      await _notificationService.createNotification(
        userId: currentUser!.uid,
        title: 'Verification Email Sent',
        message: 'A new verification email has been sent to your email address. Please check your inbox.',
        relatedEntityId: currentUser!.uid,
        type: 'ACCOUNT_VERIFICATION',
      );
      
      return {'success': true, 'message': 'Verification email sent'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to send verification email. Please try again.'};
    } finally {
      _setLoading(false);
    }
  }

  // Password reset
  Future<Map<String, dynamic>> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    try {
      if (email.isEmpty) {
        return {'success': false, 'message': 'Email is required'};
      }
      
      // Check if this email exists in our system
      final userQuery = await _firestore.collection('students')
          .where('universityEmail', isEqualTo: email)
          .limit(1)
          .get();
          
      final providerQuery = await _firestore.collection('providers')
          .where('businessEmail', isEqualTo: email)
          .limit(1)
          .get();
          
      final adminQuery = await _firestore.collection('admins')
          .where('adminEmail', isEqualTo: email)
          .limit(1)
          .get();
      
      String? userId;
      if (userQuery.docs.isNotEmpty) {
        userId = userQuery.docs.first.id;
      } else if (providerQuery.docs.isNotEmpty) {
        userId = providerQuery.docs.first.id;
      } else if (adminQuery.docs.isNotEmpty) {
        userId = adminQuery.docs.first.id;
      }
      
      await _auth.sendPasswordResetEmail(email: email);
      
      // Create notification if we found a user
      if (userId != null) {
        await _notificationService.createNotification(
          userId: userId,
          title: 'Password Reset Requested',
          message: 'A password reset link has been sent to your email address. The link will expire in 1 hour.',
          relatedEntityId: userId,
          type: 'PASSWORD_RESET',
        );
      }
      
      return {'success': true, 'message': 'Password reset email sent'};
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email format';
          break;
        default:
          errorMessage = 'Password reset failed. Please try again.';
      }
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      return {'success': false, 'message': 'Password reset failed. Please try again later.'};
    } finally {
      _setLoading(false);
    }
  }

  // Get user data based on type
  Future<Map<String, dynamic>> getUserData() async {
    if (currentUser == null) {
      return {'success': false, 'message': 'No user signed in'};
    }
    
    _setLoading(true);
    try {
      // Try to get admin data
      DocumentSnapshot adminDoc = await _firestore.collection('admins').doc(currentUser!.uid).get();
      if (adminDoc.exists) {
        Admin admin = Admin.fromFirestore(adminDoc);
        return {'success': true, 'user': admin, 'role': 'admin'};
      }
      
      // Try to get student data
      DocumentSnapshot studentDoc = await _firestore.collection('students').doc(currentUser!.uid).get();
      if (studentDoc.exists) {
        Student student = Student.fromFirestore(studentDoc);
        return {'success': true, 'user': student, 'role': 'student'};
      }
      
      // Try to get provider data
      DocumentSnapshot providerDoc = await _firestore.collection('providers').doc(currentUser!.uid).get();
      if (providerDoc.exists) {
        Provider provider = Provider.fromFirestore(providerDoc);
        return {'success': true, 'user': provider, 'role': 'provider'};
      }
      
      return {'success': false, 'message': 'User data not found'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to retrieve user data'};
    } finally {
      _setLoading(false);
    }
  }

  // Update student profile
  Future<Map<String, dynamic>> updateStudentProfile({
    required String fullName,
    required String phone,
    required String course,
    required int yearOfStudy,
    String? profileImage,
  }) async {
    _setLoading(true);
    try {
      if (currentUser == null) {
        return {'success': false, 'message': 'No user is currently signed in'};
      }
      
      // Verify user is a student
      DocumentSnapshot studentDoc = await _firestore.collection('students').doc(currentUser!.uid).get();
      if (!studentDoc.exists) {
        return {'success': false, 'message': 'User is not a student'};
      }
      
      Student student = Student.fromFirestore(studentDoc);
      
      // Update student data
      Student updatedStudent = Student(
        id: student.id,
        fullName: fullName,
        universityEmail: student.universityEmail,
        studentId: student.studentId,
        phone: phone,
        course: course,
        yearOfStudy: yearOfStudy,
        profileImage: profileImage ?? student.profileImage,
        createdAt: student.createdAt,
        updatedAt: DateTime.now(),
      );
      
      await _firestore.collection('students').doc(currentUser!.uid).update(updatedStudent.toMap());
      
      // Update display name
      await currentUser!.updateDisplayName(fullName);
      
      // Create notification for profile update
      await _notificationService.createNotification(
        userId: currentUser!.uid,
        title: 'Profile Updated',
        message: 'Your student profile has been updated successfully.',
        relatedEntityId: currentUser!.uid,
        type: 'PROFILE_UPDATE',
      );
      
      return {'success': true, 'message': 'Profile updated successfully', 'user': updatedStudent};
    } catch (e) {
      return {'success': false, 'message': 'Failed to update profile. Please try again.'};
    } finally {
      _setLoading(false);
    }
  }

  // Update provider profile
  Future<Map<String, dynamic>> updateProviderProfile({
    required String businessName,
    required String phone,
    required String businessType,
    required List<String> loanTypes,
    required double interestRate,
    String? website,
    String? description,
  }) async {
    _setLoading(true);
    try {
      if (currentUser == null) {
        return {'success': false, 'message': 'No user is currently signed in'};
      }
      
      // Verify user is a provider
      DocumentSnapshot providerDoc = await _firestore.collection('providers').doc(currentUser!.uid).get();
      if (!providerDoc.exists) {
        return {'success': false, 'message': 'User is not a provider'};
      }
      
      Provider provider = Provider.fromFirestore(providerDoc);
      
      // Update provider data
      Provider updatedProvider = Provider(
        id: provider.id,
        businessName: businessName,
        businessEmail: provider.businessEmail,
        registrationNumber: provider.registrationNumber,
        phone: phone,
        businessType: businessType,
        loanTypes: loanTypes,
        website: website,
        description: description,
        interestRate: interestRate,
        createdAt: provider.createdAt,
        updatedAt: DateTime.now(),
      );
      
      await _firestore.collection('providers').doc(currentUser!.uid).update(updatedProvider.toMap());
      
      // Update display name
      await currentUser!.updateDisplayName(businessName);
      
      // Create notification for profile update
      await _notificationService.createNotification(
        userId: currentUser!.uid,
        title: 'Provider Profile Updated',
        message: 'Your provider profile has been updated successfully.',
        relatedEntityId: currentUser!.uid,
        type: 'PROFILE_UPDATE',
      );
      
      return {'success': true, 'message': 'Profile updated successfully', 'user': updatedProvider};
    } catch (e) {
      return {'success': false, 'message': 'Failed to update profile. Please try again.'};
    } finally {
      _setLoading(false);
    }
  }

  // Create admin account (should be called only once during app initialization)
  Future<Map<String, dynamic>> createAdminAccount({
    required String email,
    required String password,
    required String fullName,
  }) async {
    _setLoading(true);
    try {
      // Check if admin already exists
      final adminQuery = await _firestore.collection('admins').limit(1).get();
      
      if (adminQuery.docs.isNotEmpty) {
        return {'success': false, 'message': 'Admin already exists'};
      }
      
      // Create admin user in Firebase Auth
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Set display name
      await credential.user!.updateDisplayName(fullName);
      
      // Create admin document in Firestore
      Admin admin = Admin(
        id: credential.user!.uid,
        fullName: fullName,
        adminEmail: email,
        role: 'admin',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _firestore.collection('admins').doc(credential.user!.uid).set(admin.toMap());
      
      // Create notification for admin creation
      await _notificationService.createNotification(
        userId: credential.user!.uid,
        title: 'Admin Account Created',
        message: 'Your administrator account has been created successfully.',
        relatedEntityId: credential.user!.uid,
        type: 'ACCOUNT_CREATION',
      );
      
      // Sign out after creating admin
      await _auth.signOut();
      
      return {'success': true, 'message': 'Admin account created successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to create admin account'};
    } finally {
      _setLoading(false);
    }
  }

  // Sign out
  Future<Map<String, dynamic>> signOut() async {
    _setLoading(true);
    try {
      String userId = currentUser!.uid;
      
      await _auth.signOut();
      
      // Create notification for sign out (this won't be seen until next login)
      await _notificationService.createNotification(
        userId: userId,
        title: 'Signed Out',
        message: 'You have been signed out successfully.',
        relatedEntityId: userId,
        type: 'AUTH_LOGOUT',
      );
      
      return {'success': true, 'message': 'Signed out successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to sign out. Please try again.'};
    } finally {
      _setLoading(false);
    }
  }
}
