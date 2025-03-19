import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fintech_bridge/models/student_model.dart';
import 'package:fintech_bridge/models/provider_model.dart';
import 'package:fintech_bridge/utils/constants.dart';

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
  
  // Get current user data
  Future<UserModel?> getCurrentUserData() async {
    if (currentUser == null) return null;
    
    _setLoading(true);
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(currentUser!.uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      _showToast('Error fetching user data: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  // Get provider data if user is a provider
  Future<ProviderModel?> getProviderData() async {
    if (currentUser == null) return null;
    
    _setLoading(true);
    try {
      // First check if user is a provider
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUser!.uid).get();
      if (!userDoc.exists || userDoc.get('role') != 'provider') {
        return null;
      }
      
      DocumentSnapshot providerDoc = await _firestore.collection('providers').doc(currentUser!.uid).get();
      if (providerDoc.exists) {
        return ProviderModel.fromFirestore(providerDoc);
      }
      return null;
    } catch (e) {
      _showToast('Error fetching provider data: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  // Update provider data
  Future<bool> updateProviderData({
    required String businessName,
    required String businessDescription,
    String? businessWebsite,
    List<String>? loanTypes,
  }) async {
    if (currentUser == null) return false;
    
    _setLoading(true);
    try {
      // Check if user is a provider
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUser!.uid).get();
      if (!userDoc.exists || userDoc.get('role') != 'provider') {
        _showToast('Only providers can update provider data');
        return false;
      }
      
      Map<String, dynamic> updateData = {
        'businessName': businessName,
        'businessDescription': businessDescription,
        'updatedAt': DateTime.now(),
      };
      
      if (businessWebsite != null) {
        updateData['businessWebsite'] = businessWebsite;
      }
      
      if (loanTypes != null) {
        updateData['loanTypes'] = loanTypes;
      }
      
      await _firestore.collection('providers').doc(currentUser!.uid).update(updateData);
      
      _showToast('Provider profile updated successfully');
      return true;
    } catch (e) {
      _showToast('Failed to update provider data: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Get all approved providers
  Future<List<Map<String, dynamic>>> getApprovedProviders() async {
    _setLoading(true);
    try {
      final providerQuery = await _firestore.collection('providers')
          .where('isApproved', isEqualTo: true)
          .get();
      
      List<Map<String, dynamic>> providers = [];
      
      for (var doc in providerQuery.docs) {
        final providerModel = ProviderModel.fromFirestore(doc);
        
        // Get the user info for this provider
        final userDoc = await _firestore.collection('users').doc(providerModel.id).get();
        if (userDoc.exists) {
          final userModel = UserModel.fromFirestore(userDoc);
          
          providers.add({
            'provider': providerModel,
            'user': userModel,
          });
        }
      }
      
      return providers;
    } catch (e) {
      _showToast('Error fetching providers: ${e.toString()}');
      return [];
    } finally {
      _setLoading(false);
    }
  }
  
  // Admin: Get all pending provider approvals
  Future<List<Map<String, dynamic>>> getPendingProviderApprovals() async {
    _setLoading(true);
    try {
      // Check if current user is admin
      if (currentUser == null) return [];
      
      final userDoc = await _firestore.collection('users').doc(currentUser!.uid).get();
      if (!userDoc.exists || userDoc.get('role') != 'admin') {
        return [];
      }
      
      final providerQuery = await _firestore.collection('providers')
          .where('isApproved', isEqualTo: false)
          .get();
      
      List<Map<String, dynamic>> providers = [];
      
      for (var doc in providerQuery.docs) {
        final providerModel = ProviderModel.fromFirestore(doc);
        
        // Get the user info for this provider
        final userDoc = await _firestore.collection('users').doc(providerModel.id).get();
        if (userDoc.exists) {
          final userModel = UserModel.fromFirestore(userDoc);
          
          providers.add({
            'provider': providerModel,
            'user': userModel,
          });
        }
      }
      
      return providers;
    } catch (e) {
      _showToast('Error fetching pending approvals: ${e.toString()}');
      return [];
    } finally {
      _setLoading(false);
    }
  }
  
  // Admin: Approve or reject provider
  Future<bool> updateProviderApprovalStatus(String providerId, bool isApproved) async {
    _setLoading(true);
    try {
      // Check if current user is admin
      if (currentUser == null) return false;
      
      final userDoc = await _firestore.collection('users').doc(currentUser!.uid).get();
      if (!userDoc.exists || userDoc.get('role') != 'admin') {
        _showToast('Only admins can approve providers');
        return false;
      }
      
      await _firestore.collection('providers').doc(providerId).update({
        'isApproved': isApproved,
        'updatedAt': DateTime.now(),
      });
      
      _showToast(isApproved ? 'Provider approved successfully' : 'Provider rejected');
      return true;
    } catch (e) {
      _showToast('Error updating provider status: ${e.toString()}');
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
}
