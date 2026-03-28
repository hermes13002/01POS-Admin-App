import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onepos_admin_app/core/routes/app_routes.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/features/customers/data/models/customer_model.dart';
import 'package:onepos_admin_app/features/customers/presentation/providers/customers_provider.dart';
import 'package:onepos_admin_app/shared/widgets/custom_button.dart';
import 'package:onepos_admin_app/shared/widgets/custom_app_bar2.dart';
import 'package:onepos_admin_app/shared/widgets/custom_search_bar.dart';
import 'package:onepos_admin_app/shared/widgets/custom_text_field.dart';
import 'package:onepos_admin_app/shared/widgets/app_snackbar.dart';
import 'package:onepos_admin_app/shared/widgets/loading_widget.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

/// customers screen with expandable customer tiles
class CustomersScreen extends HookConsumerWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final searchQuery = useState('');
    final expandedCustomerId = useState<int?>(null);
    final scrollController = useScrollController();
    final customersAsync = ref.watch(customersProvider);

    useEffect(() {
      Future.microtask(() {
        ref.read(customersProvider.notifier).refreshCustomers();
      });
      return null;
    }, const []);

    // listen for search changes
    useEffect(() {
      void listener() {
        searchQuery.value = searchController.text;
      }

      searchController.addListener(listener);
      return () => searchController.removeListener(listener);
    }, [searchController]);

    useEffect(() {
      void onScroll() {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
          ref.read(customersProvider.notifier).fetchNextPage();
        }
      }

      scrollController.addListener(onScroll);
      return () => scrollController.removeListener(onScroll);
    }, [scrollController]);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: CustomAppBar2(
        title: 'Customers',
        backgroundColor: AppTheme.backgroundColor,
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.more_horiz, color: Colors.black),
        //     onPressed: () {

        //     },
        //   ),
        // ],
      ),
      body: Column(
        children: [
          // search bar
          CustomSearchBar(
            controller: searchController,
            onChanged: (value) => searchQuery.value = value,
            onClear: () => searchQuery.value = '',
          ),

          // customers list
          Expanded(
            child: customersAsync.when(
              data: (customersState) {
                final filtered = _filterCustomers(
                  customersState.customers,
                  searchQuery.value,
                );

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      'No customers found',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  );
                }

                return AnimationLimiter(
                  child: ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingMedium,
                      vertical: AppTheme.spacingSmall,
                    ),
                    itemCount:
                        filtered.length + (customersState.hasMorePages ? 1 : 0),
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppTheme.spacingSmall),
                    itemBuilder: (context, index) {
                      if (index >= filtered.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final customer = filtered[index];
                      final isExpanded =
                          expandedCustomerId.value == customer.id;

                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 375),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: _CustomerTile(
                              customer: customer,
                              isExpanded: isExpanded,
                              onToggle: () {
                                expandedCustomerId.value = isExpanded
                                    ? null
                                    : customer.id;
                              },
                              onView: () =>
                                  _showViewDialog(context, ref, customer.id),
                              onEdit: () =>
                                  _showEditDialog(context, ref, customer.id),
                              onDelete: () => _showDeleteConfirmation(
                                context,
                                ref,
                                customer,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: LoadingWidget()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Failed to load customers',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingMedium),
                    ElevatedButton(
                      onPressed: () => ref
                          .read(customersProvider.notifier)
                          .refreshCustomers(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // fab with add customer option
      floatingActionButton: _AddCustomerFab(
        onAddCustomer: () async {
          final created = await Navigator.pushNamed(
            context,
            AppRoutes.addCustomer,
          );
          if (created == true) {
            await ref.read(customersProvider.notifier).refreshCustomers();
          }
        },
      ),
    );
  }

  /// filters customers by name, comment and preference
  List<CustomerModel> _filterCustomers(
    List<CustomerModel> customers,
    String query,
  ) {
    final lowerQuery = query.trim().toLowerCase();
    if (lowerQuery.isEmpty) return customers;

    return customers.where((customer) {
      return customer.name.toLowerCase().contains(lowerQuery) ||
          (customer.comment ?? '').toLowerCase().contains(lowerQuery) ||
          (customer.preference ?? '').toLowerCase().contains(lowerQuery) ||
          customer.id.toString().contains(lowerQuery);
    }).toList();
  }

  /// show single customer details dialog
  Future<void> _showViewDialog(
    BuildContext context,
    WidgetRef ref,
    int customerId,
  ) async {
    try {
      final customer = await ref
          .read(customersProvider.notifier)
          .getCustomer(customerId);
      if (!context.mounted) return;
      await showDialog(
        context: context,
        builder: (_) => _ViewCustomerDialog(customer: customer),
      );
    } catch (error) {
      if (!context.mounted) return;
      AppSnackbar.showError(
        context,
        error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  /// show edit customer dialog
  Future<void> _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    int customerId,
  ) async {
    try {
      final customer = await ref
          .read(customersProvider.notifier)
          .getCustomer(customerId);
      if (!context.mounted) return;

      await showDialog(
        context: context,
        builder: (_) => _EditCustomerDialog(customer: customer),
      );
    } catch (error) {
      if (!context.mounted) return;
      AppSnackbar.showError(
        context,
        error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  /// show delete confirmation dialog
  Future<void> _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    CustomerModel customer,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _DeleteCustomerDialog(customerName: customer.name),
    );

    if (confirmed != true || !context.mounted) return;

    final error = await ref
        .read(customersProvider.notifier)
        .deleteCustomer(customer.id);
    if (!context.mounted) return;

    if (error != null) {
      AppSnackbar.showError(context, error);
      return;
    }

    AppSnackbar.showSuccess(context, 'Customer deleted successfully');
  }
}

/// expandable customer tile
class _CustomerTile extends StatelessWidget {
  final CustomerModel customer;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CustomerTile({
    required this.customer,
    required this.isExpanded,
    required this.onToggle,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: Column(
        children: [
          // header row (always visible)
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMedium),
              child: Row(
                children: [
                  // customer info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.name,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          customer.comment ?? customer.preference ?? 'N/A',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // expand/collapse icon
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppTheme.textSecondary,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),

          // expanded content - action buttons
          if (isExpanded) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMedium,
              ),
              child: Divider(color: AppTheme.grey200, height: 1),
            ),

            // action buttons row
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spacingMedium,
                AppTheme.spacingSmall + 4,
                AppTheme.spacingMedium,
                AppTheme.spacingMedium,
              ),
              child: Row(
                children: [
                  // view button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onView,
                      icon: Icon(
                        Icons.visibility_outlined,
                        size: 18,
                        color: AppTheme.textSecondary,
                      ),
                      label: Text(
                        'View',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppTheme.grey300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.borderRadiusMedium,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingSmall),

                  // edit button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: AppTheme.blue,
                      ),
                      label: Text(
                        'Edit',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppTheme.blue,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppTheme.blue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.borderRadiusMedium,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingSmall),

                  // delete button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: AppTheme.errorColor,
                      ),
                      label: Text(
                        'Delete',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppTheme.errorColor,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Color(0xFFFFCDD2)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.borderRadiusMedium,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// fab with add customer option
class _AddCustomerFab extends HookWidget {
  final VoidCallback onAddCustomer;

  const _AddCustomerFab({required this.onAddCustomer});

  @override
  Widget build(BuildContext context) {
    final isExpanded = useState(false);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // expanded option
        if (isExpanded.value) ...[
          _FabOption(
            label: 'Add Customer',
            color: const Color(0xFF1E88E5),
            icon: Icons.person_add_outlined,
            onTap: () {
              isExpanded.value = false;
              onAddCustomer();
            },
          ),
          const SizedBox(height: AppTheme.spacingSmall + 4),
        ],

        // main fab
        FloatingActionButton(
          onPressed: () => isExpanded.value = !isExpanded.value,
          backgroundColor: Colors.black,
          shape: const CircleBorder(),
          child: AnimatedRotation(
            turns: isExpanded.value ? 0.125 : 0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ),
      ],
    );
  }
}

/// individual fab option button
class _FabOption extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _FabOption({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // label
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: AppTheme.spacingSmall + 4),

        // icon button
        SizedBox(
          width: 48,
          height: 48,
          child: FloatingActionButton(
            heroTag: label,
            onPressed: onTap,
            backgroundColor: color,
            elevation: 2,
            shape: const CircleBorder(),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
        ),
      ],
    );
  }
}

/// animated dialog for viewing customer
class _ViewCustomerDialog extends HookWidget {
  final CustomerModel customer;

  const _ViewCustomerDialog({required this.customer});

  @override
  Widget build(BuildContext context) {
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );

    useEffect(() {
      animationController.forward();
      return null;
    }, const []);

    Future<void> closeDialog() async {
      await animationController.reverse();
      if (context.mounted) {
        Navigator.pop(context);
      }
    }

    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animationController,
        curve: Curves.easeIn,
      ),
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Customer Details',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: closeDialog,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingMedium),
              _DialogInfoRow(label: 'Name', value: customer.name),
              _DialogInfoRow(
                label: 'Comment',
                value: customer.comment ?? 'N/A',
              ),
              _DialogInfoRow(
                label: 'Email or Phone Number',
                value: customer.preference ?? 'N/A',
              ),
              _DialogInfoRow(
                label: 'Loyalty point',
                value: customer.loyaltyPoint.toStringAsFixed(2),
              ),
              _DialogInfoRow(
                label: 'Status',
                value: customer.isActive ? 'Active' : 'Inactive',
              ),
              const SizedBox(height: AppTheme.spacingLarge),
              CustomButton(
                text: 'Close',
                onPressed: closeDialog,
                backgroundColor: AppTheme.blue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// animated dialog for editing customer
class _EditCustomerDialog extends HookConsumerWidget {
  final CustomerModel customer;

  const _EditCustomerDialog({required this.customer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final nameController = useTextEditingController(text: customer.name);
    final commentController = useTextEditingController(
      text: customer.comment ?? '',
    );
    final preferenceController = useTextEditingController(
      text: customer.preference ?? '',
    );
    final isSaving = useState(false);

    useEffect(() {
      animationController.forward();
      return null;
    }, const []);

    Future<void> closeDialog() async {
      await animationController.reverse();
      if (context.mounted) {
        Navigator.pop(context);
      }
    }

    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animationController,
        curve: Curves.easeIn,
      ),
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingLarge),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Edit Customer',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      onPressed: closeDialog,
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingMedium),
                CustomTextField(
                  controller: nameController,
                  hint: 'Customer name',
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Customer name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.spacingMedium),
                CustomTextField(controller: commentController, hint: 'Comment'),
                const SizedBox(height: AppTheme.spacingMedium),
                CustomTextField(
                  controller: preferenceController,
                  hint: 'Email or Phone Number',
                ),
                const SizedBox(height: AppTheme.spacingLarge),
                CustomButton(
                  text: 'Save Changes',
                  isLoading: isSaving.value,
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) {
                      return;
                    }

                    isSaving.value = true;
                    final error = await ref
                        .read(customersProvider.notifier)
                        .updateCustomer(customer.id, {
                          'name': nameController.text.trim(),
                          'comment': commentController.text.trim(),
                          'preference': preferenceController.text.trim(),
                        });
                    isSaving.value = false;

                    if (!context.mounted) return;

                    if (error != null) {
                      AppSnackbar.showError(context, error);
                      return;
                    }

                    AppSnackbar.showSuccess(
                      context,
                      'Customer updated successfully',
                    );
                    await closeDialog();
                  },
                  backgroundColor: AppTheme.blue,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// animated dialog for confirming delete action
class _DeleteCustomerDialog extends HookWidget {
  final String customerName;

  const _DeleteCustomerDialog({required this.customerName});

  @override
  Widget build(BuildContext context) {
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );

    useEffect(() {
      animationController.forward();
      return null;
    }, const []);

    Future<void> closeWithResult(bool result) async {
      await animationController.reverse();
      if (context.mounted) {
        Navigator.pop(context, result);
      }
    }

    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animationController,
        curve: Curves.easeIn,
      ),
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Delete Customer',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppTheme.spacingSmall),
              Text(
                'Are you sure you want to delete "$customerName"?',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: AppTheme.spacingLarge),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Cancel',
                      isOutlined: true,
                      onPressed: () => closeWithResult(false),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMedium),
                  Expanded(
                    child: CustomButton(
                      text: 'Delete',
                      backgroundColor: AppTheme.errorColor,
                      onPressed: () => closeWithResult(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _DialogInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
