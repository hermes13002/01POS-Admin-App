import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/features/online_store/data/models/currency_model.dart';
import 'package:onepos_admin_app/features/online_store/presentation/providers/currency_settings_provider.dart';
import 'package:onepos_admin_app/shared/widgets/app_dropdown.dart';
import 'package:onepos_admin_app/shared/widgets/app_snackbar.dart';
import 'package:onepos_admin_app/shared/widgets/custom_app_bar.dart';
import 'package:onepos_admin_app/shared/widgets/custom_button.dart';
import 'package:onepos_admin_app/shared/widgets/loading_widget.dart';

class CurrencySettingsScreen extends HookConsumerWidget {
  const CurrencySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(currencySettingsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: CustomAppBar(
        title: 'Currency Settings',
        centerTitle: false,
        backgroundColor: AppTheme.backgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: settingsAsync.when(
          loading: () => const Center(child: LoadingWidget()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Failed to load currency settings',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingMedium),
                ElevatedButton(
                  onPressed: () => ref
                      .read(currencySettingsProvider.notifier)
                      .refreshSettings(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (state) => _CurrencySettingsContent(state: state),
        ),
      ),
    );
  }
}

class _CurrencySettingsContent extends ConsumerWidget {
  final CurrencySettingsState state;

  const _CurrencySettingsContent({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentCurrency = state.companyCurrency.currency;

    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              border: Border.all(color: AppTheme.grey300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Company Currency',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSmall),
                currentCurrency?.code.isNotEmpty == true
                    ? RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${currentCurrency!.code} (',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            TextSpan(
                              text: currentCurrency.symbol,
                              style: GoogleFonts.roboto(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            TextSpan(
                              text: ')',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Text(
                        '—',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                const SizedBox(height: 4),
                Text(
                  currentCurrency?.country.isNotEmpty == true
                      ? currentCurrency!.country
                      : 'not set',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingLarge),
          CustomButton(
            text: 'Update',
            onPressed: () => _showUpdateCurrencyDialog(context, ref, state),
            backgroundColor: AppTheme.blue,
            textColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Future<void> _showUpdateCurrencyDialog(
    BuildContext context,
    WidgetRef ref,
    CurrencySettingsState state,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => _UpdateCurrencyDialog(state: state),
    );
  }
}

class _UpdateCurrencyDialog extends HookConsumerWidget {
  final CurrencySettingsState state;

  const _UpdateCurrencyDialog({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCurrencyId = useState<String?>(
      state.companyCurrency.currencyId,
    );
    final isUpdating = useState(false);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Update Currency',
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
      ),
      content: SizedBox(
        width: 460,
        child: AppDropdown<String>(
          hint: 'Select currency',
          value: _hasCurrency(state.currencies, selectedCurrencyId.value)
              ? selectedCurrencyId.value
              : null,
          items: state.currencies
              .map(
                (currency) => DropdownMenuItem<String>(
                  value: currency.id.toString(),
                  child: Text(
                    currency.displayName,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: (value) => selectedCurrencyId.value = value,
        ),
      ),
      actions: [
        TextButton(
          onPressed: isUpdating.value ? null : () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: GoogleFonts.poppins(color: AppTheme.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: isUpdating.value
              ? null
              : () async {
                  final picked = selectedCurrencyId.value;
                  if (picked == null || picked.isEmpty) {
                    AppSnackbar.showWarning(
                      context,
                      'Please select a currency',
                    );
                    return;
                  }

                  isUpdating.value = true;
                  final error = await ref
                      .read(currencySettingsProvider.notifier)
                      .updateCurrency(currencyId: picked);
                  isUpdating.value = false;

                  if (!context.mounted) return;

                  if (error != null) {
                    AppSnackbar.showError(context, error);
                    return;
                  }

                  Navigator.pop(context);
                  AppSnackbar.showSuccess(
                    context,
                    'Currency updated successfully',
                  );
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.blue,
            foregroundColor: Colors.white,
          ),
          child: isUpdating.value
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text('Update Currency', style: GoogleFonts.poppins()),
        ),
      ],
    );
  }

  bool _hasCurrency(List<CurrencyModel> currencies, String? id) {
    if (id == null) return false;
    return currencies.any((currency) => currency.id.toString() == id);
  }
}
