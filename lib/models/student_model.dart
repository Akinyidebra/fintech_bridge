import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  final String id;
  final String fullName;
  final String universityEmail;
  final String studentId;
  final String phone;
  final String course;
  final double yearOfStudy;
  final String? profileImage;
  final bool verified;
  final DateTime? verifiedAt;
  final Map<String, dynamic>? identificationImages;
  final String mpesaPhone;
  final String institutionName;
  final bool hasActiveLoan;
  final List<String> guarantorContacts;
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
    required this.mpesaPhone,
    required this.institutionName,
    required this.hasActiveLoan,
    required this.guarantorContacts,
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
      verifiedAt: data['verifiedAt']?.toDate(),
      identificationImages: data['identificationImages'] != null
          ? Map<String, dynamic>.from(data['identificationImages'])
          : null,
      mpesaPhone: data['mpesaPhone'],
      institutionName: data['institutionName'],
      hasActiveLoan: data['hasActiveLoan'] ?? false,
      guarantorContacts: data['guarantorContacts'] != null
          ? List<String>.from(data['guarantorContacts'])
          : [],
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
      'mpesaPhone': mpesaPhone,
      'institutionName': institutionName,
      'hasActiveLoan': hasActiveLoan,
      'guarantorContacts': guarantorContacts,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Helper method to get identification images as a list (if needed elsewhere)
  List<String> get identificationImagesList {
    if (identificationImages == null) return [];
    return identificationImages!.values
        .where((value) => value != null && value.toString().isNotEmpty)
        .map((value) => value.toString())
        .toList();
  }

  // Helper method to get specific identification images
  String? get nationalIdFront => identificationImages?['nationalIdFront'];
  String? get nationalIdBack => identificationImages?['nationalIdBack'];
  String? get studentIdFront => identificationImages?['studentIdFront'];
  String? get studentIdBack => identificationImages?['studentIdBack'];

  // Helper method to check if student has any identification images
  bool get hasIdentificationImages {
    return identificationImages != null &&
        identificationImages!.isNotEmpty &&
        identificationImages!.values
            .any((value) => value != null && value.toString().isNotEmpty);
  }

  // Helper method to count valid identification images
  int get identificationImagesCount {
    if (identificationImages == null) return 0;
    return identificationImages!.values
        .where((value) => value != null && value.toString().isNotEmpty)
        .length;
  }
}
