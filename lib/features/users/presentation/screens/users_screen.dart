import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onepos_admin_app/core/routes/app_routes.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/features/users/data/models/user_model.dart';
import 'package:onepos_admin_app/shared/widgets/custom_app_bar.dart';
import 'package:onepos_admin_app/shared/widgets/custom_button_with_icon.dart';
import 'package:onepos_admin_app/shared/widgets/custom_search_bar.dart';

/// Screen for viewing and managing users
class UsersScreen extends HookConsumerWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // mock data
    final users = useMemoized(
      () => [
        UserModel(
          id: '1',
          name: 'John Doe',
          email: 'Johndoe123@gmail.com',
          role: 'Cashier',
          isActive: true, // true uses green Active
        ),
        UserModel(
          id: '2',
          name: 'Jane Doe',
          email: 'Janedoe123@gmail.com',
          role: 'Manager',
          isActive: false,
        ),
        UserModel(
          id: '3',
          name: 'Jill Doe',
          email: 'Jilldoe123@gmail.com',
          role: 'Supervisor',
          isActive: false,
        ),
        UserModel(
          id: '4',
          name: 'Jenna Doe',
          email: 'Jennadoe123@gmail.com',
          role: 'Lender',
          isActive: false,
        ),
      ],
    );

    final expandedIndex = useState<int?>(0);
    final searchController = useTextEditingController();

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
              child: ListView.separated(
                padding: const EdgeInsets.all(
                  AppTheme.spacingMedium,
                ).copyWith(bottom: 80), // space for fab
                itemCount: users.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppTheme.spacingMedium),
                itemBuilder: (context, index) {
                  final user = users[index];
                  final isExpanded = expandedIndex.value == index;

                  return GestureDetector(
                    onTap: () {
                      if (isExpanded) {
                        expandedIndex.value = null;
                      } else {
                        expandedIndex.value = index;
                      }
                    },
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
                          // Top row: Name/Email and Role
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.name,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      user.email,
                                      style: GoogleFonts.poppins(
                                        fontSize:
                                            10, // matching the smaller lightweight text from design
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    user.role,
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

                          // Expanded content
                          if (isExpanded) ...[
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 16),
                            // Status row
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
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Action Buttons
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
                                    text: 'Delete',
                                    icon: Icons.delete_outline,
                                    onPressed: () {},
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
}
