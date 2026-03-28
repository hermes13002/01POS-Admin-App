import 'package:onepos_admin_app/data/models/api_response_model.dart';
import '../../data/models/invoice_model.dart';

abstract class InvoicesRepository {
  Future<ApiResponse<List<InvoiceModel>>> fetchInvoices();
  Future<ApiResponse<InvoiceModel>> createInvoice(InvoiceModel invoice);
}
