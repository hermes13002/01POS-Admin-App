import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/reports_model.dart';

part 'reports_provider.g.dart';

/// Reports data provider
@riverpod
class Reports extends _$Reports {
  @override
  Future<ReportsData> build() async {
    // TODO: replace with actual api call
    return _getMockData();
  }

  /// Refresh reports data
  Future<void> refreshReports() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return _getMockData();
    });
  }

  /// Mock data for development
  ReportsData _getMockData() {
    return const ReportsData(
      salesOverview: SalesOverviewData(
        totalOrders: 3150,
        salesToday: 14,
        totalOrdersWithTrend: 3150,
      ),
      storeHealth: StoreHealthData(
        score: 100,
        status: 'Excellent',
      ),
      aiInsight: "Next week's sales forecast shows that demand is rising.",
      lowStockItems: [
        LowStockItem(name: 'Herbal sleep aid', quantity: 1),
        LowStockItem(name: 'Ultrabook pro 15', quantity: 1),
        LowStockItem(name: 'Modern sectional sofa', quantity: 1),
      ],
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
      totalExpenses: 730000,
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
      topSales: [
        TopSalesItem(rank: 1, name: 'Ultrabook pro 15', category: 'Electronics', amount: 70000, unitsSold: 25),
        TopSalesItem(rank: 2, name: 'Organic whole milk', category: 'Electronics', amount: 70000, unitsSold: 25),
        TopSalesItem(rank: 3, name: 'Herbal sleep aid', category: 'Electronics', amount: 70000, unitsSold: 25),
        TopSalesItem(rank: 4, name: 'Modern sectional sofa', category: 'Electronics', amount: 70000, unitsSold: 25),
        TopSalesItem(rank: 5, name: 'Cold brew coffee', category: 'Electronics', amount: 70000, unitsSold: 25),
      ],
    );
  }
}
