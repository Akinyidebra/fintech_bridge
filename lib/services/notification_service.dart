import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Notification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final bool isRead;
  final String? relatedEntityId; // Can be loanId, transactionId, etc.
  final String? type; // Can be 'loan', 'payment', 'system', etc.
  final DateTime createdAt;

  Notification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.isRead,
    this.relatedEntityId,
    this.type,
    required this.createdAt,
  });

  factory Notification.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Notification(
      id: doc.id,
      userId: data['userId'],
      title: data['title'],
      message: data['message'],
      isRead: data['isRead'] ?? false,
      relatedEntityId: data['relatedEntityId'],
      type: data['type'],
      createdAt: data['createdAt'].toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'message': message,
      'isRead': isRead,
      'relatedEntityId': relatedEntityId,
      'type': type,
      'createdAt': createdAt,
    };
  }
}

class NotificationService extends ChangeNotifier {
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

  // Get notifications for current user
  Future<Map<String, dynamic>> getUserNotifications({bool unreadOnly = false}) async {
    _setLoading(true);
    try {
      if (currentUser == null) {
        return {'success': false, 'message': 'No user signed in'};
      }
      
      Query query = _firestore.collection('notifications')
          .where('userId', isEqualTo: currentUser!.uid)
          .orderBy('createdAt', descending: true);
          
      if (unreadOnly) {
        query = query.where('isRead', isEqualTo: false);
      }
      
      final notificationDocs = await query.get();
      
      List<Notification> notifications = [];
      for (var doc in notificationDocs.docs) {
        notifications.add(Notification.fromFirestore(doc));
      }
      
      return {'success': true, 'data': notifications};
    } catch (e) {
      return {'success': false, 'message': 'Failed to retrieve notifications'};
    } finally {
      _setLoading(false);
    }
  }
  
  // Mark notification as read
  Future<Map<String, dynamic>> markNotificationAsRead(String notificationId) async {
    _setLoading(true);
    try {
      if (currentUser == null) {
        return {'success': false, 'message': 'No user signed in'};
      }
      
      // Get notification document
      DocumentSnapshot notificationDoc = await _firestore.collection('notifications').doc(notificationId).get();
      if (!notificationDoc.exists) {
        return {'success': false, 'message': 'Notification not found'};
      }
      
      Notification notification = Notification.fromFirestore(notificationDoc);
      
      // Verify notification belongs to current user
      if (notification.userId != currentUser!.uid) {
        