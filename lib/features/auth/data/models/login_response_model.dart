import 'package:equatable/equatable.dart';
import 'auth_user_model.dart';

class LoginResponseModel extends Equatable {
  final AuthUserModel user;
  final String accessToken;
  final String tokenType;

  const LoginResponseModel({
    required this.user,
    required this.accessToken,
    required this.tokenType,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      LoginResponseModel(
        user: AuthUserModel.fromJson(json['user']),
        accessToken: json['accessToken'] ?? '',
        tokenType: json['tokenType'] ?? 'Bearer',
      );

  @override
  List<Object?> get props => [user, accessToken];
}
