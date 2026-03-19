import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onepos_admin_app/core/routes/app_routes.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/features/users/data/models/user_model.dart';
import 'package:onepos_admin_app/features/users/presentation/providers/roles_provider.dart';
import 'package:onepos_admin_app/features/users/presentation/providers/users_provider.dart';
import 'package:onepos_admin_app/shared/widgets/custom_app_bar.dart';
import 'package:onepos_admin_app/shared/widgets/custom_button_with_icon.dart';
import 'package:onepos_admin_app/shared/widgets/custom_search_bar.dart';
import 'package:onepos_admin_app/shared/widgets/loading_widget.dart';
import 'package:onepos_admin_app/shared/widgets/app_snackbar.dart';
import 'package:onepos_admin_app/shared/widgets/custom_text_field.dart';
import 'package:onepos_admin_app/shared/widgets/app_dropdown.dart';
import 'package:onepos_admin_app/core/utils/validators.dart';
import 'package:onepos_admin_app/shared/widgets/custom_switch.dart';

/// Screen for viewing and managing users
class UsersScreen extends HookConsumerWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(allUsersProvider);

    final expandedIndex = useState<int?>(0);
    final searchController = useTextEditingController();
    final searchQuery = useState('');
    final scrollController = useScrollController();

    useEffect(() {
      void listener() {
        searchQuery.value = searchController.text;
      }

      searchController.addListener(listener);
      return () => searchController.removeListener(listener);
    }, [searchController]);

    // refresh users data on screen entry
    useEffect(() {
      Future.microtask(() {
        ref.read(allUsersProvider.notifier).refresh();
      });
      return null;
    }, const []);

    // listen for scroll to load more
    useEffect(() {
      void onScroll() {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
          ref.read(allUsersProvider.notifier).fetchNextPage();
        }
      }

      scrollController.addListener(onScroll);
      return () => scrollController.removeListener(onScroll);
    }, [scrollController]);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Users',
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMedium,
                vertical: AppTheme.spacingSmall,
              ),
              child: CustomSearchBar(
                controller: searchController,
                hintText: 'Search',
                padding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            Expanded(
              child: usersAsync.when(
                loading: () => const LoadingWidget(),
                error: (error, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Failed to load users',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () =>
                            ref.read(allUsersProvider.notifier).refresh(),
                        child: Text(
                          'Retry',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppTheme.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                data: (usersState) {
                  final filteredUsers = _filterUsers(
                    usersState.users,
                    searchQuery.value,
                  );

                  if (filteredUsers.isEmpty) {
                    return Center(
                      child: Text(
                        'No users found',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      await ref.read(allUsersProvider.notifier).refresh();
                    },
                    child: ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.all(
                        AppTheme.spacingMedium,
                      ).copyWith(bottom: 80),
                      itemCount:
                          filteredUsers.length +
                          (usersState.hasMorePages ? 1 : 0),
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: AppTheme.spacingMedium),
                      itemBuilder: (context, index) {
                        // loading indicator at the bottom
                        if (index >= filteredUsers.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: LoadingWidget(size: 32),
                          );
                        }

                        final user = filteredUsers[index];
                        final isExpanded = expandedIndex.value == index;

                        return _UserCard(
                          user: user,
                          isExpanded: isExpanded,
                          onTap: () {
                            if (isExpanded) {
                              expandedIndex.value = null;
                            } else {
                              expandedIndex.value = index;
                            }
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.pushNamed(context, AppRoutes.addUser);
          if (created == true) {
            await ref.read(allUsersProvider.notifier).refresh();
          }
        },
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  /// filters users by name, email, or role
  List<UserModel> _filterUsers(List<UserModel> users, String query) {
    final lowerQuery = query.trim().toLowerCase();
    if (lowerQuery.isEmpty) return users;
    return users.where((user) {
      return user.fullName.toLowerCase().contains(lowerQuery) ||
          user.email.toLowerCase().contains(lowerQuery) ||
          user.roleName.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}

/// expandable user card widget with toggle switch
class _UserCard extends HookConsumerWidget {
  final UserModel user;
  final bool isExpanded;
  final VoidCallback onTap;

  const _UserCard({
    required this.user,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isToggling = useState(false);
    final isDeleting = useState(false);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // top row: name/email and role
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.email,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Text(
                      user.roleName,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: AppTheme.textSecondary,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),

            // expanded content
            if (isExpanded) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              // status row with toggle switch
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Status',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        user.isActive ? 'Active' : 'Inactive',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: user.isActive
                              ? const Color(0xFF4CAF50)
                              : AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (isToggling.value)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        SizedBox(
                          height: 24,
                          child: CustomSwitch(
                            value: user.isActive,
                            activeColor: const Color(0xFF4CAF50),
                            onChanged: (value) async {
                              isToggling.value = true;
                              final error = await ref
                                  .read(allUsersProvider.notifier)
                                  .toggleUserStatus(user.id, activate: value);
                              isToggling.value = false;
                              if (error != null && context.mounted) {
                                AppSnackbar.showError(context, error);
                              }
                            },
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // action buttons
              Row(
                children: [
                  Expanded(
                    child: CustomButtonWithIcon(
                      text: 'View',
                      icon: Icons.visibility_outlined,
                      onPressed: () {
                        _showViewDialog(context, ref, user);
                      },
                      isOutlined: true,
                      textColor: AppTheme.grey400,
                      iconColor: AppTheme.grey400,
                      borderColor: AppTheme.grey400,
                      height: 44,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CustomButtonWithIcon(
                      text: 'Edit',
                      icon: Icons.edit_outlined,
                      onPressed: () {
                        _showEditDialog(context, ref, user);
                      },
                      isOutlined: true,
                      textColor: AppTheme.blue,
                      iconColor: AppTheme.blue,
                      borderColor: AppTheme.blue,
                      height: 44,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CustomButtonWithIcon(
                      text: isDeleting.value ? 'Deleting...' : 'Delete',
                      icon: Icons.delete_outline,
                      onPressed: () {
                        if (!isDeleting.value) {
                          _showDeleteConfirmation(
                            context,
                            ref,
                            user,
                            isDeleting,
                          );
                        }
                      },
                      isOutlined: true,
                      textColor: const Color(0xFFD32F2F),
                      iconColor: const Color(0xFFD32F2F),
                      borderColor: const Color(0xFFD32F2F),
                      height: 44,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// shows view user details dialog
  static void _showViewDialog(
    BuildContext context,
    WidgetRef ref,
    UserModel user,
  ) {
    showDialog(
      context: context,
      builder: (context) => _ViewUserDialog(user: user),
    );
  }

  /// shows delete confirmation dialog and handles the delete action
  static void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    UserModel user,
    ValueNotifier<bool> isDeleting,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
        title: Text(
          'Delete User',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to delete ${user.fullName}?',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: AppTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              isDeleting.value = true;
              final error = await ref
                  .read(allUsersProvider.notifier)
                  .deleteUser(user.id);
              isDeleting.value = false;
              if (error != null && context.mounted) {
                AppSnackbar.showError(context, error);
              }
            },
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(
                color: const Color(0xFFD32F2F),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// shows edit user dialog
  static void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    UserModel user,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _EditUserDialog(user: user),
    );
  }
}

/// dialog for viewing user details
class _ViewUserDialog extends HookConsumerWidget {
  final UserModel user;

  const _ViewUserDialog({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDetail = useState<UserModel?>(user);
    final isLoading = useState<bool>(true);

    useEffect(() {
      Future.microtask(() async {
        final result = await ref
            .read(allUsersProvider.notifier)
            .getUser(user.id);
        result.fold(
          (_) {
            isLoading.value = false;
          },
          (fetchedUser) {
            userDetail.value = fetchedUser;
            isLoading.value = false;
          },
        );
      });
      return null;
    }, []);

    final currentUser = userDetail.value ?? user;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        constraints: const BoxConstraints(maxWidth: 450),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'User Details',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  color: AppTheme.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (isLoading.value)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: CircularProgressIndicator(),
                ),
              )
            else ...[
              // Profile Section
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.blue.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.blue.withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          currentUser.firstname.isNotEmpty
                              ? currentUser.firstname[0].toUpperCase()
                              : '?',
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.blue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      currentUser.fullName,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        currentUser.roles.isNotEmpty
                            ? currentUser.roles.first.name
                            : 'No Role',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // details grid/list
              _DetailItem(
                label: 'Email Address',
                value: currentUser.email,
                icon: Icons.email_outlined,
              ),
              const _Divider(),
              _DetailItem(
                label: 'Phone Number',
                value: currentUser.phoneno,
                icon: Icons.phone_outlined,
              ),
              const _Divider(),
              _DetailItem(
                label: 'Address',
                value: currentUser.address ?? 'N/A',
                icon: Icons.location_on_outlined,
              ),
              const _Divider(),
              Row(
                children: [
                  Expanded(
                    child: _DetailItem(
                      label: 'Account Status',
                      value: currentUser.isActive ? 'Active' : 'Inactive',
                      icon: Icons.verified_user_outlined,
                      valueColor: currentUser.isActive
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFD32F2F),
                    ),
                  ),
                  Expanded(
                    child: _DetailItem(
                      label: 'Verified',
                      value: currentUser.isVerified ? 'Verified' : 'Pending',
                      icon: Icons.check_circle_outline,
                      valueColor: currentUser.isVerified
                          ? const Color(0xFF2E7D32)
                          : Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Close',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _DetailItem({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: AppTheme.textSecondary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: valueColor ?? AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Divider(height: 24, color: Colors.grey.withOpacity(0.1));
  }
}

/// dialog for editing user details
class _EditUserDialog extends HookConsumerWidget {
  final UserModel user;

  const _EditUserDialog({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final firstNameController = useTextEditingController(text: user.firstname);
    final lastNameController = useTextEditingController(text: user.lastname);
    final emailController = useTextEditingController(text: user.email);
    final addressController = useTextEditingController(text: user.address);
    final phoneController = useTextEditingController(text: user.phoneno);

    final rolesAsync = ref.watch(rolesProvider);

    final selectedRoleId = useState<int?>(
      user.roles.isNotEmpty ? user.roles.first.id : null,
    );
    final isSubmitting = useState<bool>(false);

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // header with icon
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.blue.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  color: AppTheme.blue,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Edit User Profile',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              'Update details for ${user.fullName}',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // form fields
            Flexible(
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              label: 'First Name',
                              hint: 'e.g. John',
                              controller: firstNameController,
                              validator: (val) => Validators.validateRequired(
                                val,
                                'First name',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomTextField(
                              label: 'Last Name',
                              hint: 'e.g. Doe',
                              controller: lastNameController,
                              validator: (val) =>
                                  Validators.validateRequired(val, 'Last name'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Email address',
                        hint: 'e.g. john.doe@example.com',
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.email_outlined, size: 20),
                        validator: Validators.validateEmail,
                      ),
                      const SizedBox(height: 16),
                      rolesAsync.when(
                        data: (roles) => AppDropdown<int>(
                          hint: 'Role',
                          value: selectedRoleId.value,
                          prefixIcon: const Icon(
                            Icons.badge_outlined,
                            size: 20,
                          ),
                          items: roles.map((role) {
                            return DropdownMenuItem<int>(
                              value: role.id,
                              child: Text(role.name),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) selectedRoleId.value = val;
                          },
                          validator: (val) {
                            if (val == null) return 'Role is required';
                            return null;
                          },
                        ),
                        loading: () => const AppDropdown<int>(
                          hint: 'Loading roles...',
                          items: [],
                          onChanged: null,
                        ),
                        error: (_, __) => const AppDropdown<int>(
                          hint: 'Error loading roles',
                          items: [],
                          onChanged: null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Address',
                        hint: 'e.g. 123 Main St, Lagos',
                        controller: addressController,
                        prefixIcon: const Icon(
                          Icons.location_on_outlined,
                          size: 20,
                        ),
                        validator: (val) =>
                            Validators.validateRequired(val, 'Address'),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Phone number',
                        hint: 'e.g. 08012345678',
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                        validator: Validators.validatePhone,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // actions
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isSubmitting.value
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) {
                              return;
                            }

                            final body = <String, dynamic>{
                              'role_id': selectedRoleId.value,
                              'firstname': firstNameController.text.trim(),
                              'lastname': lastNameController.text.trim(),
                              'email': emailController.text.trim(),
                              'address': addressController.text.trim(),
                              'phoneno': phoneController.text.trim(),
                            };

                            final error = await ref
                                .read(allUsersProvider.notifier)
                                .updateUser(user.id, body);

                            isSubmitting.value = false;

                            if (!context.mounted) return;

                            if (error != null) {
                              AppSnackbar.showError(context, error);
                              return;
                            }

                            AppSnackbar.showSuccess(
                              context,
                              'User updated successfully',
                            );
                            Navigator.pop(context);
                          },
                    style:
                        ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ).copyWith(
                          overlayColor: WidgetStateProperty.all(Colors.white10),
                        ),
                    child: isSubmitting.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Save Changes',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
