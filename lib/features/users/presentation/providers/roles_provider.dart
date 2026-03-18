import 'package:onepos_admin_app/features/users/data/models/user_model.dart';
import 'package:onepos_admin_app/features/users/presentation/providers/users_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'roles_provider.g.dart';

@riverpod
Future<List<RoleModel>> roles(RolesRef ref) async {
  final repo = ref.watch(usersRepositoryProvider);
  final result = await repo.getRoles();
  return result.fold((l) => throw Exception(l.message), (r) => r);
}
