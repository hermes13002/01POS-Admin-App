import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/core/utils/image_picker_util.dart';
import 'package:onepos_admin_app/features/products/data/models/product_model.dart';
import 'package:onepos_admin_app/features/products/presentation/providers/products_provider.dart';
import 'package:onepos_admin_app/shared/widgets/app_dropdown.dart';
import 'package:onepos_admin_app/shared/widgets/custom_app_bar2.dart';
import 'package:onepos_admin_app/shared/widgets/custom_button.dart';
import 'package:onepos_admin_app/shared/widgets/custom_text_field.dart';
import 'package:onepos_admin_app/core/utils/validators.dart';

/// screen for adding a new product (single scrollable form)
class AddProductScreen extends HookConsumerWidget {
  const AddProductScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final categoriesAsync = ref.watch(productCategoriesProvider);

    // step 1 controllers
    final nameController = useTextEditingController();
    final quantityController = useTextEditingController();
    final priceController = useTextEditingController();
    final selectedCategory = useState<String?>(null);
    final selectedSubCategory = useState<String?>(null);

    // step 2 controllers
    final storeController = useTextEditingController();
    final warehouseController = useTextEditingController();
    final supplierController = useTextEditingController();
    final skuController = useTextEditingController();
    final barcodeController = useTextEditingController();
    final descriptionController = useTextEditingController();
    final manufacturingDate = useState<DateTime?>(null);
    final expiryDate = useState<DateTime?>(null);

    // image placeholder
    final productImage = useState<String?>(null);

    // loading state
    final isLoading = useState(false);

    // available sub-categories based on selected category
    final subCategories = useMemoized(() {
      if (selectedCategory.value == null) return <String>[];
      final categories = categoriesAsync.valueOrNull ?? [];
      final match = categories.where((c) => c.name == selectedCategory.value);
      if (match.isEmpty) return <String>[];
      return match.first.subCategories;
    }, [selectedCategory.value, categoriesAsync]);

    // reset sub-category when category changes
    useEffect(() {
      selectedSubCategory.value = null;
      return null;
    }, [selectedCategory.value]);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: const CustomAppBar2(
        title: 'Add New Product',
        backgroundColor: AppTheme.backgroundColor,
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMedium,
            vertical: AppTheme.spacingSmall,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppTheme.spacingSmall),

              // -- product details section --
              _SectionLabel(label: 'Product Details'),
              const SizedBox(height: AppTheme.spacingSmall),

              // product name
              CustomTextField(
                label: 'Product name *',
                hint: 'Enter product name',
                controller: nameController,
                validator: (val) =>
                    Validators.validateRequired(val, 'Product name'),
              ),
              const SizedBox(height: AppTheme.spacingMedium),

              // category dropdown
              categoriesAsync.when(
                data: (categories) => AppDropdown<String>(
                  label: 'Category *',
                  hint: 'Select category',
                  value: selectedCategory.value,
                  items: categories
                      .map(
                        (c) => DropdownMenuItem(
                          value: c.name,
                          child: Text(c.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => selectedCategory.value = value,
                  validator: (val) =>
                      Validators.validateRequired(val, 'Category'),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('Failed to load categories'),
              ),
              const SizedBox(height: AppTheme.spacingMedium),

              // sub-category dropdown
              AppDropdown<String>(
                label: 'Sub-category *',
                hint: 'Select sub-category',
                value: selectedSubCategory.value,
                enabled: subCategories.isNotEmpty,
                items: subCategories
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (value) => selectedSubCategory.value = value,
              ),
              const SizedBox(height: AppTheme.spacingMedium),

              // quantity
              CustomTextField(
                label: 'Quantity *',
                hint: 'Enter quantity',
                controller: quantityController,
                keyboardType: TextInputType.number,
                validator: (val) => Validators.validateNumber(val, 'Quantity'),
              ),
              const SizedBox(height: AppTheme.spacingMedium),

              // price
              CustomTextField(
                label: 'Price *',
                hint: 'Enter price',
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (val) =>
                    Validators.validatePositiveNumber(val, 'Price'),
              ),
              const SizedBox(height: AppTheme.spacingLarge),

              // -- other details section --
              _SectionLabel(label: 'Other Details'),
              const SizedBox(height: AppTheme.spacingSmall),

              // upload product image
              Text(
                'Upload product image',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: AppTheme.spacingSmall),
              ImageUploadBox(
                imagePath: productImage.value,
                onTap: () async {
                  final path = await AppImagePicker.showPickerBottomSheet(
                    context,
                  );
                  if (path != null) {
                    productImage.value = path;
                  }
                },
              ),
              const SizedBox(height: AppTheme.spacingMedium),

              // store
              CustomTextField(
                label: 'Store',
                hint: 'Enter store name',
                controller: storeController,
              ),
              const SizedBox(height: AppTheme.spacingMedium),

              // warehouse
              CustomTextField(
                label: 'Warehouse',
                hint: 'Enter warehouse',
                controller: warehouseController,
              ),
              const SizedBox(height: AppTheme.spacingMedium),

              // supplier
              CustomTextField(
                label: 'Supplier',
                hint: 'Enter supplier',
                controller: supplierController,
              ),
              const SizedBox(height: AppTheme.spacingMedium),

              // sku
              CustomTextField(
                label: 'SKU',
                hint: 'Enter SKU',
                controller: skuController,
              ),
              const SizedBox(height: AppTheme.spacingMedium),

              // barcode
              CustomTextField(
                label: 'Barcode',
                hint: 'Enter barcode',
                controller: barcodeController,
              ),
              const SizedBox(height: AppTheme.spacingMedium),

              // manufacturing date
              _DatePickerField(
                label: 'Manufacturing date',
                value: manufacturingDate.value,
                onDateSelected: (date) => manufacturingDate.value = date,
              ),
              const SizedBox(height: AppTheme.spacingMedium),

              // expiry date
              _DatePickerField(
                label: 'Expiry date',
                value: expiryDate.value,
                onDateSelected: (date) => expiryDate.value = date,
              ),
              const SizedBox(height: AppTheme.spacingMedium),

              // product description
              CustomTextField(
                label: 'Product description',
                hint: 'Enter product description',
                controller: descriptionController,
                maxLines: 4,
              ),
              const SizedBox(height: AppTheme.spacingLarge),

              // save button
              CustomButton(
                text: 'Save Product',
                isLoading: isLoading.value,
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;

                  isLoading.value = true;

                  final product = ProductModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text.trim(),
                    price: double.parse(priceController.text.trim()),
                    category: selectedCategory.value ?? '',
                    subCategory: selectedSubCategory.value,
                    stock: int.parse(quantityController.text.trim()),
                    imageUrl: productImage.value,
                    store: storeController.text.trim().isNotEmpty
                        ? storeController.text.trim()
                        : null,
                    warehouse: warehouseController.text.trim().isNotEmpty
                        ? warehouseController.text.trim()
                        : null,
                    supplier: supplierController.text.trim().isNotEmpty
                        ? supplierController.text.trim()
                        : null,
                    sku: skuController.text.trim().isNotEmpty
                        ? skuController.text.trim()
                        : null,
                    barcode: barcodeController.text.trim().isNotEmpty
                        ? barcodeController.text.trim()
                        : null,
                    manufacturingDate: manufacturingDate.value,
                    expiryDate: expiryDate.value,
                    description: descriptionController.text.trim().isNotEmpty
                        ? descriptionController.text.trim()
                        : null,
                  );

                  await ref.read(productsProvider.notifier).addProduct(product);

                  isLoading.value = false;

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
              ),
              const SizedBox(height: AppTheme.spacingXLarge),
            ],
          ),
        ),
      ),
    );
  }
}

/// section label
class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimary,
      ),
    );
  }
}

/// date picker field with calendar icon
class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onDateSelected;

  const _DatePickerField({
    required this.label,
    required this.value,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final displayText = value != null
        ? DateFormat('dd/MM/yyyy').format(value!)
        : '';

    return CustomTextField(
      label: label,
      hint: 'Select date',
      readOnly: true,
      controller: TextEditingController(text: displayText),
      suffixIcon: const Icon(
        Icons.access_time_outlined,
        color: AppTheme.textSecondary,
        size: 20,
      ),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Colors.black,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Colors.black,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          onDateSelected(picked);
        }
      },
    );
  }
}
