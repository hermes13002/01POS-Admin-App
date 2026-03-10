import 'package:onepos_admin_app/features/online_store/data/models/company_model.dart';
import 'package:onepos_admin_app/features/online_store/presentation/providers/profile_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'company_provider.g.dart';

/// derives company data from the profile provider — no extra api call
@riverpod
Future<CompanyModel> companyDetails(CompanyDetailsRef ref) async {
  final profile = await ref.watch(userProfileProvider.future);
  if (profile.company == null) {
    throw Exception('company data not available in profile response');
  }
  return profile.company!;
}
