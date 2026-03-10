import 'package:onepos_admin_app/features/online_store/data/models/company_model.dart';

/// model for user profile api response
class ProfileModel {
  final int id;
  final String firstname;
  final String lastname;
  final String phoneno;
  final String? address;
  final String email;
  final String? gender;
  final String? image;
  final bool canLogin;
  final bool isActive;
  final String? plan;
  final String? planExpiresAt;
  final CompanyModel? company;

  const ProfileModel({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.phoneno,
    this.address,
    required this.email,
    this.gender,
    this.image,
    required this.canLogin,
    required this.isActive,
    this.plan,
    this.planExpiresAt,
    this.company,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final companyJson = json['company'] as Map<String, dynamic>?;
    return ProfileModel(
      id: json['id'] as int,
      firstname: json['firstname']?.toString() ?? '',
      lastname: json['lastname']?.toString() ?? '',
      phoneno: json['phoneno']?.toString() ?? '',
      address: json['address']?.toString(),
      email: json['email']?.toString() ?? '',
      gender: json['gender']?.toString(),
      image: json['image']?.toString(),
      canLogin:
          json['can_login'] == true ||
          json['can_login'] == 1 ||
          json['can_login'] == '1',
      isActive:
          json['is_active'] == true ||
          json['is_active'] == 1 ||
          json['is_active'] == '1',
      plan: json['plan']?.toString(),
      planExpiresAt: json['plan_expires_at']?.toString(),
      company: companyJson != null ? CompanyModel.fromJson(companyJson) : null,
    );
  }
}
