import 'package:cloud_firestore/cloud_firestore.dart';

class ProviderModel {
  final String id;
  final bool isApproved;
  final String? businessName;
  final String? businessDescription;
  final String? businessWebsite;
  final List<String>? loanTypes;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProviderModel({
    required this.id,
    required this.isApproved,
    this.businessName,
    this.businessDescription,
    this.businessWebsite,
    this.loanTypes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProviderModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return ProviderModel(
      id: doc.id,
      isApproved: data['isApproved'] ?? false,
      businessName: data['businessName'],
      businessDescription: data['businessDescription'],
      businessWebsite: data['businessWebsite'],
      loanTypes: data['loanTypes'] != null 
          ? List<String>.from(data['loanTypes']) 
          : null,
      createdAt: data['createdAt'].toDate(),
      updatedAt: data['updatedAt'].toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isApproved': isApproved,
      'businessName': businessName,
      'businessDescription': businessDescription,
      'businessWebsite': businessWebsite,
      'loanTypes': loanTypes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
