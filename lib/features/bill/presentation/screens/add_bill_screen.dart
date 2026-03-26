import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/features/bill/data/models/auto_bill_model.dart';
import 'package:onepos_admin_app/features/bill/presentation/providers/bill_providers.dart';
import 'package:onepos_admin_app/shared/widgets/app_dropdown.dart';
import 'package:onepos_admin_app/shared/widgets/custom_app_bar.dart';
import 'package:onepos_admin_app/shared/widgets/custom_button.dart';
import 'package:onepos_admin_app/shared/widgets/custom_text_field.dart';
import 'package:onepos_admin_app/core/utils/validators.dart';
import 'package:onepos_admin_app/shared/widgets/custom_switch.dart';
import 'package:onepos_admin_app/core/utils/extensions.dart';

/// Screen for adding or editing a bill
class AddBillScreen extends HookConsumerWidget {
  final AutoBillModel? bill;
  const AddBillScreen({super.key, this.bill});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditing = bill != null;
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final nameController = useTextEditingController(text: bill?.name);
    final percentageController = useTextEditingController(
      text: bill?.percentage,
    );
    final descController = useTextEditingController(text: bill?.description);

    final optionsAsync = ref.watch(billOptionsProvider);
    final selectedOption = useState<BillOptionModel?>(null);
    final isActive = useState<bool>(bill?.isActive == 1);
    final isLoading = useState<bool>(false);

    // Initial value for dropdown
    useEffect(() {
      if (isEditing && optionsAsync.hasValue) {
        final options = optionsAsync.value!;
        final billOptionId = bill?.billOptionId;
        if (billOptionId != null) {
          selectedOption.value = options.firstWhere(
            (opt) => opt.id.toString() == billOptionId,
            orElse: () => options.first,
          );
        }
      }
      return null;
    }, [optionsAsync.hasValue]);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Add New Bill',
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
                  hint: 'Percentage/amount',
                  controller: percentageController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (val) => Validators.validatePositiveNumber(
                    val,
                    'Percentage/amount',
                  ),
                ),
                const SizedBox(height: AppTheme.spacingMedium),

                optionsAsync.when(
                  data: (options) => AppDropdown<BillOptionModel>(
                    hint: 'Bill type',
                    value: selectedOption.value,
                    items: options.map((opt) {
                      return DropdownMenuItem(
                        value: opt,
                        child: Text(opt.name),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) selectedOption.value = val;
                    },
                    validator: (val) =>
                        Validators.validateRequired(val, 'Bill type'),
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Text('Error loading options: $e'),
                ),
                const SizedBox(height: AppTheme.spacingMedium),

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
                        activeColor: const Color(0xFF4CAF50),
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
                  text: isEditing ? 'Update Bill' : 'Add Bill',
                  isLoading: isLoading.value,
                  onPressed: () async {
                    if (formKey.currentState!.validate() && !isLoading.value) {
                      isLoading.value = true;

                      final data = {
                        'bill_option_id': selectedOption.value?.id.toString(),
                        'name': nameController.text,
                        'short_description': descController.text,
                        'percentage': percentageController.text,
                        'is_active': isActive.value ? 1 : 0,
                      };

                      final response;
                      if (isEditing) {
                        response = await ref
                            .read(billsProvider.notifier)
                            .updateBillItem(
                              int.parse(bill!.id.toString()),
                              data,
                            );
                      } else {
                        response = await ref
                            .read(billsProvider.notifier)
                            .addBillItem(data);
                      }

                      isLoading.value = false;

                      if (response.success) {
                        context.showSnackBar(
                          isEditing
                              ? 'Bill updated successfully'
                              : 'Bill added successfully',
                        );
                        Navigator.pop(context);
                      } else {
                        context.showSnackBar(
                          response.message ?? 'An error occurred',
                          isError: true,
                        );
                      }
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
