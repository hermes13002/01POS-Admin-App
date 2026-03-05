import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onepos_admin_app/core/routes/app_routes.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/features/payment_method/data/models/payment_method_model.dart';
import 'package:onepos_admin_app/shared/widgets/custom_app_bar.dart';
import 'package:onepos_admin_app/shared/widgets/custom_button_with_icon.dart';
import 'package:onepos_admin_app/shared/widgets/custom_search_bar.dart';

/// Screen for viewing and managing payment methods
class PaymentMethodScreen extends HookConsumerWidget {
  const PaymentMethodScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // mock data
    final paymentMethods = useMemoized(
      () => [
        PaymentMethodModel(
          id: '1',
          name: 'John Doe',
          bankName: 'Access Bank',
          accountNumber: '**** 54321',
          accountName: 'John Doe',
        ),
      ],
    );

    final expandedIndex = useState<int?>(0);
    final searchController = useTextEditingController();
    final isFabExpanded = useState<bool>(false);

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
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSmall),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(
                      AppTheme.spacingMedium,
                    ).copyWith(bottom: 120), // space for fab & menu
                    itemCount: paymentMethods.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppTheme.spacingMedium),
                    itemBuilder: (context, index) {
                      final method = paymentMethods[index];
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
                              // Top row: Name and Bank
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      method.name,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        method.bankName,
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
                                // Account Number row
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Account number',
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      method.accountNumber,
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Bank row
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Bank',
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      method.bankName,
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Account Name row
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Account name',
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      method.accountName,
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: AppTheme.textSecondary,
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

            // Dim Background Overlay when FAB is open
            if (isFabExpanded.value)
              GestureDetector(
                onTap: () => isFabExpanded.value = false,
                child: Container(
                  color: Colors.black.withOpacity(0.5),
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
          // Expandable menu items
          if (isFabExpanded.value) ...[
            // Connect Bank Account
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
                  onTap: () {
                    isFabExpanded.value = false;
                    Navigator.pushNamed(context, AppRoutes.connectBankAccount);
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

            // Add Payment Method
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
                  onTap: () {
                    isFabExpanded.value = false;
                    Navigator.pushNamed(context, AppRoutes.addPaymentMethod);
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

          // Main FAB acts just like a close/add button based on state
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
}
