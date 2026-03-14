import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:onepos_admin_app/core/routes/app_routes.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/features/online_store/data/models/receipt_template_model.dart';
import 'package:onepos_admin_app/features/online_store/presentation/providers/receipt_template_provider.dart';
import 'package:onepos_admin_app/shared/widgets/custom_app_bar.dart';
import 'package:onepos_admin_app/shared/widgets/custom_button.dart';
import 'package:onepos_admin_app/shared/widgets/loading_widget.dart';

class ReceiptTemplateScreen extends ConsumerWidget {
  const ReceiptTemplateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templateAsync = ref.watch(receiptTemplateProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: CustomAppBar(
        title: 'Receipt Template Settings',
        centerTitle: false,
        backgroundColor: AppTheme.backgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: templateAsync.when(
          loading: () => const Center(child: LoadingWidget()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Failed to load receipt template',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingMedium),
                ElevatedButton(
                  onPressed: () =>
                      ref.read(receiptTemplateProvider.notifier).refreshTemplate(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (template) => _ReceiptTemplateContent(template: template),
        ),
      ),
    );
  }
}

class _ReceiptTemplateContent extends StatelessWidget {
  final ReceiptTemplateModel template;

  const _ReceiptTemplateContent({required this.template});

  @override
  Widget build(BuildContext context) {
    final nowText = DateFormat('M/d/yyyy h:mm:ss a').format(DateTime.now());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            decoration: BoxDecoration(
              color: AppTheme.grey100,
              border: Border.all(color: AppTheme.textPrimary),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Header',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSmall),
                _TemplateCenteredText(text: template.headerLineOne),
                const SizedBox(height: 6),
                _TemplateCenteredText(text: template.headerLineTwo),
                const SizedBox(height: 6),
                _TemplateCenteredText(text: template.headerLineThree),
                const SizedBox(height: AppTheme.spacingMedium),

                SizedBox(
                  width: double.infinity,
                  child: Text(
                    nowText,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Cashier',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),

                const _DashedDivider(),
                const SizedBox(height: AppTheme.spacingSmall),

                _lineItem('Product1 x 2', '400'),
                const SizedBox(height: 8),
                _lineItem('Product1 x 2', '400'),
                const SizedBox(height: 8),
                _lineItem('Total', '800', isBold: true),

                const SizedBox(height: AppTheme.spacingSmall),
                const _DashedDivider(),
                const SizedBox(height: AppTheme.spacingSmall),

                Text(
                  'Footer',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSmall),
                _TemplateCenteredText(text: template.footerLineOne),
                const SizedBox(height: 6),
                _TemplateCenteredText(text: template.footerLineTwo),
                const SizedBox(height: 6),
                _TemplateCenteredText(text: template.footerLineThree),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spacingLarge),

          CustomButton(
            text: 'Update Receipt',
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.updateReceiptTemplate,
            ),
            backgroundColor: AppTheme.blue,
            textColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _lineItem(String name, String amount, {bool isBold = false}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            name,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
        Text(
          '\$$amount',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _TemplateCenteredText extends StatelessWidget {
  final String text;

  const _TemplateCenteredText({required this.text});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Text(
        text.isEmpty ? '—' : text,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          fontSize: 13,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dashCount = (constraints.maxWidth / 10).floor();

        return Row(
          children: List.generate(
            dashCount,
            (index) => Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                height: 1,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        );
      },
    );
  }
}
