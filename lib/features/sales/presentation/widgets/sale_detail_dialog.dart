import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/core/utils/amount_formatter.dart';
import 'package:onepos_admin_app/features/sales/data/models/sale_model.dart';
import 'package:onepos_admin_app/shared/widgets/custom_button.dart';

class SaleDetailDialog extends StatelessWidget {
  final SaleModel sale;

  const SaleDetailDialog({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: AppTheme.spacingLarge),
              _buildSection('Order', [
                _buildInfoRow(
                  'Total',
                  AmountFormatter.formatCurrency(
                    sale.totalPrice ?? sale.totalAmount,
                  ),
                  valueStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ]),
              const SizedBox(height: AppTheme.spacingMedium),
              _buildSection('Customer', [
                _buildInfoRow('Customer name:', sale.customerName),
                _buildInfoRow('Address:', sale.customerAddress ?? 'N/A'),
              ]),
              const SizedBox(height: AppTheme.spacingMedium),
              _buildSection('Cashier', [
                _buildInfoRow('Cashier name:', sale.cashierName),
                _buildInfoRow('Email:', sale.cashierEmail ?? 'N/A'),
                _buildInfoRow('Phone:', sale.cashierPhone ?? 'N/A'),
              ]),
              const SizedBox(height: AppTheme.spacingLarge),
              _buildOrderItems(),
              _buildSection('Payment Info', [
                _buildInfoRow('Payment type:', sale.paymentMethod ?? 'N/A'),
                _buildInfoRow('Discount:', sale.discountApplied ?? 'None'),
                _buildInfoRow(
                  'Loyalty applied:',
                  sale.loyaltyApplied != null
                      ? AmountFormatter.formatCurrency(sale.loyaltyApplied)
                      : 'N/A',
                  valueStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
                _buildInfoRow(
                  'Total price:',
                  AmountFormatter.formatCurrency(
                    sale.totalPrice ?? sale.totalAmount,
                  ),
                  valueStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ]),
              const SizedBox(height: AppTheme.spacingLarge),
              CustomButton(
                text: 'Close',
                onPressed: () => Navigator.pop(context),
                backgroundColor: AppTheme.primaryColor,
                height: 50,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order No: ${sale.orderNumber}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.successColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Sales Details',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _buildStatusBadge(sale.status),
                  const SizedBox(width: AppTheme.spacingSmall),
                  Text(
                    DateFormat('MMM d, yyyy, h:mma').format(sale.date),
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.close, color: AppTheme.textPrimary, size: 22),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
      ),
      child: Text(
        status,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppTheme.successColor;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return AppTheme.errorColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSmall),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(width: AppTheme.spacingSmall),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style:
                  valueStyle ??
                  GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order Items',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSmall),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.grey200),
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
          ),
          child: Column(
            children: [
              _buildItemsHeader(),
              ...sale.items.map((item) => _buildItemRow(item)),
              _buildItemsFooter(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemsHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF4DA6C9),
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: _headerText('Product')),
          Expanded(
            flex: 2,
            child: _headerText('Qty', textAlign: TextAlign.center),
          ),
          Expanded(
            flex: 2,
            child: _headerText('Price', textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }

  Widget _headerText(String text, {TextAlign? textAlign}) {
    return Text(
      text,
      textAlign: textAlign,
      style: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }

  Widget _buildItemRow(SaleItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.grey200)),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: _itemText(item.productName)),
          Expanded(
            flex: 2,
            child: _itemText('${item.quantity}', textAlign: TextAlign.center),
          ),
          Expanded(
            flex: 2,
            child: _itemText(
              AmountFormatter.formatCurrency(
                item.unitPrice,
                showDecimals: false,
              ),
              textAlign: TextAlign.right,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemText(String text, {TextAlign? textAlign, TextStyle? style}) {
    return Text(
      text,
      textAlign: textAlign,
      style:
          style ??
          GoogleFonts.poppins(fontSize: 12, color: AppTheme.textPrimary),
    );
  }

  Widget _buildItemsFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Total: ${AmountFormatter.formatCurrency(sale.totalPrice ?? sale.totalAmount, showDecimals: false)}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
