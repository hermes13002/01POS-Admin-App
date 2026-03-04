import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/sale_model.dart';

part 'sales_provider.g.dart';

/// sales provider with filtering support
@riverpod
class Sales extends _$Sales {
  @override
  Future<List<SaleModel>> build() async {
    // TODO: replace with actual api call
    return _getMockSales();
  }

  /// refresh sales list
  Future<void> refreshSales() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return _getMockSales();
    });
  }

  /// mock data for development
  List<SaleModel> _getMockSales() {
    return [
      SaleModel(
        id: '1',
        orderNumber: '#65432I',
        customerName: 'John Doe',
        cashierName: 'John Doe',
        cashierEmail: 'Johndoe123@gmail.com',
        cashierPhone: '07012345678',
        totalAmount: 70000,
        date: DateTime(2026, 1, 26),
        status: 'Completed',
        customerAddress: 'N/A',
        paymentMethod: 'Cash',
        discountApplied: 'N/A',
        loyaltyApplied: null,
        totalPrice: 833000,
        items: const [
          SaleItem(
            productName: 'Herbal sleep aid',
            quantity: 12,
            unitPrice: 5000,
          ),
        ],
      ),
      SaleModel(
        id: '2',
        orderNumber: '#65433I',
        customerName: 'John Doe',
        cashierName: 'John Doe',
        cashierEmail: 'Johndoe123@gmail.com',
        cashierPhone: '07012345678',
        totalAmount: 70000,
        date: DateTime(2026, 1, 25),
        status: 'Completed',
        items: const [
          SaleItem(
            productName: 'Cold brew coffee',
            quantity: 5,
            unitPrice: 3000,
          ),
        ],
      ),
      SaleModel(
        id: '3',
        orderNumber: '#65434I',
        customerName: 'John Doe',
        cashierName: 'Jane Smith',
        cashierEmail: 'janesmith@gmail.com',
        cashierPhone: '08098765432',
        totalAmount: 70000,
        date: DateTime(2026, 1, 24),
        status: 'Completed',
        items: const [
          SaleItem(
            productName: 'Ultrabook pro 15',
            quantity: 1,
            unitPrice: 70000,
          ),
        ],
      ),
      SaleModel(
        id: '4',
        orderNumber: '#65435I',
        customerName: 'John Doe',
        cashierName: 'John Doe',
        cashierEmail: 'Johndoe123@gmail.com',
        cashierPhone: '07012345678',
        totalAmount: 70000,
        date: DateTime(2026, 1, 23),
        status: 'Completed',
        items: const [
          SaleItem(
            productName: 'Organic whole milk',
            quantity: 10,
            unitPrice: 2500,
          ),
        ],
      ),
      SaleModel(
        id: '5',
        orderNumber: '#65436I',
        customerName: 'John Doe',
        cashierName: 'John Doe',
        cashierEmail: 'Johndoe123@gmail.com',
        cashierPhone: '07012345678',
        totalAmount: 70000,
        date: DateTime(2026, 1, 22),
        status: 'Completed',
        items: const [
          SaleItem(
            productName: 'Cross sectional sofa',
            quantity: 2,
            unitPrice: 35000,
          ),
        ],
      ),
    ];
  }
}
