import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Notification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final bool isRead;
  final String? relatedEntityId;
  final String? type;
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
    Map data = doc.data() as Map<String, dynamic>;
    return Notification(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? 'Notification',
      message: data['message'] ?? '',
      isRead: data['isRead'] ?? false,
      relatedEntityId: data['relatedEntityId'],
      type: data['type'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
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

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  User? get currentUser => _auth.currentUser;

  Future<Map<String, dynamic>> createNotification({
    required String userId,
    required String title,
    required String message,
    String? relatedEntityId,
    String? type,
  }) async {
    _setLoading(true);
    try {
      final notification = Notification(
        id: '',
        userId: userId,
        title: title,
        message: message,
        isRead: false,
        relatedEntityId: relatedEntityId,
        type: type,
        createdAt: DateTime.now(),
      );

      final docRef = await _firestore
          .collection('notifications')
          .add(notification.toMap());
      return {
        'success': true,
        'message': 'Notification created',
        'data': notification.copyWith(id: docRef.id)
      };
    } catch (e) {
      return {'success': false, 'message': 'Failed to create notification'};
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> getUserNotifications(
      {bool unreadOnly = false}) async {
    _setLoading(true);
    try {
      if (currentUser == null) {
        return {
          'success': false,
          'message': 'Please sign in to view notifications'
        };
      }

      Query query = _firestore
          .collection('notifications')
          .where('userId', isEqualTo: currentUser!.uid)
          .orderBy('createdAt', descending: true);

      if (unreadOnly) {
        query = query.where('isRead', isEqualTo: false);
      }

      final snapshot = await query.get();
      final notifications =
          snapshot.docs.map((doc) => Notification.fromFirestore(doc)).toList();

      return {'success': true, 'data': notifications};
    } catch (e) {
      return {'success': false, 'message': 'Failed to load notifications'};
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> markNotificationAsRead(
      String notificationId) async {
    _setLoading(true);
    try {
      if (currentUser == null) {
        return {'success': false, 'message': 'Authentication required'};
      }

      final doc = await _firestore
          .collection('notifications')
          .doc(notificationId)
          .get();
      if (!doc.exists) {
        return {'success': false, 'message': 'Notification not found'};
      }

      final notification = Notification.fromFirestore(doc);
      if (notification.userId != currentUser!.uid) {
        return {'success': false, 'message': 'Unauthorized action'};
      }

      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
      });

      return {'success': true, 'message': 'Marked as read'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to update notification'};
    } finally {
      _setLoading(false);
    }
  }
}

extension NotificationCopyWith on Notification {
  Notification copyWith({
    String? id,
    bool? isRead,
  }) {
    return Notification(
      id: id ?? this.id,
      userId: userId,
      title: title,
      message: message,
      isRead: isRead ?? this.isRead,
      relatedEntityId: relatedEntityId,
      type: type,
      createdAt: createdAt,
    );
  }
}
