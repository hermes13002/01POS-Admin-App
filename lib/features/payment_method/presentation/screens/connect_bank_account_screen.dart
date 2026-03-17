import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/shared/widgets/app_dropdown.dart';
import 'package:onepos_admin_app/shared/widgets/custom_button.dart';
import 'package:onepos_admin_app/shared/widgets/custom_text_field.dart';
import 'package:onepos_admin_app/core/utils/validators.dart';
import 'package:onepos_admin_app/shared/widgets/app_snackbar.dart';
import 'package:google_fonts/google_fonts.dart';

class ConnectBankAccountScreen extends HookConsumerWidget {
  const ConnectBankAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.2),
      body: const SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(AppTheme.spacingMedium),
            child: ConnectBankAccountDialog(),
          ),
        ),
      ),
    );
  }
}

class ConnectBankAccountDialog extends HookConsumerWidget {
  const ConnectBankAccountDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final accountController = useTextEditingController();
    final bankSearchController = useTextEditingController();
    final searchQuery = useState('');
    final selectedBank = useState<String?>(null);
    final isSubmitting = useState(false);

    const allBanks = <String>[
      'Access Bank',
      'First Bank',
      'GTBank',
      'UBA',
      'Zenith Bank',
      'Fidelity Bank',
      'Union Bank',
      'Sterling Bank',
    ];

    final filteredBanks = allBanks
        .where(
          (bank) => bank.toLowerCase().contains(
            searchQuery.value.trim().toLowerCase(),
          ),
        )
        .toList();

    if (selectedBank.value != null &&
        !filteredBanks.contains(selectedBank.value)) {
      selectedBank.value = null;
    }

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMedium,
        vertical: AppTheme.spacingLarge,
      ),
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 460),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingLarge),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.blue.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.account_balance_rounded,
                        color: AppTheme.blue,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingSmall),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Connect Bank Account',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Add account details to validate your payout account',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppTheme.grey600),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingMedium),

                Text(
                  'Account Number',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                CustomTextField(
                  hint: 'Enter 10-digit account number',
                  controller: accountController,
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (val) {
                    final requiredValidation = Validators.validateRequired(
                      val,
                      'Account number',
                    );
                    if (requiredValidation != null) return requiredValidation;

                    if ((val ?? '').trim().length != 10) {
                      return 'Account number must be 10 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.spacingSmall),

                Text(
                  'Find Bank',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                CustomTextField(
                  hint: 'Type to search banks...',
                  controller: bankSearchController,
                  onChanged: (value) {
                    searchQuery.value = value;
                  },
                  prefixIcon: const Icon(Icons.search, size: 20),
                ),
                const SizedBox(height: AppTheme.spacingSmall),

                AppDropdown<String>(
                  hint: 'Select Bank',
                  value: selectedBank.value,
                  items: filteredBanks
                      .map(
                        (bank) => DropdownMenuItem<String>(
                          value: bank,
                          child: Text(bank),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => selectedBank.value = value,
                  validator: (value) =>
                      Validators.validateRequired(value, 'Bank'),
                ),

                if (selectedBank.value != null ||
                    accountController.text.trim().isNotEmpty) ...[
                  const SizedBox(height: AppTheme.spacingMedium),
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingMedium),
                    decoration: BoxDecoration(
                      color: AppTheme.blue.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(
                        AppTheme.borderRadiusMedium,
                      ),
                      border: Border.all(
                        color: AppTheme.blue.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.verified_user_outlined,
                          color: AppTheme.blue,
                          size: 20,
                        ),
                        const SizedBox(width: AppTheme.spacingSmall),
                        Expanded(
                          child: Text(
                            'Bank: ${selectedBank.value ?? 'Not selected'}\nAccount: ${accountController.text.isEmpty ? '---' : accountController.text}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppTheme.grey700,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: AppTheme.spacingLarge),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.grey300),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingSmall),
                    Expanded(
                      child: CustomButton(
                        text: 'Validate Account',
                        isLoading: isSubmitting.value,
                        onPressed: () async {
                          if (isSubmitting.value ||
                              !formKey.currentState!.validate()) {
                            return;
                          }

                          isSubmitting.value = true;
                          await Future<void>.delayed(
                            const Duration(milliseconds: 600),
                          );
                          isSubmitting.value = false;

                          if (!context.mounted) return;

                          AppSnackbar.showInfo(
                            context,
                            'Validation UI ready. Endpoint integration is pending.',
                          );
                        },
                        backgroundColor: AppTheme.blue,
                        textColor: Colors.white,
                        height: 48,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
