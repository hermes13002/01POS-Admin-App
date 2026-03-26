import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:onepos_admin_app/core/routes/app_routes.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/core/utils/image_picker_util.dart';
import 'package:onepos_admin_app/features/products/presentation/providers/products_provider.dart';
import 'package:onepos_admin_app/features/store/presentation/providers/store_provider.dart';
import 'package:onepos_admin_app/shared/widgets/app_dropdown.dart';
import 'package:onepos_admin_app/shared/widgets/app_snackbar.dart';
import 'package:onepos_admin_app/shared/widgets/custom_app_bar2.dart';
import 'package:onepos_admin_app/shared/widgets/custom_button.dart';
import 'package:onepos_admin_app/shared/widgets/custom_text_field.dart';
import 'package:onepos_admin_app/core/utils/validators.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// screen for adding a new product (single scrollable form)
class AddProductScreen extends HookConsumerWidget {
  const AddProductScreen({super.key});

  void _showBarcodeScanner(
    BuildContext context,
    TextEditingController controller,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;
        final sheetHeight = screenHeight * 0.5;
        final scanWindowHeight = 160.0;
        final scanWindowWidth = screenWidth * 0.8;

        return Container(
          height: sheetHeight,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Focus on Barcode',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        MobileScanner(
                          fit: BoxFit.cover,
                          onDetect: (capture) {
                            final List<Barcode> barcodes = capture.barcodes;
                            if (barcodes.isNotEmpty) {
                              final String? code = barcodes.first.rawValue;
                              if (code != null) {
                                controller.text = code;
                                Navigator.pop(context);
                              }
                            }
                          },
                        ),
                        // semi-transparent overlay
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                          ),
                        ),
                        // scan window "cutout"
                        Container(
                          height: scanWindowHeight,
                          width: scanWindowWidth,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppTheme.primaryColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        // label inside cutout
                        Positioned(
                          top: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Scanning...',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: CustomButton(
                  text: 'Cancel',
                  onPressed: () => Navigator.pop(context),
                  isOutlined: true,
                  textColor: AppTheme.errorColor,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final categoriesAsync = ref.watch(storeCategoriesProvider);

    // step 1 controllers
    final nameController = useTextEditingController();
    final quantityController = useTextEditingController();
    final priceController = useTextEditingController();
    final selectedCategoryId = useState<int?>(null);
    final selectedSubCategoryId = useState<int?>(null);

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
      if (selectedCategoryId.value == null) return [];
      final categories = categoriesAsync.valueOrNull?.categories ?? [];
      final match = categories.where((c) => c.id == selectedCategoryId.value);
      if (match.isEmpty) return [];
      return match.first.subCategories;
    }, [selectedCategoryId.value, categoriesAsync]);

    // reset sub-category when category changes
    useEffect(() {
      selectedSubCategoryId.value = null;
      return null;
    }, [selectedCategoryId.value]);

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
                data: (state) => AppDropdown<int>(
                  label: 'Category *',
                  hint: 'Select category',
                  value: selectedCategoryId.value,
                  items: state.categories
                      .map(
                        (c) => DropdownMenuItem<int>(
                          value: c.id,
                          child: Text(c.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => selectedCategoryId.value = value,
                  validator: (val) {
                    if (val == null) return 'Category is required';
                    return null;
                  },
                ),
                loading: () => const LinearProgressIndicator(),
                error: (error, _) => Text('Failed to load categories: $error'),
              ),
              const SizedBox(height: AppTheme.spacingMedium),

              // sub-category dropdown
              AppDropdown<int>(
                label: 'Sub-category *',
                hint: 'Select sub-category',
                value: selectedSubCategoryId.value,
                enabled: subCategories.isNotEmpty,
                items: subCategories
                    .map(
                      (s) => DropdownMenuItem<int>(
                        value: s.id,
                        child: Text(s.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) => selectedSubCategoryId.value = value,
                validator: (val) {
                  if (val == null) return 'Sub-category is required';
                  return null;
                },
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
                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.qr_code_scanner,
                    color: AppTheme.blue,
                    size: 22,
                  ),
                  onPressed: () =>
                      _showBarcodeScanner(context, barcodeController),
                ),
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

                  // prepare API body
                  final body = <String, dynamic>{
                    'store': storeController.text.trim(),
                    'warehouse': warehouseController.text.trim(),
                    'supplier': supplierController.text.trim(),
                    'cat_id': selectedCategoryId.value,
                    'sub_cat_id': selectedSubCategoryId.value,
                    'product_name': nameController.text.trim(),
                    'sku': skuController.text.trim(),
                    'barcode': barcodeController.text.trim(),
                    'quantity': quantityController.text.trim(),
                    'price': priceController.text.trim(),
                    'manufacturing_date': manufacturingDate.value != null
                        ? DateFormat(
                            'yyyy-MM-dd HH:mm:ss',
                          ).format(manufacturingDate.value!)
                        : null,
                    'expiring_date': expiryDate.value != null
                        ? DateFormat(
                            'yyyy-MM-dd HH:mm:ss',
                          ).format(expiryDate.value!)
                        : null,
                    'product_image': productImage.value,
                    'description': descriptionController.text.trim(),
                  };

                  final response = await ref
                      .read(productsProvider.notifier)
                      .addProductItem(body);

                  isLoading.value = false;

                  if (context.mounted) {
                    if (response.success) {
                      AppSnackbar.showSuccess(
                        context,
                        'Product created successfully',
                      );
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.products,
                      );
                    } else {
                      AppSnackbar.showError(
                        context,
                        response.message ?? 'Failed to add product',
                      );
                    }
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
