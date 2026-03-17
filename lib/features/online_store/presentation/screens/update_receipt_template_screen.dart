import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/features/online_store/data/models/receipt_template_model.dart';
import 'package:onepos_admin_app/features/online_store/presentation/providers/receipt_template_provider.dart';
import 'package:onepos_admin_app/shared/widgets/custom_app_bar.dart';
import 'package:onepos_admin_app/shared/widgets/app_snackbar.dart';
import 'package:onepos_admin_app/shared/widgets/custom_button.dart';
import 'package:onepos_admin_app/shared/widgets/loading_widget.dart';

class UpdateReceiptTemplateScreen extends HookConsumerWidget {
  const UpdateReceiptTemplateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templateAsync = ref.watch(receiptTemplateProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: CustomAppBar(
        title: 'Update Receipt Template',
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
                  onPressed: () => ref
                      .read(receiptTemplateProvider.notifier)
                      .refreshTemplate(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (template) => _UpdateReceiptContent(template: template),
        ),
      ),
    );
  }
}

class _UpdateReceiptContent extends HookConsumerWidget {
  final ReceiptTemplateModel template;

  const _UpdateReceiptContent({required this.template});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // number of pages stepper
    final numberOfPages = useState<int>(
      template.numberOfPages <= 0 ? 1 : template.numberOfPages,
    );
    final isUpdating = useState(false);

    // header controllers
    final headerOneCtrl = useTextEditingController(
      text: template.headerLineOne,
    );
    final headerTwoCtrl = useTextEditingController(
      text: template.headerLineTwo,
    );
    final headerThreeCtrl = useTextEditingController(
      text: template.headerLineThree,
    );

    // footer controllers
    final footerOneCtrl = useTextEditingController(
      text: template.footerLineOne,
    );
    final footerTwoCtrl = useTextEditingController(
      text: template.footerLineTwo,
    );
    final footerThreeCtrl = useTextEditingController(
      text: template.footerLineThree,
    );

    final nowText = DateFormat('M/d/yyyy h:mm:ss a').format(DateTime.now());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // number of receipts stepper
          Row(
            children: [
              Text(
                'Number of receipts :',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(width: AppTheme.spacingSmall),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.grey300),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: numberOfPages.value > 1
                          ? () => numberOfPages.value -= 1
                          : null,
                      icon: const Icon(Icons.remove, size: 18),
                      visualDensity: VisualDensity.compact,
                    ),
                    Text(
                      numberOfPages.value.toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      onPressed: () => numberOfPages.value += 1,
                      icon: const Icon(Icons.add, size: 18),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMedium),

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
                _CenteredTextField(
                  controller: headerOneCtrl,
                  hint: 'Header line 1',
                ),
                const SizedBox(height: 8),
                _CenteredTextField(
                  controller: headerTwoCtrl,
                  hint: 'Header line 2',
                ),
                const SizedBox(height: 8),
                _CenteredTextField(
                  controller: headerThreeCtrl,
                  hint: 'Header line 3',
                ),
                const SizedBox(height: AppTheme.spacingMedium),

                SizedBox(
                  width: double.infinity,
                  child: Text(
                    nowText,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Cashier',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      color: AppTheme.textPrimary,
                    ),
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
                _CenteredTextField(
                  controller: footerOneCtrl,
                  hint: 'Footer line 1',
                ),
                const SizedBox(height: 8),
                _CenteredTextField(
                  controller: footerTwoCtrl,
                  hint: 'Footer line 2',
                ),
                const SizedBox(height: 8),
                _CenteredTextField(
                  controller: footerThreeCtrl,
                  hint: 'Footer line 3',
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spacingLarge),

          CustomButton(
            text: 'Update Receipt',
            isLoading: isUpdating.value,
            onPressed: () async {
              if (isUpdating.value) return;
              isUpdating.value = true;

              final error = await ref
                  .read(receiptTemplateProvider.notifier)
                  .updateTemplate(
                    numberOfPages: numberOfPages.value,
                    headerLineOne: headerOneCtrl.text.trim(),
                    headerLineTwo: headerTwoCtrl.text.trim(),
                    headerLineThree: headerThreeCtrl.text.trim(),
                    footerLineOne: footerOneCtrl.text.trim(),
                    footerLineTwo: footerTwoCtrl.text.trim(),
                    footerLineThree: footerThreeCtrl.text.trim(),
                  );

              isUpdating.value = false;
              if (!context.mounted) return;

              if (error != null) {
                AppSnackbar.showError(context, error);
                return;
              }

              AppSnackbar.showSuccess(
                context,
                'Receipt template updated successfully',
              );
              Navigator.pop(context);
            },
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

// text field with centered input text
class _CenteredTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const _CenteredTextField({required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width * 0.7,
        child: TextFormField(
          controller: controller,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppTheme.grey300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppTheme.grey300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppTheme.blue, width: 1.5),
            ),
          ),
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
