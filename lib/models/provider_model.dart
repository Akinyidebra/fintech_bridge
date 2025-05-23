import 'package:cloud_firestore/cloud_firestore.dart';

class Provider {
  final String id;
  final String businessName;
  final String businessEmail;
  final String phone;
  final String businessType;
  final List<String> loanTypes;
  final String? website;
  final String? description;
  final double interestRate;
  final String? profileImage;
  final bool verified;
  final DateTime? verifiedAt;
  final List<String>? identificationImages; // For business registration docs and ID verification
  final bool approved;
  final DateTime createdAt;
  final DateTime updatedAt;

  Provider({
    required this.id,
    required this.businessName,
    required this.businessEmail,
    required this.phone,
    required this.businessType,
    required this.loanTypes,
    this.website,
    this.description,
    required this.interestRate,
    this.profileImage,
    this.verified = false,
    this.verifiedAt,
    this.identificationImages,
    this.approved = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Provider.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Provider(
      id: doc.id,
      businessName: data['businessName'],
      businessEmail: data['businessEmail'],
      phone: data['phone'],
      businessType: data['businessType'],
      loanTypes: List<String>.from(data['loanTypes']),
      website: data['website'],
      description: data['description'],
      interestRate: data['interestRate'].toDouble(),
      profileImage: data['profileImage'],
      verified: data['verified'] ?? false,
      verifiedAt: data['verifiedAt'] != null ? data['verifiedAt'].toDate() : null,
      identificationImages: data['identificationImages'] != null 
          ? List<String>.from(data['identificationImages']) 
          : null,
      approved: data['approved'] ?? false,
      createdAt: data['createdAt'].toDate(),
      updatedAt: data['updatedAt'].toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'businessName': businessName,
      'businessEmail': businessEmail,
      'phone': phone,
      'businessType': businessType,
      'loanTypes': loanTypes,
      'website': website,
      'description': description,
      'interestRate': interestRate,
      'profileImage': profileImage,
      'verified': verified,
      'verifiedAt': verifiedAt,
      'identificationImages': identificationImages,
      'approved': approved,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
