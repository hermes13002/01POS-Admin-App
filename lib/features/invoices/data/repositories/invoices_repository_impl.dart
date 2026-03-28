import 'package:onepos_admin_app/core/errors/exceptions.dart';
import 'package:onepos_admin_app/data/models/api_response_model.dart';
import '../datasources/invoices_remote_datasource.dart';
import '../models/invoice_model.dart';
import '../../domain/repositories/invoices_repository.dart';

class InvoicesRepositoryImpl implements InvoicesRepository {
  final InvoicesRemoteDatasource _remoteDatasource;

  InvoicesRepositoryImpl({InvoicesRemoteDatasource? remoteDatasource})
    : _remoteDatasource = remoteDatasource ?? InvoicesRemoteDatasource();

  @override
  Future<ApiResponse<List<InvoiceModel>>> fetchInvoices() async {
    try {
      final response = await _remoteDatasource.fetchInvoices();

      return ApiResponse<List<InvoiceModel>>.fromJson(response.data, (data) {
        final list = data as List? ?? [];
        return list.map((e) => InvoiceModel.fromJson(e)).toList();
      });
    } on AppException catch (e) {
      return ApiResponse<List<InvoiceModel>>(
        success: false,
        message: e.message,
      );
    } catch (e) {
      return ApiResponse<List<InvoiceModel>>(
        success: false,
        message: e.toString(),
      );
    }
  }

  @override
  Future<ApiResponse<InvoiceModel>> createInvoice(InvoiceModel invoice) async {
    try {
      final response = await _remoteDatasource.createInvoice(invoice.toJson());

      return ApiResponse<InvoiceModel>.fromJson(response.data, (data) {
        if (data is Map<String, dynamic>) {
          return InvoiceModel.fromJson(data);
        }
        // handle empty data or list from api
        return const InvoiceModel(id: '', customerId: '', items: []);
      });
    } on AppException catch (e) {
      return ApiResponse<InvoiceModel>(success: false, message: e.message);
    } catch (e) {
      return ApiResponse<InvoiceModel>(success: false, message: e.toString());
    }
  }
}
