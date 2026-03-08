import 'package:equatable/equatable.dart';

class AuthRoleModel extends Equatable {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final int level;

  const AuthRoleModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.level,
  });

  factory AuthRoleModel.fromJson(Map<String, dynamic> json) => AuthRoleModel(
    id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
    name: json['name'] ?? '',
    slug: json['slug'] ?? '',
    description: json['description'],
    level: json['level'] is int
        ? json['level']
        : int.parse(json['level'].toString()),
  );

  @override
  List<Object?> get props => [id, name, slug, level];
}

class AuthCompanyModel extends Equatable {
  final int id;
  final String companyName;
  final String? companyEmail;
  final String? companyAddress;
  final String? logo;
  final String? licenseExpiry;

  const AuthCompanyModel({
    required this.id,
    required this.companyName,
    this.companyEmail,
    this.companyAddress,
    this.logo,
    this.licenseExpiry,
  });

  factory AuthCompanyModel.fromJson(Map<String, dynamic> json) =>
      AuthCompanyModel(
        id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
        companyName: json['company_name'] ?? '',
        companyEmail: json['company_email'],
        companyAddress: json['company_address'],
        logo: json['logo'],
        licenseExpiry: json['license_duration'],
      );

  @override
  List<Object?> get props => [id, companyName];
}

class AuthUserModel extends Equatable {
  final int id;
  final int companyId;
  final String firstname;
  final String lastname;
  final String email;
  final String? phoneno;
  final String? image;
  final List<AuthRoleModel> roles;
  final AuthCompanyModel? company;

  const AuthUserModel({
    required this.id,
    required this.companyId,
    required this.firstname,
    required this.lastname,
    required this.email,
    this.phoneno,
    this.image,
    required this.roles,
    this.company,
  });

  String get fullName => '$firstname $lastname';

  String get primaryRole => roles.isNotEmpty ? roles.first.name : '';

  factory AuthUserModel.fromJson(Map<String, dynamic> json) => AuthUserModel(
    id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
    companyId: json['company_id'] is int
        ? json['company_id']
        : int.parse(json['company_id'].toString()),
    firstname: json['firstname'] ?? '',
    lastname: json['lastname'] ?? '',
    email: json['email'] ?? '',
    phoneno: json['phoneno'],
    image: json['image'],
    roles: (json['roles'] as List<dynamic>? ?? [])
        .map((r) => AuthRoleModel.fromJson(r))
        .toList(),
    company: json['company'] != null
        ? AuthCompanyModel.fromJson(json['company'])
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'company_id': companyId,
    'firstname': firstname,
    'lastname': lastname,
    'email': email,
    'phoneno': phoneno,
    'image': image,
  };

  @override
  List<Object?> get props => [id, email];
}
