import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/features/payment_method/presentation/providers/payment_method_provider.dart';
import 'package:onepos_admin_app/shared/widgets/custom_app_bar.dart';
import 'package:onepos_admin_app/shared/widgets/custom_button.dart';
import 'package:onepos_admin_app/shared/widgets/custom_text_field.dart';
import 'package:onepos_admin_app/shared/widgets/app_snackbar.dart';
import 'package:onepos_admin_app/core/utils/validators.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:onepos_admin_app/shared/widgets/app_showcase.dart';
import 'package:onepos_admin_app/presentation/providers/guided_tour_provider.dart';

class AddPaymentMethodScreen extends StatelessWidget {
  const AddPaymentMethodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      builder: (context) => const _AddPaymentMethodScreenContent(),
    );
  }
}

class _AddPaymentMethodScreenContent extends HookConsumerWidget {
  const _AddPaymentMethodScreenContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final nameController = useTextEditingController();
    final isSubmitting = useState(false);

    // showcase keys
    final nameKey = useMemoized(() => GlobalKey());
    final saveKey = useMemoized(() => GlobalKey());
    final tourState = ref.watch(guidedTourProvider);

    // trigger guided tour sequence continuation
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (tourState == TourType.addPayment) {
          ShowCaseWidget.of(context).startShowCase([nameKey, saveKey]);
          ref
              .read(guidedTourProvider.notifier)
              .completeTour(TourType.addPayment);
        }
      });
      return null;
    }, [tourState]);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Add Payment Method',
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMedium),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppShowcase(
                  showcaseKey: nameKey,
                  description:
                      'Enter the name of your new payment method (e.g. Bank Transfer, Crypto).',
                  child: CustomTextField(
                    label: 'Payment Method Name',
                    hint: 'e.g. Bank Transfer',
                    controller: nameController,
                    validator: (val) =>
                        Validators.validateRequired(val, 'Payment method name'),
                  ),
                ),

                const Spacer(),

                AppShowcase(
                  showcaseKey: saveKey,
                  description:
                      'Tap here to add this payment method to your system.',
                  child: CustomButton(
                    text: 'Add Method',
                    isLoading: isSubmitting.value,
                    onPressed: () async {
                      if (!formKey.currentState!.validate() ||
                          isSubmitting.value) {
                        return;
                      }

                      isSubmitting.value = true;

                      final error = await ref
                          .read(paymentMethodsProvider.notifier)
                          .addPaymentMethod({
                            'method_name': nameController.text.trim(),
                          });

                      isSubmitting.value = false;

                      if (!context.mounted) return;

                      if (error != null) {
                        AppSnackbar.showError(context, error);
                        return;
                      }

                      AppSnackbar.showSuccess(
                        context,
                        'Payment method added successfully',
                      );

                      Navigator.pop(context, true);
                    },
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
