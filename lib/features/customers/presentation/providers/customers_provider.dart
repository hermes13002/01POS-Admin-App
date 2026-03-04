import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/customer_model.dart';

part 'customers_provider.g.dart';

/// customers provider
@riverpod
class Customers extends _$Customers {
  @override
  Future<List<CustomerModel>> build() async {
    // TODO: replace with actual api call
    return _getMockCustomers();
  }

  /// add a new customer
  Future<void> addCustomer(CustomerModel customer) async {
    final current = state.valueOrNull ?? [];
    state = AsyncData([...current, customer]);
  }

  /// update an existing customer
  Future<void> updateCustomer(CustomerModel customer) async {
    final current = state.valueOrNull ?? [];
    state = AsyncData(
      current.map((c) => c.id == customer.id ? customer : c).toList(),
    );
  }

  /// delete a customer by id
  Future<void> deleteCustomer(String customerId) async {
    final current = state.valueOrNull ?? [];
    state = AsyncData(current.where((c) => c.id != customerId).toList());
  }

  /// refresh customers list
  Future<void> refreshCustomers() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return _getMockCustomers();
    });
  }

  /// mock data for development
  List<CustomerModel> _getMockCustomers() {
    return const [
      CustomerModel(
        id: '1',
        name: 'John Doe',
        email: 'Johndoe123@gmail.com',
      ),
      CustomerModel(
        id: '2',
        name: 'John Doe',
        email: 'Johndoe123@gmail.com',
      ),
      CustomerModel(
        id: '3',
        name: 'John Doe',
        email: 'Johndoe123@gmail.com',
      ),
      CustomerModel(
        id: '4',
        name: 'John Doe',
        email: 'Johndoe123@gmail.com',
      ),
      CustomerModel(
        id: '5',
        name: 'John Doe',
        email: 'Johndoe123@gmail.com',
      ),
      CustomerModel(
        id: '6',
        name: 'John Doe',
        email: 'Johndoe123@gmail.com',
      ),
    ];
  }
}
