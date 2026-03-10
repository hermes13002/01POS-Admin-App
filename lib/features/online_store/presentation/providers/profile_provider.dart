import 'package:onepos_admin_app/core/network/dio_client.dart';
import 'package:onepos_admin_app/features/auth/data/models/profile_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_provider.g.dart';

/// fetches authenticated user profile — kept alive so it is shared
/// between the home screen and store profile screen without re-fetching
@Riverpod(keepAlive: true)
Future<ProfileModel> userProfile(UserProfileRef ref) async {
  final response = await DioClient().get('/admin/users/profile');
  final data = response.data['data'] as Map<String, dynamic>;
  return ProfileModel.fromJson(data);
}
