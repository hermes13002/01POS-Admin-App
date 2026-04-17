import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/features/products/data/models/product_model.dart';
import 'package:onepos_admin_app/features/products/presentation/providers/products_provider.dart';
import 'package:onepos_admin_app/shared/widgets/app_snackbar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:io';

class EditProductDialog extends HookConsumerWidget {
  final ProductModel product;

  const EditProductDialog({super.key, required this.product});

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
                            color: Colors.black.withValues(alpha: 0.4),
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
                  horizontal: 20,
                  vertical: 8,
                ),
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.poppins(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
    // initialize controllers immediately with the current product values
    final storeController = useTextEditingController(text: product.store ?? '');
    final warehouseController = useTextEditingController(
      text: product.warehouse ?? '',
    );
    final supplierController = useTextEditingController(
      text: product.supplier ?? '',
    );
    final nameController = useTextEditingController(text: product.name);
    final skuController = useTextEditingController(text: product.sku ?? '');
    final barcodeController = useTextEditingController(
      text: product.barcode ?? '',
    );
    final qtyController = useTextEditingController(
      text: product.stock.toString().replaceAll(RegExp(r'\.0$'), ''),
    );
    final priceController = useTextEditingController(
      text: product.price.toString(),
    );
    final mfgDateController = useTextEditingController(
      text: product.manufacturingDate ?? '',
    );
    final expDateController = useTextEditingController(
      text: product.expiryDate ?? '',
    );
    final descController = useTextEditingController(
      text: product.description ?? '',
    );
    final pickedImage = useState<XFile?>(null);
    final picker = ImagePicker();

    Future<void> pickImage() async {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        pickedImage.value = image;
      }
    }

    // Fade animation setup
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );
    useEffect(() {
      animationController.forward();
      return null;
    }, const []);

    final isSubmitting = useState(false);

    Future<void> saveChanges() async {
      isSubmitting.value = true;

      // prepare body based strictly on textfield content
      final data = {
        "store": storeController.text.trim(),
        "warehouse": warehouseController.text.trim(),
        "supplier": supplierController.text.trim(),
        "cat_id": product.catId, // keeping existing cat_id
        "sub_cat_id": product.subCatId, // keeping existing sub_cat_id
        "product_name": nameController.text.trim(),
        "sku": skuController.text.trim(),
        "barcode": barcodeController.text.trim(),
        "available_quantity":
            double.tryParse(qtyController.text.trim()) ??
            0.0, // Using proper api field
        "quantity":
            double.tryParse(qtyController.text.trim()) ??
            0.0, // Mandatory for backend
        "price": priceController.text.trim(),
        "manufacturing_date": mfgDateController.text.trim(),
        "expiring_date": expDateController.text.trim(),
        "description": descController.text.trim().isEmpty
            ? null
            : descController.text.trim(),
        "product_image":
            pickedImage.value?.path ??
            product.imageUrl ??
            "", // Mandatory for backend
      };

      try {
        final response = await ref
            .read(productsProvider.notifier)
            .updateProductItem(product.id, data);

        if (context.mounted) {
          if (response.success) {
            AppSnackbar.showSuccess(
              context,
              response.message ?? 'Product updated successfully',
            );
            await animationController.reverse(); // Fade out before closing
            if (context.mounted) Navigator.pop(context);
          } else {
            AppSnackbar.showError(context, response.message ?? 'Update failed');
          }
        }
      } catch (e) {
        if (context.mounted) {
          AppSnackbar.showError(context, e.toString());
        }
      } finally {
        if (context.mounted) {
          isSubmitting.value = false;
        }
      }
    }

    return FadeTransition(
      opacity: animationController,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppTheme.spacingMedium),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Edit Product Details',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Update fields below. Untouched fields keep original values.',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: AppTheme.textSecondary,
                    ),
                    onPressed: () async {
                      await animationController.reverse();
                      if (context.mounted) Navigator.pop(context);
                    },
                    padding: EdgeInsets.zero,
                    splashRadius: 24,
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingMedium),
              const Divider(height: 1, color: AppTheme.grey200),
              const SizedBox(height: AppTheme.spacingMedium),

              // Image Picker
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.grey100,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.grey300, width: 2),
                        image: pickedImage.value != null
                            ? DecorationImage(
                                image: FileImage(File(pickedImage.value!.path)),
                                fit: BoxFit.cover,
                              )
                            : (product.imageUrl != null
                                  ? DecorationImage(
                                      image: _getImageProvider(
                                        product.imageUrl!,
                                      ),
                                      fit: BoxFit.cover,
                                    )
                                  : null),
                      ),
                      child:
                          (pickedImage.value == null &&
                              product.imageUrl == null)
                          ? const Icon(
                              Icons.image_outlined,
                              size: 32,
                              color: AppTheme.grey400,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacingMedium),

              // form content — single column
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // basic info
                      _buildSectionTitle('Basic Information'),
                      _buildField('Product Name', nameController),
                      const SizedBox(height: 12),
                      _amountBuildField(
                        'Price',
                        priceController,
                        keyboardType: TextInputType.number,
                        prefixText: '₦ ',
                      ),

                      const SizedBox(height: 16),
                      // description
                      _buildSectionTitle('Description'),
                      _buildField(
                        'Description',
                        descController,
                        minLines: 3,
                        maxLines: null,
                        hintText: 'Enter product description...',
                      ),

                      const SizedBox(height: 16),
                      // inventory
                      _buildSectionTitle('Inventory Details'),
                      _buildField(
                        'Available Quantity',
                        qtyController,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      _buildField('SKU', skuController),
                      const SizedBox(height: 12),
                      _buildField(
                        'Barcode',
                        barcodeController,
                        suffixIcon: IconButton(
                          icon: const Icon(
                            Icons.qr_code_scanner,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                          onPressed: () =>
                              _showBarcodeScanner(context, barcodeController),
                        ),
                      ),

                      const SizedBox(height: 16),
                      // vendor & dates
                      _buildSectionTitle('Vendor & Dates'),
                      _buildField('Store', storeController),
                      const SizedBox(height: 12),
                      _buildField('Warehouse', warehouseController),
                      const SizedBox(height: 12),
                      _buildField('Supplier', supplierController),
                      const SizedBox(height: 12),
                      _buildField(
                        'Manufacturing Date',
                        mfgDateController,
                        hintText: 'YYYY-MM-DD',
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        'Expiring Date',
                        expDateController,
                        hintText: 'YYYY-MM-DD',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppTheme.spacingSmall),
              const Divider(height: 1, color: AppTheme.grey200),
              const SizedBox(height: AppTheme.spacingSmall),

              // action buttons — full width row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isSubmitting.value
                          ? null
                          : () async {
                              await animationController.reverse();
                              if (context.mounted) Navigator.pop(context);
                            },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppTheme.grey300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isSubmitting.value ? null : saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isSubmitting.value
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Save Changes',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  // _buildFieldRow removed — fields are now single-column

  Widget _buildField(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
    int? maxLines = 1,
    int? minLines,
    String? hintText,
    String? prefixText,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          minLines: minLines,
          style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.poppins(
              fontSize: 14,
              color: AppTheme.grey400,
            ),
            prefixText: prefixText,
            prefixStyle: GoogleFonts.poppins(
              fontSize: 14,
              color: AppTheme.textPrimary,
            ),
            suffixIcon: suffixIcon,
            isDense: true,
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.grey200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.grey200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.primaryColor),
            ),
          ),
        ),
      ],
    );
  }

  ImageProvider _getImageProvider(String url) {
    if (url.startsWith('file://') ||
        url.startsWith('/data/') ||
        url.startsWith('/tmp/')) {
      final path = url.startsWith('file://')
          ? Uri.parse(url).toFilePath()
          : url;
      return FileImage(File(path));
    }
    return NetworkImage(url);
  }
}

Widget _amountBuildField(
  String label,
  TextEditingController controller, {
  TextInputType? keyboardType,
  int? maxLines = 1,
  int? minLines,
  // int flex = 1,
  String? hintText,
  String? prefixText,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppTheme.textPrimary,
        ),
      ),
      const SizedBox(height: 6),
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        minLines: minLines,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          color: AppTheme.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: AppTheme.grey400,
          ),
          prefixText: prefixText,
          prefixStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: AppTheme.textPrimary,
          ),
          isDense: true,
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppTheme.grey200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppTheme.grey200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppTheme.primaryColor),
          ),
        ),
      ),
    ],
  );
}
