import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  final String id;
  final String fullName;
  final String universityEmail;
  final String studentId;
  final String phone;
  final String course;
  final int yearOfStudy;
  final String? profileImage;
  final bool verified;
  final DateTime? verifiedAt;
  final List<String>? identificationImages; // For ID front/back and selfie
  final DateTime createdAt;
  final DateTime updatedAt;

  Student({
    required this.id,
    required this.fullName,
    required this.universityEmail,
    required this.studentId,
    required this.phone,
    required this.course,
    required this.yearOfStudy,
    this.profileImage,
    this.verified = false,
    this.verifiedAt,
    this.identificationImages,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Student.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Student(
      id: doc.id,
      fullName: data['fullName'],
      universityEmail: data['universityEmail'],
      studentId: data['studentId'],
      phone: data['phone'],
      course: data['course'],
      yearOfStudy: data['yearOfStudy'],
      profileImage: data['profileImage'],
      verified: data['verified'] ?? false,
      verifiedAt: data['verifiedAt'] != null ? data['verifiedAt'].toDate() : null,
      identificationImages: data['identificationImages'] != null 
          ? List<String>.from(data['identificationImages']) 
          : null,
      createdAt: data['createdAt'].toDate(),
      updatedAt: data['updatedAt'].toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'universityEmail': universityEmail,
      'studentId': studentId,
      'phone': phone,
      'course': course,
      'yearOfStudy': yearOfStudy,
      'profileImage': profileImage,
      'verified': verified,
      'verifiedAt': verifiedAt,
      'identificationImages': identificationImages,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
