import 'package:onepos_admin_app/features/bill/data/models/auto_bill_model.dart';

class BillState {
  final List<AutoBillModel> bills;
  final int currentPage;
  final bool hasMorePages;
  final bool isLoading;
  final String? error;

  BillState({
    this.bills = const [],
    this.currentPage = 1,
    this.hasMorePages = false,
    this.isLoading = false,
    this.error,
  });

  BillState copyWith({
    List<AutoBillModel>? bills,
    int? currentPage,
    bool? hasMorePages,
    bool? isLoading,
    String? error,
  }) {
    return BillState(
      bills: bills ?? this.bills,
      currentPage: currentPage ?? this.currentPage,
      hasMorePages: hasMorePages ?? this.hasMorePages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
