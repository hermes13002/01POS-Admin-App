import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/core/utils/amount_formatter.dart';
import 'package:onepos_admin_app/features/invoices/data/models/invoice_model.dart';
import 'package:onepos_admin_app/shared/widgets/custom_button.dart';

class InvoiceDetailDialog extends StatelessWidget {
  final InvoiceModel invoice;

  const InvoiceDetailDialog({super.key, required this.invoice});

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

              _buildSection('Customer', [
                _buildInfoRow('Customer name:', invoice.customerName ?? 'N/A'),
              ]),
              const SizedBox(height: AppTheme.spacingMedium),

              _buildInvoiceItems(),
              const SizedBox(height: AppTheme.spacingLarge),

              _buildSection('Payment Summary', [
                _buildInfoRow(
                  'Subtotal:',
                  AmountFormatter.formatCurrency(invoice.subtotal),
                  valueStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
                _buildInfoRow(
                  'Tax (${invoice.tax}%):',
                  AmountFormatter.formatCurrency(invoice.taxAmount),
                  valueStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
                _buildInfoRow(
                  'Discount (${invoice.discount}%):',
                  '-${AmountFormatter.formatCurrency(invoice.discountAmount)}',
                  valueStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.errorColor,
                  ),
                ),
                const Divider(),
                _buildInfoRow(
                  'Total Amount:',
                  AmountFormatter.formatCurrency(invoice.total),
                  valueStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ]),
              const SizedBox(height: AppTheme.spacingLarge),

              _buildSection('Delivery Info', [
                _buildInfoRow('Send Option:', invoice.sendOption.toUpperCase()),
                if (invoice.scheduledDate != null)
                  _buildInfoRow('Scheduled Date:', invoice.scheduledDate!),
                if (invoice.scheduledTime != null)
                  _buildInfoRow('Scheduled Time:', invoice.scheduledTime!),
                if (invoice.recurringFrequency != null)
                  _buildInfoRow('Recurring:', invoice.recurringFrequency!),
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
                'Invoice No: ${invoice.invoiceNumber ?? invoice.id}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Invoice Details',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                invoice.createdAt != null
                    ? DateFormat(
                        'MMM d, yyyy, h:mma',
                      ).format(invoice.createdAt!)
                    : 'n/a',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                ),
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

  Widget _buildInvoiceItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Invoice Items',
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
              ...invoice.items.map((item) => _buildItemRow(item)),
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
        color: AppTheme.primaryColor,
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

  Widget _buildItemRow(InvoiceItemModel item) {
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
              AmountFormatter.formatCurrency(item.price, showDecimals: false),
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
}
