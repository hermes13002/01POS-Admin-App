import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/shared/widgets/app_dropdown.dart';
import 'package:onepos_admin_app/shared/widgets/custom_app_bar.dart';
import 'package:onepos_admin_app/shared/widgets/custom_button.dart';
import 'package:onepos_admin_app/shared/widgets/custom_text_field.dart';
import 'package:onepos_admin_app/core/utils/validators.dart';
import 'package:onepos_admin_app/features/discount/data/models/discount_model.dart';
import 'package:onepos_admin_app/features/discount/presentation/providers/discount_provider.dart';
import 'package:onepos_admin_app/shared/widgets/app_snackbar.dart';
import 'package:onepos_admin_app/shared/widgets/custom_switch.dart';

/// Screen for adding or editing a discount
class AddDiscountScreen extends HookConsumerWidget {
  final DiscountModel? discount;
  const AddDiscountScreen({super.key, this.discount});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditing = discount != null;
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final nameController = useTextEditingController(text: discount?.name);
    final minPriceController = useTextEditingController(
      text: discount?.minimumPrice.toInt().toString(),
    );
    final discountValueController = useTextEditingController(
      text: discount?.discountValue.toInt().toString(),
    );
    final descController = useTextEditingController(
      text: discount?.description,
    );

    final selectedDiscountType = useState<String?>(
      discount?.discountType.toLowerCase() == 'percentage'
          ? 'Percentage'
          : 'Fixed',
    );
    final isActive = useState<bool>(discount?.isActive ?? true);
    final isLoading = useState(false);

    Future<void> handleSave() async {
      if (!formKey.currentState!.validate()) return;

      isLoading.value = true;
      try {
        final data = {
          'name': nameController.text.trim(),
          'minimum_price': double.parse(minPriceController.text.trim()),
          'discount_type': selectedDiscountType.value!.toLowerCase(),
          'discount_value': double.parse(discountValueController.text.trim()),
          'description': descController.text.trim(),
          'status': isActive.value ? 'active' : 'inactive',
        };

        if (isEditing) {
          await ref
              .read(discountsProvider.notifier)
              .updateDiscount(discount!.id, data);
        } else {
          await ref.read(discountsProvider.notifier).createDiscount(data);
        }

        if (context.mounted) {
          AppSnackbar.showSuccess(
            context,
            isEditing
                ? 'Discount updated successfully'
                : 'Discount created successfully',
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (context.mounted) {
          AppSnackbar.showError(context, e.toString());
        }
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: isEditing ? 'Edit Discount' : 'Add New Discount',
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomTextField(
                    label: 'Name',
                    hint: 'Weekend Promo',
                    controller: nameController,
                    validator: (val) =>
                        Validators.validateRequired(val, 'Name'),
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),

                  CustomTextField(
                    label: 'Minimum price',
                    hint: '5000',
                    controller: minPriceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (val) =>
                        Validators.validatePositiveNumber(val, 'Minimum price'),
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),

                  AppDropdown<String>(
                    hint: 'Discount type',
                    value: selectedDiscountType.value,
                    items: const [
                      DropdownMenuItem(value: 'Fixed', child: Text('Fixed')),
                      DropdownMenuItem(
                        value: 'Percentage',
                        child: Text('Percentage'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) selectedDiscountType.value = val;
                    },
                    validator: (val) =>
                        Validators.validateRequired(val, 'Discount type'),
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),

                  CustomTextField(
                    label: 'Discount value',
                    hint: '10',
                    controller: discountValueController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (val) => Validators.validatePositiveNumber(
                      val,
                      'Discount value',
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),

                  // Active Switch Container
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingMedium,
                      vertical: AppTheme.spacingSmall,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        AppTheme.borderRadiusMedium,
                      ),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Active',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        CustomSwitch(
                          value: isActive.value,
                          activeColor: const Color(0xFF4CAF50), // green
                          onChanged: (val) {
                            isActive.value = val;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),

                  CustomTextField(
                    label: 'Description',
                    hint: 'Enter discount description',
                    controller: descController,
                    maxLines: 5,
                  ),

                  const SizedBox(height: AppTheme.spacingLarge),

                  CustomButton(
                    text: isEditing ? 'Update Discount' : 'Add Discount',
                    isLoading: isLoading.value,
                    onPressed: handleSave,
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
