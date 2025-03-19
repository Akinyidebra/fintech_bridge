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
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}