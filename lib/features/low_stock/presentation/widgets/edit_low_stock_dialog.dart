import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/features/products/data/models/product_model.dart';
import 'package:onepos_admin_app/features/low_stock/presentation/providers/low_stock_provider.dart';
import 'package:onepos_admin_app/shared/widgets/app_snackbar.dart';
import 'package:onepos_admin_app/shared/widgets/custom_text_field.dart';

/// a streamlined dialog for updating only the product quantity
class EditLowStockDialog extends HookConsumerWidget {
  final ProductModel product;

  const EditLowStockDialog({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qtyController = useTextEditingController(
      text: product.stock.toString(),
    );
    final isSubmitting = useState(false);

    // fade animation
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );
    useEffect(() {
      animationController.forward();
      return null;
    }, const []);

    Future<void> handleSave() async {
      final newQty = int.tryParse(qtyController.text.trim());
      if (newQty == null) {
        AppSnackbar.showError(context, 'Please enter a valid quantity');
        return;
      }

      isSubmitting.value = true;
      try {
        await ref
            .read(lowStockProductsProvider.notifier)
            .updateProductQuantity(product, newQty);

        if (context.mounted) {
          AppSnackbar.showSuccess(context, 'Quantity updated successfully');
          Navigator.pop(context);
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
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(AppTheme.spacingLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Edit Stock',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingMedium),

              // product info
              Text(
                product.name,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: AppTheme.spacingLarge),

              // quantity field
              CustomTextField(
                label: 'Available Quantity',
                controller: qtyController,
                keyboardType: TextInputType.number,
                hint: 'e.g. 100',
              ),
              const SizedBox(height: AppTheme.spacingLarge),

              // actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: isSubmitting.value
                        ? null
                        : () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(color: AppTheme.textSecondary),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMedium),
                  ElevatedButton(
                    onPressed: isSubmitting.value ? null : handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
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
                            'Update',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
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
}
