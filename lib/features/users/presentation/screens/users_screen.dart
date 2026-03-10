import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onepos_admin_app/core/routes/app_routes.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/features/users/data/models/user_model.dart';
import 'package:onepos_admin_app/features/users/presentation/providers/users_provider.dart';
import 'package:onepos_admin_app/shared/widgets/custom_app_bar.dart';
import 'package:onepos_admin_app/shared/widgets/custom_button_with_icon.dart';
import 'package:onepos_admin_app/shared/widgets/custom_search_bar.dart';
import 'package:onepos_admin_app/shared/widgets/loading_widget.dart';

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
                  final filteredUsers =
                      _filterUsers(usersState.users, searchQuery.value);

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
                          filteredUsers.length + (usersState.hasMorePages ? 1 : 0),
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
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.addUser);
        },
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  /// filters users by name, email, or role
  List<UserModel> _filterUsers(List<UserModel> users, String query) {
    if (query.isEmpty) return users;
    final lowerQuery = query.toLowerCase();
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
          borderRadius: BorderRadius.circular(
            AppTheme.borderRadiusMedium,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
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
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      else
                        SizedBox(
                          height: 24,
                          child: Switch(
                            value: user.isActive,
                            activeColor: const Color(0xFF4CAF50),
                            onChanged: (value) async {
                              isToggling.value = true;
                              final error = await ref
                                  .read(allUsersProvider.notifier)
                                  .toggleUserStatus(
                                    user.id,
                                    activate: value,
                                  );
                              isToggling.value = false;
                              if (error != null && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(error),
                                    backgroundColor: const Color(0xFFD32F2F),
                                  ),
                                );
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
                      text: 'Edit',
                      icon: Icons.edit_outlined,
                      onPressed: () {},
                      isOutlined: true,
                      textColor: AppTheme.blue,
                      iconColor: AppTheme.blue,
                      borderColor: AppTheme.blue,
                      height: 44,
                    ),
                  ),
                  const SizedBox(width: 12),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error),
                    backgroundColor: const Color(0xFFD32F2F),
                  ),
                );
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
}
