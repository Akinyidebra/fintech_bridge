// provider_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Provider {
  final String id;
  final String businessName;
  final String businessEmail;
  final String registrationNumber;
  final String phone;
  final String businessType;
  final List<String> loanTypes;
  final String? website;
  final String? description;
  final double interestRate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Provider({
    required this.id,
    required this.businessName,
    required this.businessEmail,
    required this.registrationNumber,
    required this.phone,
    required this.businessType,
    required this.loanTypes,
    this.website,
    this.description,
    required this.interestRate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Provider.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Provider(
      id: doc.id,
      businessName: data['businessName'],
      businessEmail: data['businessEmail'],
      registrationNumber: data['registrationNumber'],
      phone: data['phone'],
      businessType: data['businessType'],
      loanTypes: List<String>.from(data['loanTypes']),
      website: data['website'],
      description: data['description'],
      interestRate: data['interestRate'].toDouble(),
      createdAt: data['createdAt'].toDate(),
      updatedAt: data['updatedAt'].toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'businessName': businessName,
      'businessEmail': businessEmail,
      'registrationNumber': registrationNumber,
      'phone': phone,
      'businessType': businessType,
      'loanTypes': loanTypes,
      'website': website,
      'description': description,
      'interestRate': interestRate,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
