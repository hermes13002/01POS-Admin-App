import 'package:onepos_admin_app/core/network/dio_client.dart';
import 'package:onepos_admin_app/features/auth/data/models/profile_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_provider.g.dart';

/// fetches authenticated user profile — kept alive so it is shared
/// between the home screen and store profile screen without re-fetching
@Riverpod(keepAlive: true)
class UserProfile extends _$UserProfile {
  @override
  Future<ProfileModel> build() async {
    final response = await DioClient().get('/admin/users/profile');
    final data = response.data['data'] as Map<String, dynamic>;
    return ProfileModel.fromJson(data);
  }

  /// Update user profile field(s)
  Future<void> updateProfile(Map<String, dynamic> updateData) async {
    final currentProfile = state.valueOrNull;
    if (currentProfile == null) return;

    // Prepare the full body as required by the API
    final fullBody = {
      'firstname': updateData['firstname'] ?? currentProfile.firstname,
      'lastname': updateData['lastname'] ?? currentProfile.lastname,
      'email': updateData['email'] ?? currentProfile.email,
      'address': updateData['address'] ?? currentProfile.address ?? '',
      'phoneno': updateData['phoneno'] ?? currentProfile.phoneno,
      'profile_image':
          updateData['profile_image'] ?? currentProfile.image ?? '',
      'old_password': updateData['old_password'] ?? '',
      'new_password': updateData['new_password'] ?? '',
    };

    try {
      await DioClient().post('/admin/users/profile_update', data: fullBody);
      // Re-fetch the profile to ensure local state is perfectly synced with server
      ref.invalidateSelf();
      await future;
    } catch (e) {
      rethrow;
    }
  }
}
