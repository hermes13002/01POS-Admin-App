import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onepos_admin_app/data/models/api_response_model.dart';
import '../../domain/repositories/invoices_repository.dart';
import '../../data/repositories/invoices_repository_impl.dart';
import '../../data/models/invoice_model.dart';

final invoicesRepositoryProvider = Provider<InvoicesRepository>((ref) {
  return InvoicesRepositoryImpl();
});

final invoicesListProvider = FutureProvider<ApiResponse<List<InvoiceModel>>>((
  ref,
) {
  return ref.watch(invoicesRepositoryProvider).fetchInvoices();
});

class InvoiceNotifier extends Notifier<InvoiceModel> {
  @override
  InvoiceModel build() {
    return const InvoiceModel(id: '', customerId: '', items: []);
  }

  void setCustomer(String customerId) {
    state = state.copyWith(customerId: customerId);
  }

  void addItem(InvoiceItemModel item) {
    final existingIndex = state.items.indexWhere(
      (i) => i.productId == item.productId,
    );

    List<InvoiceItemModel> newItems;
    if (existingIndex >= 0) {
      newItems = List.from(state.items);
      newItems[existingIndex] = newItems[existingIndex].copyWith(
        quantity: newItems[existingIndex].quantity + 1,
      );
    } else {
      newItems = [...state.items, item];
    }

    _updateTotals(newItems);
  }

  void removeItem(String productId) {
    final newItems = state.items
        .where((i) => i.productId != productId)
        .toList();
    _updateTotals(newItems);
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }

    final newItems = state.items.map((i) {
      if (i.productId == productId) {
        return i.copyWith(quantity: quantity);
      }
      return i;
    }).toList();

    _updateTotals(newItems);
  }

  void setDiscount(double discount) {
    state = state.copyWith(discount: discount);
    _calculateFinalTotal();
  }

  void setTax(double tax) {
    state = state.copyWith(tax: tax);
    _calculateFinalTotal();
  }

  void setSendOption(String option) {
    state = state.copyWith(sendOption: option);
  }

  void reset() {
    state = build();
  }

  void _updateTotals(List<InvoiceItemModel> items) {
    double subtotal = 0;
    for (final item in items) {
      subtotal += item.price * item.quantity;
    }

    state = state.copyWith(items: items, subtotal: subtotal);
    _calculateFinalTotal();
  }

  void _calculateFinalTotal() {
    // total = subtotal - discount + tax
    final dAmount = (state.subtotal * state.discount) / 100;
    final tAmount = (state.subtotal * state.tax) / 100;
    final total = state.subtotal - dAmount + tAmount;

    state = state.copyWith(
      discountAmount: dAmount,
      taxAmount: tAmount,
      total: total > 0 ? total : 0,
    );
  }

  Future<ApiResponse<InvoiceModel>> createInvoice() async {
    final repo = ref.read(invoicesRepositoryProvider);
    final response = await repo.createInvoice(state);

    if (response.success) {
      ref.invalidate(invoicesListProvider);
      reset();
    }
    return response;
  }
}

final invoiceProvider = NotifierProvider<InvoiceNotifier, InvoiceModel>(() {
  return InvoiceNotifier();
});
