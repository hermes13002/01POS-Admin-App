import 'dart:io';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:onepos_admin_app/features/sales/data/models/sale_model.dart';

/// service to handle sales data export to Excel and PDF
class SalesExportService {
  static final _dateFormatter = DateFormat('yyyy-MM-dd HH:mm');
  static final _currencyFormatter = NumberFormat.currency(symbol: '₦');

  /// export sales to Excel (.xlsx)
  static Future<void> exportToExcel(List<SaleModel> sales) async {
    final excel = Excel.createExcel();
    final Sheet sheet = excel['Sales Report'];

    // header row
    sheet.appendRow([
      TextCellValue('Date'),
      TextCellValue('Order #'),
      TextCellValue('Customer'),
      TextCellValue('Cashier'),
      TextCellValue('Payment'),
      TextCellValue('Items'),
      TextCellValue('Total (₦)'),
      TextCellValue('Status'),
    ]);

    // data rows
    for (final sale in sales) {
      final itemsSummary = sale.items
          .map((item) => '${item.productName} (x${item.quantity})')
          .join(', ');

      sheet.appendRow([
        TextCellValue(_dateFormatter.format(sale.date)),
        TextCellValue(sale.orderNumber),
        TextCellValue(sale.customerName),
        TextCellValue(sale.cashierName),
        TextCellValue(sale.paymentMethod ?? 'N/A'),
        TextCellValue(itemsSummary),
        DoubleCellValue(sale.totalAmount),
        TextCellValue(sale.status),
      ]);
    }

    // save and share
    final bytes = excel.save();
    if (bytes != null) {
      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/sales_report_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      await SharePlus.instance.share(
        ShareParams(files: [XFile(filePath)], subject: 'Sales Report Excel'),
      );
    }
  }

  /// export sales to PDF
  static Future<void> exportToPdf(List<SaleModel> sales) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.poppinsRegular();
    final boldFont = await PdfGoogleFonts.poppinsBold();
    final amountFont = await PdfGoogleFonts.robotoRegular();
    final amountBoldFont = await PdfGoogleFonts.robotoBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Sales Report',
                    style: pw.TextStyle(font: boldFont, fontSize: 24),
                  ),
                  pw.Text(
                    _dateFormatter.format(DateTime.now()),
                    style: pw.TextStyle(font: font, fontSize: 12),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              children: [
                // Header row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.black),
                  children: ['Date', 'Order #', 'Customer', 'Items', 'Total']
                      .map(
                        (h) => pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            h,
                            style: pw.TextStyle(
                              font: boldFont,
                              color: PdfColors.white,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                // Data rows
                ...sales.map((sale) {
                  final itemsSummary = sale.items
                      .map((item) => '${item.productName} (x${item.quantity})')
                      .join('\n');
                  return pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          _dateFormatter.format(sale.date),
                          style: pw.TextStyle(font: font),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          sale.orderNumber,
                          style: pw.TextStyle(font: font),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          sale.customerName,
                          style: pw.TextStyle(font: font),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          itemsSummary,
                          style: pw.TextStyle(font: font),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          _currencyFormatter.format(sale.totalAmount),
                          style: pw.TextStyle(font: amountFont),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text(
                  'Grand Total: ${_currencyFormatter.format(sales.fold(0.0, (sum, item) => sum + item.totalAmount))}',
                  style: pw.TextStyle(font: amountBoldFont, fontSize: 16),
                ),
              ],
            ),
          ];
        },
      ),
    );

    // save and share
    final directory = await getTemporaryDirectory();
    final filePath =
        '${directory.path}/sales_report_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    await SharePlus.instance.share(
      ShareParams(files: [XFile(filePath)], subject: 'Sales Report PDF'),
    );
  }
}
