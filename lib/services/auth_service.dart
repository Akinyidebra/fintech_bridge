import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fintech_bridge/models/student_model.dart';
import 'package:fintech_bridge/models/provider_model.dart';
import 'package:fintech_bridge/models/student_model.dart';
import 'package:fintech_bridge/utils/constants.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
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

  // Get user data from Firestore
  Future<UserModel?> getCurrentUserData() async {
    if (currentUser == null) return null;
    
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(currentUser!.uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      _showToast('Error fetching user data: ${e.toString()}');
      return null;
    }
  }

  // Register with email and password
  Future<UserModel?> registerWithEmailAndPassword({
    required String fullName,
    required String email,
    required String password,
    required String studentId,
    required String phone,
    required String role,  // Now will be 'student' or 'provider'
    String? profileImageBase64,
    required bool Function(String) emailValidator,
  }) async {
    _setLoading(true);
    try {
      // Validate inputs
      if (fullName.isEmpty || email.isEmpty || password.isEmpty || studentId.isEmpty || phone.isEmpty) {
        _showToast('All fields are required');
        return null;
      }
      
      // Check if email is a university email
      if (!emailValidator(email)) {
        _showToast('Please use a valid university email');
        return null;
      }
      
      // Check if role is valid
      if (!['student', 'provider'].contains(role)) {
        _showToast('Invalid role selection');
        return null;
      }
      
      // Check if email is already used
      final emailQuery = await _firestore.collection('users')
          .where('email', isEqualTo: email)
          .get();
      
      if (emailQuery.docs.isNotEmpty) {
        _showToast('Email already registered');
        return null;
      }

      // Create user in Firebase Auth
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await credential.user!.updateDisplayName(fullName);

      // Send email verification
      await credential.user!.sendEmailVerification();

      // Create user document in Firestore
      UserModel user = UserModel(
        id: credential.user!.uid,
        fullName: fullName,
        email: email,
        studentId: studentId,
        phone: phone,
        role: role,  // Changed from 'user' to either 'student' or 'provider'
        profileImage: profileImageBase64,
        isVerified: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(credential.user!.uid).set(user.toMap());

      // Create related documents based on role
      if (role == 'provider') {
        await _createProviderDocument(credential.user!.uid);
      } else if (role == 'student') {
        await _createStudentDocument(credential.user!.uid);
      }

      _showToast('Registration successful! Please verify your email.');
      return user;
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
          errorMessage = e.message ?? 'Registration failed';
      }
      _showToast(errorMessage);
      return null;
    } catch (e) {
      _showToast('Registration failed: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Google Sign-In with role selection
  Future<UserModel?> signInWithGoogle({
    required String selectedRole,
    required bool Function(String) emailValidator,
  }) async {
    _setLoading(true);
    try {
      // Validate role selection
      if (!['student', 'provider'].contains(selectedRole)) {
        _showToast('Please select a valid user type');
        return null;
      }
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      // Validate if it's a university email
      if (!emailValidator(googleUser.email)) {
        _showToast('Please use a university email account');
        await _googleSignIn.signOut();
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user == null) return null;

      // Check if user exists in Firestore
      DocumentSnapshot doc = await _firestore.collection('users').doc(userCredential.user!.uid).get();

      if (doc.exists) {
        // User exists, update last login
        await _firestore.collection('users').doc(userCredential.user!.uid).update({
          'updatedAt': DateTime.now(),
        });
        
        _showToast('Welcome back!');
        return UserModel.fromFirestore(doc);
      } else {
        // Check if email is already used in a different account
        final emailQuery = await _firestore.collection('users')
            .where('email', isEqualTo: googleUser.email)
            .get();
        
        if (emailQuery.docs.isNotEmpty) {
          _showToast('Email already registered with a different account');
          await _auth.signOut();
          return null;
        }
        
        // Create new user with selected role
        UserModel newUser = UserModel(
          id: userCredential.user!.uid,
          fullName: googleUser.displayName ?? '',
          email: googleUser.email,
          studentId: '', // Will need to be filled later
          phone: '', // Will need to be filled later
          role: selectedRole, // Using the selected role - student or provider
          profileImage: null, // Google photo URL could be fetched
          isVerified: true, // Google accounts are pre-verified
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _firestore.collection('users').doc(userCredential.user!.uid).set(newUser.toMap());
        
        // Create role-specific document
        if (selectedRole == 'provider') {
          await _createProviderDocument(userCredential.user!.uid);
        } else if (selectedRole == 'student') {
          await _createStudentDocument(userCredential.user!.uid);
        }
        
        _showToast('Account created successfully!');
        return newUser;
      }
    } catch (e) {
      _showToast('Google sign-in failed: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Login with email/password
  Future<UserModel?> loginWithEmailAndPassword(
    String email,
    String password,
  ) async {
    _setLoading(true);
    try {
      if (email.isEmpty || password.isEmpty) {
        _showToast('Email and password are required');
        return null;
      }
      
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check email verification
      if (!credential.user!.emailVerified) {
        _showToast('Please verify your email before logging in');
        await _auth.signOut();
        return null;
      }

      // Get user doc from Firestore
      DocumentSnapshot doc = await _firestore.collection('users').doc(credential.user!.uid).get();
      
      if (!doc.exists) {
        _showToast('User data not found');
        await _auth.signOut();
        return null;
      }

      // Update last login time
      await _firestore.collection('users').doc(credential.user!.uid).update({
        'updatedAt': DateTime.now(),
      });

      _showToast('Login successful');
      return UserModel.fromFirestore(doc);
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
          errorMessage = e.message ?? 'Login failed';
      }
      _showToast(errorMessage);
      return null;
    } catch (e) {
      _showToast('Login failed: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Google Sign-In for login only (without role selection)
  Future<UserModel?> loginWithGoogle({
    required bool Function(String) emailValidator,
  }) async {
    _setLoading(true);
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      // Validate if it's a university email
      if (!emailValidator(googleUser.email)) {
        _showToast('Please use a university email account');
        await _googleSignIn.signOut();
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user == null) return null;

      // Check if user exists in Firestore
      DocumentSnapshot doc = await _firestore.collection('users').doc(userCredential.user!.uid).get();

      if (!doc.exists) {
        // Check if user exists with this email
        final emailQuery = await _firestore.collection('users')
          .where('email', isEqualTo: googleUser.email)
          .get();
        
        if (emailQuery.docs.isEmpty) {
          // User doesn't exist - they need to register first
          _showToast('Account not found. Please register first.');
          await _auth.signOut();
          return null;
        }
      }

      // Update last login time
      await _firestore.collection('users').doc(userCredential.user!.uid).update({
        'updatedAt': DateTime.now(),
      });

      _showToast('Login successful');
      return UserModel.fromFirestore(doc);
    } catch (e) {
      _showToast('Google sign-in failed: ${e.toString()}');
      return null;
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
  Future<bool> resendVerificationEmail() async {
    _setLoading(true);
    try {
      if (currentUser == null) {
        _showToast('No user is currently signed in');
        return false;
      }
      
      await currentUser!.sendEmailVerification();
      _showToast('Verification email sent');
      return true;
    } catch (e) {
      _showToast('Failed to send verification email: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Password reset
  Future<bool> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    try {
      if (email.isEmpty) {
        _showToast('Email is required');
        return false;
      }
      
      await _auth.sendPasswordResetEmail(email: email);
      _showToast('Password reset email sent');
      return true;
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
          errorMessage = e.message ?? 'Password reset failed';
      }
      _showToast(errorMessage);
      return false;
    } catch (e) {
      _showToast('Password reset failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Create provider document
  Future<void> _createProviderDocument(String userId) async {
    ProviderModel provider = ProviderModel(
      id: userId,
      isApproved: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _firestore.collection('providers').doc(userId).set(provider.toMap());
  }

  // Create student document
  Future<void> _createStudentDocument(String userId) async {
    // Create a student model 
    // Add your student model properties as needed
    Map<String, dynamic> studentData = {
      'id': userId,
      'createdAt': DateTime.now(),
      'updatedAt': DateTime.now(),
      // Add other student-specific fields here
    };

    await _firestore.collection('students').doc(userId).set(studentData);
  }

  // Create admin account (should be called only once during app initialization)
  Future<void> createAdminAccount({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      // Check if admin already exists
      final adminQuery = await _firestore.collection('users')
          .where('role', isEqualTo: 'admin')
          .limit(1)
          .get();
      
      if (adminQuery.docs.isNotEmpty) {
        // Admin already exists
        return;
      }
      
      // Create admin user or sign in if exists
      UserCredential? credential;
      try {
        // Try to sign in first in case the auth account exists but not the Firestore document
        credential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } catch (e) {
        // If sign in fails, create new account
        credential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        
        // Set display name
        await credential.user!.updateDisplayName(fullName);
        
        // Force email verification for admin
        if (!credential.user!.emailVerified) {
          try {
            await credential.user!.sendEmailVerification();
          } catch (e) {
            // Silent error for verification email
          }
        }
      }
      
      // Create admin document
      UserModel admin = UserModel(
        id: credential.user!.uid,
        fullName: fullName,
        email: email,
        studentId: 'ADMIN',
        phone: '',
        role: 'admin',
        profileImage: null,
        isVerified: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _firestore.collection('users').doc(credential.user!.uid).set(admin.toMap());
      
      // Sign out after creating admin
      await _auth.signOut();
    } catch (e) {
      // Silent error as this is an internal operation
      print('Admin account creation error: ${e.toString()}');
    }
  }

  // Check user role
  Future<String> getUserRole(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      return doc.exists ? doc.get('role') ?? 'student' : 'student';
    } catch (e) {
      return 'student'; // Default role
    }
  }

  // Get user by email
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final querySnapshot = await _firestore.collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isEmpty) {
        return null;
      }
      
      return UserModel.fromFirestore(querySnapshot.docs.first);
    } catch (e) {
      print('Error fetching user by email: ${e.toString()}');
      return null;
    }
  }

  // Update user profile
  Future<bool> updateUserProfile({
    required String fullName,
    required String phone,
    String? studentId,
    String? profileImageBase64,
  }) async {
    _setLoading(true);
    try {
      if (currentUser == null) {
        _showToast('No user is currently signed in');
        return false;
      }
      
      Map<String, dynamic> updateData = {
        'fullName': fullName,
        'phone': phone,
        'updatedAt': DateTime.now(),
      };
      
      if (studentId != null && studentId.isNotEmpty) {
        updateData['studentId'] = studentId;
      }
      
      if (profileImageBase64 != null) {
        updateData['profileImage'] = profileImageBase64;
      }
      
      // Update Firestore document
      await _firestore.collection('users').doc(currentUser!.uid).update(updateData);
      
      // Update display name
      await currentUser!.updateDisplayName(fullName);
      
      _showToast('Profile updated successfully');
      return true;
    } catch (e) {
      _showToast('Failed to update profile: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Show toast messages
  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppConstants.primaryColor,
      textColor: Colors.white,
    );
  }

  // Sign out
  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      _showToast('Signed out successfully');
    } catch (e) {
      _showToast('Sign out failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
}
