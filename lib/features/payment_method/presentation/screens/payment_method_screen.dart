import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onepos_admin_app/core/routes/app_routes.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/features/payment_method/data/models/payment_method_model.dart';
import 'package:onepos_admin_app/features/payment_method/presentation/providers/payment_method_provider.dart';
import 'package:onepos_admin_app/features/payment_method/presentation/screens/connect_bank_account_screen.dart';
import 'package:onepos_admin_app/shared/widgets/custom_app_bar.dart';
import 'package:onepos_admin_app/shared/widgets/custom_button_with_icon.dart';
import 'package:onepos_admin_app/shared/widgets/custom_search_bar.dart';
import 'package:onepos_admin_app/shared/widgets/loading_widget.dart';
import 'package:onepos_admin_app/shared/widgets/app_snackbar.dart';
import 'package:onepos_admin_app/shared/widgets/custom_text_field.dart';

class PaymentMethodScreen extends HookConsumerWidget {
  const PaymentMethodScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final searchQuery = useState('');
    final expandedMethodId = useState<int?>(null);
    final isFabExpanded = useState<bool>(false);
    final methodsAsync = ref.watch(paymentMethodsProvider);

    useEffect(() {
      Future.microtask(() {
        ref.read(paymentMethodsProvider.notifier).refreshPaymentMethods();
      });
      return null;
    }, const []);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Payment Method',
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
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
                    onChanged: (value) => searchQuery.value = value,
                    onClear: () => searchQuery.value = '',
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSmall),
                Expanded(
                  child: methodsAsync.when(
                    data: (state) {
                      final filtered = _filterMethods(
                        state.methods,
                        searchQuery.value,
                      );

                      if (filtered.isEmpty) {
                        return Center(
                          child: Text(
                            'No payment methods found',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.all(
                          AppTheme.spacingMedium,
                        ).copyWith(bottom: 120),
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: AppTheme.spacingMedium),
                        itemBuilder: (context, index) {
                          final method = filtered[index];
                          final isExpanded =
                              expandedMethodId.value == method.id;

                          return GestureDetector(
                            onTap: () {
                              expandedMethodId.value = isExpanded
                                  ? null
                                  : method.id;
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.all(
                                AppTheme.spacingMedium,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                  AppTheme.borderRadiusMedium,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          method.methodName.isEmpty
                                              ? 'N/A'
                                              : method.methodName,
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                      ),
                                      // Text(
                                      //   '#${method.id}',
                                      //   style: GoogleFonts.poppins(
                                      //     fontSize: 12,
                                      //     color: AppTheme.textSecondary,
                                      //   ),
                                      // ),
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
                                  if (isExpanded) ...[
                                    const SizedBox(height: 16),
                                    const Divider(height: 1),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: CustomButtonWithIcon(
                                            text: 'Edit',
                                            icon: Icons.edit_outlined,
                                            onPressed: () => _showEditDialog(
                                              context,
                                              ref,
                                              method.id,
                                            ),
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
                                            onPressed: () =>
                                                _showDeleteConfirmation(
                                                  context,
                                                  ref,
                                                  method,
                                                ),
                                            isOutlined: true,
                                            textColor: AppTheme.errorColor,
                                            iconColor: AppTheme.errorColor,
                                            borderColor: AppTheme.errorColor,
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
                      );
                    },
                    loading: () => const Center(child: LoadingWidget()),
                    error: (error, stack) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Failed to load payment methods',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingMedium),
                          ElevatedButton(
                            onPressed: () => ref
                                .read(paymentMethodsProvider.notifier)
                                .refreshPaymentMethods(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            if (isFabExpanded.value)
              GestureDetector(
                onTap: () => isFabExpanded.value = false,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.5),
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isFabExpanded.value) ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Connect Bank Account',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: () async {
                    isFabExpanded.value = false;
                    await showGeneralDialog<void>(
                      context: context,
                      barrierDismissible: true,
                      barrierLabel: 'Connect Bank Account',
                      barrierColor: Colors.black.withValues(alpha: 0.5),
                      transitionDuration: const Duration(milliseconds: 260),
                      pageBuilder: (_, __, ___) =>
                          const ConnectBankAccountDialog(),
                      transitionBuilder:
                          (
                            dialogContext,
                            animation,
                            secondaryAnimation,
                            child,
                          ) {
                            final curvedAnimation = CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                              reverseCurve: Curves.easeInCubic,
                            );

                            return FadeTransition(
                              opacity: curvedAnimation,
                              child: ScaleTransition(
                                scale: Tween<double>(
                                  begin: 0.94,
                                  end: 1,
                                ).animate(curvedAnimation),
                                child: child,
                              ),
                            );
                          },
                    );
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Color(0xFF9013FE), // purple from design
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Add Payment Method',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: () async {
                    isFabExpanded.value = false;
                    final created = await Navigator.pushNamed(
                      context,
                      AppRoutes.addPaymentMethod,
                    );
                    if (created == true) {
                      await ref
                          .read(paymentMethodsProvider.notifier)
                          .refreshPaymentMethods();
                    }
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4A90E2), // blue from design
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          FloatingActionButton(
            backgroundColor: isFabExpanded.value ? Colors.white : Colors.black,
            onPressed: () {
              isFabExpanded.value = !isFabExpanded.value;
            },
            child: Icon(
              isFabExpanded.value ? Icons.close : Icons.add,
              color: isFabExpanded.value ? Colors.black : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  List<PaymentMethodModel> _filterMethods(
    List<PaymentMethodModel> methods,
    String query,
  ) {
    final lowerQuery = query.trim().toLowerCase();
    if (lowerQuery.isEmpty) return methods;

    return methods
        .where(
          (item) =>
              item.methodName.toLowerCase().contains(lowerQuery) ||
              item.id.toString().contains(lowerQuery),
        )
        .toList();
  }

  Future<void> _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    int methodId,
  ) async {
    try {
      final method = await ref
          .read(paymentMethodsProvider.notifier)
          .getPaymentMethod(methodId);
      if (!context.mounted) return;

      final controller = TextEditingController(text: method.methodName);
      final saved = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Edit Payment Method'),
            content: CustomTextField(
              label: 'Payment Method Name',
              controller: controller,
              hint: 'e.g. Bank Transfer',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Save'),
              ),
            ],
          );
        },
      );

      if (saved != true || !context.mounted) return;

      final value = controller.text.trim();
      if (value.isEmpty) {
        AppSnackbar.showWarning(context, 'Payment method name is required');
        return;
      }

      final error = await ref
          .read(paymentMethodsProvider.notifier)
          .updatePaymentMethod(methodId, {'method_name': value});

      if (!context.mounted) return;
      if (error != null) {
        AppSnackbar.showError(context, error);
        return;
      }

      AppSnackbar.showSuccess(context, 'Payment method updated successfully');
    } catch (error) {
      if (!context.mounted) return;
      AppSnackbar.showError(
        context,
        error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    PaymentMethodModel method,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Payment Method'),
          content: Text(
            'Are you sure you want to delete "${method.methodName.isEmpty ? 'N/A' : method.methodName}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    final error = await ref
        .read(paymentMethodsProvider.notifier)
        .deletePaymentMethod(method.id);
    if (!context.mounted) return;

    if (error != null) {
      AppSnackbar.showError(context, error);
      return;
    }

    AppSnackbar.showSuccess(context, 'Payment method deleted successfully');
  }
}
