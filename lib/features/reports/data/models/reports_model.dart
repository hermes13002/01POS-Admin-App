/// Model for sales overview data
class SalesOverviewData {
  final int totalOrders;
  final int salesToday;
  final int totalOrdersWithTrend;

  const SalesOverviewData({
    required this.totalOrders,
    required this.salesToday,
    required this.totalOrdersWithTrend,
  });
}

/// Model for store health
class StoreHealthData {
  final int score;
  final String status;

  const StoreHealthData({
    required this.score,
    required this.status,
  });
}

/// Model for low stock item
class LowStockItem {
  final String name;
  final int quantity;

  const LowStockItem({
    required this.name,
    required this.quantity,
  });
}

/// Model for monthly sales data
class MonthlySalesData {
  final String month;
  final double totalSales;
  final int transactions;

  const MonthlySalesData({
    required this.month,
    required this.totalSales,
    required this.transactions,
  });
}

/// Model for top sales item
class TopSalesItem {
  final int rank;
  final String name;
  final String category;
  final double amount;
  final int unitsSold;

  const TopSalesItem({
    required this.rank,
    required this.name,
    required this.category,
    required this.amount,
    required this.unitsSold,
  });
}

/// Model for stock level data
class StockLevelData {
  final String month;
  final double totalStock;

  const StockLevelData({
    required this.month,
    required this.totalStock,
  });
}

/// Full reports data model
class ReportsData {
  final SalesOverviewData salesOverview;
  final StoreHealthData storeHealth;
  final String aiInsight;
  final List<LowStockItem> lowStockItems;
  final List<MonthlySalesData> salesSummary;
  final double totalExpenses;
  final List<StockLevelData> stockLevel;
  final List<TopSalesItem> topSales;

  const ReportsData({
    required this.salesOverview,
    required this.storeHealth,
    required this.aiInsight,
    required this.lowStockItems,
    required this.salesSummary,
    required this.totalExpenses,
    required this.stockLevel,
    required this.topSales,
  });
}
