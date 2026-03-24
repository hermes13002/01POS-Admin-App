import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/features/online_store/presentation/providers/profile_provider.dart';
import 'package:onepos_admin_app/features/sales/presentation/providers/sales_provider.dart';
import 'package:onepos_admin_app/features/sales/presentation/services/sales_export_service.dart';
import 'package:onepos_admin_app/shared/widgets/loading_widget.dart';
import 'package:onepos_admin_app/shared/widgets/app_snackbar.dart';
import 'package:onepos_admin_app/shared/widgets/custom_app_bar2.dart';
import 'package:onepos_admin_app/shared/widgets/custom_switch.dart';

/// screen for sales-specific settings like download activation and export
class SalesSettingsScreen extends HookConsumerWidget {
  const SalesSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesState = ref.watch(salesProvider);
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final companyId = profile?.company?.id;

    final fromDate = useState<DateTime>(
      DateTime.now().subtract(const Duration(days: 30)),
    );
    final toDate = useState<DateTime>(DateTime.now());
    final exportFormat = useState<String>('Excel');

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: const CustomAppBar2(title: 'Sales Settings'),
      body: salesState.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (state) => Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // activation toggle card
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingMedium),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    AppTheme.borderRadiusMedium,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Activate Sales Download',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            'Enable CSV/PDF download for sales',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CustomSwitch(
                      value: state.isDownloadEnabled,
                      activeColor: AppTheme.blue,
                      onChanged: (value) async {
                        if (companyId == null) {
                          AppSnackbar.showError(
                            context,
                            'Company ID not found',
                          );
                          return;
                        }
                        try {
                          await ref
                              .read(salesProvider.notifier)
                              .toggleDownloadActivation(companyId, value);
                          if (context.mounted) {
                            AppSnackbar.showSuccess(
                              context,
                              value
                                  ? 'Sales download activated'
                                  : 'Sales download deactivated',
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            AppSnackbar.showError(context, e.toString());
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.spacingLarge),

              if (state.isDownloadEnabled) ...[
                Text(
                  'Download Sales Data',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSmall),
                Text(
                  'Select a date range to export your sales records.',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingMedium),

                // date tiles
                Row(
                  children: [
                    Expanded(
                      child: _DateTile(
                        label: 'From',
                        date: fromDate.value,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: fromDate.value,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) fromDate.value = picked;
                        },
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingMedium),
                    Expanded(
                      child: _DateTile(
                        label: 'To',
                        date: toDate.value,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: toDate.value,
                            firstDate: fromDate.value,
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) toDate.value = picked;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppTheme.spacingLarge),
                Text(
                  'Export Format',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSmall),
                Row(
                  children: [
                    _FormatTile(
                      label: 'Excel (.xlsx)',
                      subLabel: 'Best for data analysis',
                      icon: Icons.table_chart_outlined,
                      isSelected: exportFormat.value == 'Excel',
                      onTap: () => exportFormat.value = 'Excel',
                    ),
                    const SizedBox(width: AppTheme.spacingMedium),
                    _FormatTile(
                      label: 'PDF (.pdf)',
                      subLabel: 'Best for sharing/printing',
                      icon: Icons.picture_as_pdf_outlined,
                      isSelected: exportFormat.value == 'PDF',
                      onTap: () => exportFormat.value = 'PDF',
                    ),
                  ],
                ),

                const Spacer(),

                // download button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final from = DateFormat(
                        'yyyy-MM-dd',
                      ).format(fromDate.value);
                      final to = DateFormat('yyyy-MM-dd').format(toDate.value);

                      try {
                        AppSnackbar.showInfo(
                          context,
                          'Fetching sales records...',
                        );
                        final sales = await ref
                            .read(salesProvider.notifier)
                            .downloadSales(from: from, to: to);

                        if (sales.isEmpty) {
                          if (context.mounted) {
                            AppSnackbar.showInfo(
                              context,
                              'No sales found for this period',
                            );
                          }
                          return;
                        }

                        if (context.mounted) {
                          AppSnackbar.showInfo(
                            context,
                            'Generating ${exportFormat.value} file...',
                          );

                          if (exportFormat.value == 'Excel') {
                            await SalesExportService.exportToExcel(sales);
                          } else {
                            await SalesExportService.exportToPdf(sales);
                          }

                          if (context.mounted) {
                            AppSnackbar.showSuccess(
                              context,
                              'Export completed successfully',
                            );
                          }
                        }
                      } catch (e) {
                        if (context.mounted) {
                          AppSnackbar.showError(context, e.toString());
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.borderRadiusMedium,
                        ),
                      ),
                    ),
                    child: Text(
                      'Download Sales ${exportFormat.value.toUpperCase()}',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FormatTile extends StatelessWidget {
  final String label;
  final String subLabel;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FormatTile({
    required this.label,
    required this.subLabel,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingMedium),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.blue.withValues(alpha: 0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            border: Border.all(
              color: isSelected ? AppTheme.blue : Colors.grey.shade200,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: isSelected ? AppTheme.blue : AppTheme.textSecondary,
                size: 24,
              ),
              const SizedBox(height: AppTheme.spacingSmall),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                subLabel,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DateTile({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('MMM dd, yyyy').format(date),
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
