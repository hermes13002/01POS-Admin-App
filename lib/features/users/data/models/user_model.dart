/// model for a role assigned to a user
class RoleModel {
  final int id;
  final String name;
  final String slug;
  final String description;
  final int level;

  const RoleModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.level,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      level: json['level'] is int
          ? json['level']
          : int.tryParse(json['level'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'level': level,
    };
  }
}

/// model for a user item
class UserModel {
  final int id;
  final String companyId;
  final String firstname;
  final String lastname;
  final String phoneno;
  final String? address;
  final String email;
  final String? gender;
  final String? image;
  final String? loginPin;
  final bool canLogin;
  final bool isVerified;
  final bool isActive;
  final String? emailVerifiedAt;
  final String? createdAt;
  final String? updatedAt;
  final List<RoleModel> roles;

  const UserModel({
    required this.id,
    required this.companyId,
    required this.firstname,
    required this.lastname,
    required this.phoneno,
    this.address,
    required this.email,
    this.gender,
    this.image,
    this.loginPin,
    required this.canLogin,
    required this.isVerified,
    required this.isActive,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
    this.roles = const [],
  });

  /// full display name
  String get fullName => '$firstname $lastname';

  /// primary role name or empty string
  String get roleName => roles.isNotEmpty ? roles.first.name : '';

  /// creates a copy with optionally overridden fields
  UserModel copyWith({
    int? id,
    String? companyId,
    String? firstname,
    String? lastname,
    String? phoneno,
    String? address,
    String? email,
    String? gender,
    String? image,
    String? loginPin,
    bool? canLogin,
    bool? isVerified,
    bool? isActive,
    String? emailVerifiedAt,
    String? createdAt,
    String? updatedAt,
    List<RoleModel>? roles,
  }) {
    return UserModel(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      phoneno: phoneno ?? this.phoneno,
      address: address ?? this.address,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      image: image ?? this.image,
      loginPin: loginPin ?? this.loginPin,
      canLogin: canLogin ?? this.canLogin,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      roles: roles ?? this.roles,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rolesList = json['roles'] as List<dynamic>? ?? [];

    return UserModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      companyId: json['company_id']?.toString() ?? '',
      firstname: json['firstname']?.toString() ?? '',
      lastname: json['lastname']?.toString() ?? '',
      phoneno: json['phoneno']?.toString() ?? '',
      address: json['address']?.toString(),
      email: json['email']?.toString() ?? '',
      gender: json['gender']?.toString(),
      image: json['image']?.toString(),
      loginPin: json['login_pin']?.toString(),
      canLogin:
          json['can_login'] == true ||
          json['can_login'] == 1 ||
          json['can_login'] == '1',
      isVerified:
          json['is_verified'] == true ||
          json['is_verified'] == 1 ||
          json['is_verified'] == '1',
      isActive:
          json['is_active'] == true ||
          json['is_active'] == 1 ||
          json['is_active'] == '1',
      emailVerifiedAt: json['email_verified_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      roles: rolesList
          .map((r) => RoleModel.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'firstname': firstname,
      'lastname': lastname,
      'phoneno': phoneno,
      'address': address,
      'email': email,
      'gender': gender,
      'image': image,
      'login_pin': loginPin,
      'can_login': canLogin,
      'is_verified': isVerified,
      'is_active': isActive,
      'email_verified_at': emailVerifiedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'roles': roles.map((e) => e.toJson()).toList(),
    };
  }
}

/// paginated response wrapper for users
class PaginatedUsersResponse {
  final List<UserModel> users;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final bool hasMorePages;

  const PaginatedUsersResponse({
    required this.users,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.hasMorePages,
  });

  factory PaginatedUsersResponse.fromJson(Map<String, dynamic> json) {
    final usersList = json['data'] as List<dynamic>? ?? [];

    final currentPage = json['current_page'] is int
        ? json['current_page']
        : int.tryParse(json['current_page'].toString()) ?? 1;
    final lastPage = json['last_page'] is int
        ? json['last_page']
        : int.tryParse(json['last_page'].toString()) ?? 1;

    return PaginatedUsersResponse(
      users: usersList
          .map((u) => UserModel.fromJson(u as Map<String, dynamic>))
          .toList(),
      currentPage: currentPage,
      lastPage: lastPage,
      perPage: json['per_page'] is int
          ? json['per_page']
          : int.tryParse(json['per_page'].toString()) ?? 15,
      total: json['total'] is int
          ? json['total']
          : int.tryParse(json['total'].toString()) ?? 0,
      hasMorePages: currentPage < lastPage,
    );
  }
}

/// state holder for the users list with pagination info
class UsersState {
  final List<UserModel> users;
  final int currentPage;
  final int lastPage;
  final bool isLoadingMore;
  final bool hasMorePages;

  const UsersState({
    this.users = const [],
    this.currentPage = 0,
    this.lastPage = 1,
    this.isLoadingMore = false,
    this.hasMorePages = true,
  });

  UsersState copyWith({
    List<UserModel>? users,
    int? currentPage,
    int? lastPage,
    bool? isLoadingMore,
    bool? hasMorePages,
  }) {
    return UsersState(
      users: users ?? this.users,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMorePages: hasMorePages ?? this.hasMorePages,
    );
  }
}
