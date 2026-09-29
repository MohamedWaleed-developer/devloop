import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileModel {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final String bio;
  final String role;
  final List<String> skills;
  final String? githubUrl;
  final String? linkedinUrl;
  final String? portfolioUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProfileModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.bio = '',
    this.role = '',
    this.skills = const [],
    this.githubUrl,
    this.linkedinUrl,
    this.portfolioUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory ProfileModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> document,
      ) {
    final data = document.data() ?? {};

    return ProfileModel(
      uid: document.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'],
      bio: data['bio'] ?? '',
      role: data['role'] ?? '',
      skills: List<String>.from(data['skills'] ?? []),
      githubUrl: data['githubUrl'],
      linkedinUrl: data['linkedinUrl'],
      portfolioUrl: data['portfolioUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'bio': bio,
      'role': role,
      'skills': skills,
      'githubUrl': githubUrl,
      'linkedinUrl': linkedinUrl,
      'portfolioUrl': portfolioUrl,
      'createdAt': createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(createdAt!),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  ProfileModel copyWith({
    String? name,
    String? email,
    String? photoUrl,
    String? bio,
    String? role,
    List<String>? skills,
    String? githubUrl,
    String? linkedinUrl,
    String? portfolioUrl,
  }) {
    return ProfileModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      role: role ?? this.role,
      skills: skills ?? this.skills,
      githubUrl: githubUrl ?? this.githubUrl,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      portfolioUrl: portfolioUrl ?? this.portfolioUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}