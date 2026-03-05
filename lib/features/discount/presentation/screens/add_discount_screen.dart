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

/// Screen for adding a new discount
class AddDiscountScreen extends HookConsumerWidget {
  const AddDiscountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final nameController = useTextEditingController();
    final minPriceController = useTextEditingController();
    final discountValueController = useTextEditingController();
    final descController = useTextEditingController();

    final selectedDiscountType = useState<String?>('Fixed');
    final isActive = useState<bool>(true);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Add New Discount',
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
                CustomTextField(
                  hint: 'Name',
                  controller: nameController,
                  validator: (val) => Validators.validateRequired(val, 'Name'),
                ),
                const SizedBox(height: AppTheme.spacingMedium),

                CustomTextField(
                  hint: 'Minimum price',
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
                  hint: 'Discount value',
                  controller: discountValueController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (val) =>
                      Validators.validatePositiveNumber(val, 'Discount value'),
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
                      CupertinoSwitch(
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
                  hint: 'Description',
                  controller: descController,
                  maxLines: 5,
                ),

                const Spacer(),

                CustomButton(
                  text:
                      'Add Bill', // Using Add Bill as instructed by image and task
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      // handle save logic
                      Navigator.pop(context);
                    }
                  },
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
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
