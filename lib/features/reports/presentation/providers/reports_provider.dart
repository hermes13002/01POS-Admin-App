import 'package:onepos_admin_app/core/network/dio_client.dart';
import 'package:onepos_admin_app/features/products/domain/repositories/product_repository.dart';
import 'package:onepos_admin_app/features/products/presentation/providers/products_provider.dart';
import 'package:onepos_admin_app/features/sales/data/datasources/sales_remote_datasource.dart';
import 'package:onepos_admin_app/features/sales/data/repositories/sales_repository_impl.dart';
import 'package:onepos_admin_app/features/sales/domain/repositories/sales_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/reports_model.dart';

part 'reports_provider.g.dart';

/// Reports data provider
@riverpod
class Reports extends _$Reports {
  SalesRepository get _salesRepo =>
      SalesRepositoryImpl(SalesRemoteDatasourceImpl(DioClient()));

  ProductRepository get _productRepo => ref.read(productRepositoryProvider);

  @override
  ReportsData build() {
    // start fetching in background
    Future.microtask(() {
      _fetchTopSales();
      _fetchSalesSummary();
      _fetchLowStock();
      _fetchSalesOverview();
      _fetchStockLevel();
      _fetchExpenses();
    });
    return _getMockData().copyWith(
      isTopSalesLoading: true,
      isSalesSummaryLoading: true,
      isLowStockLoading: true,
      isSalesOverviewLoading: true,
      isStockLevelLoading: true,
      isExpensesLoading: true,
    );
  }

  /// Fetch top sales in background
  Future<void> _fetchTopSales() async {
    try {
      final result = await _salesRepo.getAllSalesDashboard();
      final currentData = state.value ?? _getMockData();

      final updatedData = result.fold(
        (failure) => currentData.copyWith(
          topSalesError: failure.message,
          isTopSalesLoading: false,
        ),
        (sales) => currentData.copyWith(
          topSales: sales,
          clearTopSalesError: true,
          isTopSalesLoading: false,
        ),
      );

      state = AsyncData(updatedData);
    } catch (e) {
      final currentData = state.value ?? _getMockData();
      state = AsyncData(
        currentData.copyWith(
          topSalesError: e.toString(),
          isTopSalesLoading: false,
        ),
      );
    }
  }

  /// Update sales summary filter
  Future<void> updateSalesSummaryFilter(String filter) async {
    final currentData = state.value ?? _getMockData();
    state = AsyncData(
      currentData.copyWith(
        salesSummaryFilter: filter,
        isSalesSummaryLoading: true,
      ),
    );
    await _fetchSalesSummary();
  }

  /// Fetch sales summary in background
  Future<void> _fetchSalesSummary() async {
    try {
      final currentDataTemp = state.value ?? _getMockData();
      final filter = currentDataTemp.salesSummaryFilter;
      final result = await _salesRepo.getSalesSummaryDashboard(
        dateFilter: filter,
      );
      final currentData = state.value ?? _getMockData();

      final updatedData = result.fold(
        (failure) => currentData.copyWith(
          salesSummaryError: failure.message,
          isSalesSummaryLoading: false,
        ),
        (summary) => currentData.copyWith(
          salesSummary: summary,
          clearSalesSummaryError: true,
          isSalesSummaryLoading: false,
        ),
      );

      state = AsyncData(updatedData);
    } catch (e) {
      final currentData = state.value ?? _getMockData();
      state = AsyncData(
        currentData.copyWith(
          salesSummaryError: e.toString(),
          isSalesSummaryLoading: false,
        ),
      );
    }
  }

  /// Fetch low stock products in background
  Future<void> _fetchLowStock() async {
    try {
      final result = await _productRepo.fetchLowStockProducts();
      final currentData = state.value ?? _getMockData();

      if (result.success && result.data != null) {
        state = AsyncData(
          currentData.copyWith(
            lowStockItems: result.data!,
            clearLowStockError: true,
            isLowStockLoading: false,
          ),
        );
      } else {
        state = AsyncData(
          currentData.copyWith(
            lowStockError: result.message ?? 'Failed to fetch low stock',
            isLowStockLoading: false,
          ),
        );
      }
    } catch (e) {
      final currentData = state.value ?? _getMockData();
      state = AsyncData(
        currentData.copyWith(
          lowStockError: e.toString(),
          isLowStockLoading: false,
        ),
      );
    }
  }

  /// Fetch sales overview in background
  Future<void> _fetchSalesOverview() async {
    try {
      final result = await _salesRepo.getSalesOverviewDashboard();
      final currentData = state.value ?? _getMockData();

      final updatedData = result.fold(
        (failure) => currentData.copyWith(
          salesOverviewError: failure.message,
          isSalesOverviewLoading: false,
        ),
        (overview) => currentData.copyWith(
          salesOverview: overview,
          clearSalesOverviewError: true,
          isSalesOverviewLoading: false,
        ),
      );

      state = AsyncData(updatedData);
    } catch (e) {
      final currentData = state.value ?? _getMockData();
      state = AsyncData(
        currentData.copyWith(
          salesOverviewError: e.toString(),
          isSalesOverviewLoading: false,
        ),
      );
    }
  }

  /// Refresh reports data
  Future<void> refreshReports() async {
    final currentData = state.value ?? _getMockData();
    state = AsyncData(
      currentData.copyWith(
        isTopSalesLoading: true,
        isSalesSummaryLoading: true,
        isLowStockLoading: true,
        isSalesOverviewLoading: true,
        isStockLevelLoading: true,
        isExpensesLoading: true,
      ),
    );
    await Future.wait([
      _fetchTopSales(),
      _fetchSalesSummary(),
      _fetchLowStock(),
      _fetchSalesOverview(),
      _fetchStockLevel(),
      _fetchExpenses(),
    ]);
  }

  Future<void> _fetchExpenses() async {
    try {
      final result = await _salesRepo.getExpenseStatistics();
      final currentData = state.value ?? _getMockData();

      final updatedData = result.fold(
        (failure) => currentData.copyWith(
          expensesError: failure.message,
          isExpensesLoading: false,
        ),
        (data) => currentData.copyWith(
          expenseStatistics: data,
          clearExpensesError: true,
          isExpensesLoading: false,
        ),
      );

      state = AsyncData(updatedData);
    } catch (e) {
      final currentData = state.value ?? _getMockData();
      state = AsyncData(
        currentData.copyWith(
          expensesError: e.toString(),
          isExpensesLoading: false,
        ),
      );
    }
  }

  Future<void> _fetchStockLevel() async {
    try {
      final result = await _salesRepo.getStockLevelDashboard();
      final currentData = state.value ?? _getMockData();

      final updatedData = result.fold(
        (failure) => currentData.copyWith(
          stockLevelError: failure.message,
          isStockLevelLoading: false,
        ),
        (data) => currentData.copyWith(
          stockLevel: data,
          clearStockLevelError: true,
          isStockLevelLoading: false,
        ),
      );

      state = AsyncData(updatedData);
    } catch (e) {
      final currentData = state.value ?? _getMockData();
      state = AsyncData(
        currentData.copyWith(
          stockLevelError: e.toString(),
          isStockLevelLoading: false,
        ),
      );
    }
  }

  /// Mock data for development
  ReportsData _getMockData() {
    return const ReportsData(
      salesOverview: SalesOverviewData(
        todaysSalesCount: 0,
        salesCountPercentage: 0,
        lowStockCount: 0,
        todaysTotalRevenue: 0,
        revenuePercentage: 0,
      ),
      storeHealth: StoreHealthData(score: 100, status: 'Excellent'),
      aiInsight: "Next week's sales forecast shows that demand is rising.",
      lowStockItems: [], // actual data will come from API
      salesSummary: [
        MonthlySalesData(month: 'Jan', totalSales: 350, transactions: 120),
        MonthlySalesData(month: 'Feb', totalSales: 500, transactions: 180),
        MonthlySalesData(month: 'Mar', totalSales: 400, transactions: 150),
        MonthlySalesData(month: 'Apr', totalSales: 550, transactions: 200),
        MonthlySalesData(month: 'May', totalSales: 450, transactions: 170),
        MonthlySalesData(month: 'Jun', totalSales: 600, transactions: 220),
        MonthlySalesData(month: 'Jul', totalSales: 500, transactions: 190),
        MonthlySalesData(month: 'Aug', totalSales: 550, transactions: 210),
        MonthlySalesData(month: 'Sep', totalSales: 450, transactions: 175),
      ],
      expenseStatistics: const ExpenseStatisticsData(
        totalExpenses: 61100000,
        byCategory: {
          'Personnel': 7000000,
          'Facility': 50250000,
          'Marketing': 350000,
          'Compliance': 3500000,
        },
        byType: {'monthly': 61100000},
        countByCategory: {
          'Personnel': 2,
          'Facility': 2,
          'Marketing': 1,
          'Compliance': 1,
        },
      ),
      stockLevel: [
        StockLevelData(month: 'Jan', totalStock: 800),
        StockLevelData(month: 'Feb', totalStock: 750),
        StockLevelData(month: 'Mar', totalStock: 820),
        StockLevelData(month: 'Apr', totalStock: 690),
        StockLevelData(month: 'May', totalStock: 710),
        StockLevelData(month: 'Jun', totalStock: 780),
        StockLevelData(month: 'Jul', totalStock: 650),
        StockLevelData(month: 'Aug', totalStock: 720),
        StockLevelData(month: 'Sep', totalStock: 700),
      ],
      topSales: [], // actual data will come from API
    );
  }
}
