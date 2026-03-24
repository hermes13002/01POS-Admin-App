import '../../../products/data/models/product_model.dart';
import '../../../sales/data/models/sale_model.dart';

/// Model for sales overview data
class SalesOverviewData {
  final int todaysSalesCount;
  final double salesCountPercentage;
  final int lowStockCount;
  final double todaysTotalRevenue;
  final double revenuePercentage;

  const SalesOverviewData({
    required this.todaysSalesCount,
    required this.salesCountPercentage,
    required this.lowStockCount,
    required this.todaysTotalRevenue,
    required this.revenuePercentage,
  });

  factory SalesOverviewData.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is num) return val.toInt();
      return int.tryParse(val.toString()) ?? 0;
    }

    return SalesOverviewData(
      todaysSalesCount: parseInt(json['todaysSalesCount']),
      salesCountPercentage: parseDouble(json['salesCountPercentage']),
      lowStockCount: parseInt(json['lowStockCount']),
      todaysTotalRevenue: parseDouble(json['todaysTotalRevenue']),
      revenuePercentage: parseDouble(json['revenuePercentage']),
    );
  }
}

/// Model for store health
class StoreHealthData {
  final int score;
  final String status;

  const StoreHealthData({required this.score, required this.status});
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

  /// Parse from dashboard JSON
  static List<MonthlySalesData> fromDashboardJson(Map<String, dynamic> json) {
    final labels = List<String>.from(json['labels'] ?? []);
    final datasets = List<Map<String, dynamic>>.from(json['datasets'] ?? []);

    if (datasets.isEmpty) return [];

    final salesData = List<dynamic>.from(datasets[0]['data'] ?? []);
    final transactionsData = datasets.length > 1
        ? List<dynamic>.from(datasets[1]['data'] ?? [])
        : List<dynamic>.filled(labels.length, 0);

    return List.generate(labels.length, (i) {
      double parseDouble(dynamic val) {
        if (val == null) return 0.0;
        if (val is num) return val.toDouble();
        return double.tryParse(val.toString()) ?? 0.0;
      }

      int parseInt(dynamic val) {
        if (val == null) return 0;
        if (val is num) return val.toInt();
        return int.tryParse(val.toString()) ?? 0;
      }

      return MonthlySalesData(
        month: labels[i],
        totalSales: i < salesData.length ? parseDouble(salesData[i]) : 0.0,
        transactions: i < transactionsData.length
            ? parseInt(transactionsData[i])
            : 0,
      );
    });
  }
}

/// Model for stock level data
class StockLevelData {
  final String month;
  final double totalStock;

  const StockLevelData({required this.month, required this.totalStock});

  /// Parse from dashboard JSON
  static List<StockLevelData> fromDashboardJson(Map<String, dynamic> json) {
    final labels = List<String>.from(json['labels'] ?? []);
    final stockCounts = List<dynamic>.from(json['stock-count'] ?? []);

    return List.generate(labels.length, (i) {
      double parseDouble(dynamic val) {
        if (val == null) return 0.0;
        if (val is num) return val.toDouble();
        return double.tryParse(val.toString()) ?? 0.0;
      }

      return StockLevelData(
        month: labels[i],
        totalStock: i < stockCounts.length ? parseDouble(stockCounts[i]) : 0.0,
      );
    });
  }
}

/// Model for expense statistics
class ExpenseStatisticsData {
  final double totalExpenses;
  final Map<String, double> byCategory;
  final Map<String, double> byType;
  final Map<String, int> countByCategory;

  const ExpenseStatisticsData({
    required this.totalExpenses,
    required this.byCategory,
    required this.byType,
    required this.countByCategory,
  });

  factory ExpenseStatisticsData.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is num) return val.toInt();
      return int.tryParse(val.toString()) ?? 0;
    }

    final byCategory = <String, double>{};
    if (json['by_category'] is Map) {
      (json['by_category'] as Map).forEach((key, value) {
        byCategory[key.toString()] = parseDouble(value);
      });
    }

    final byType = <String, double>{};
    if (json['by_type'] is Map) {
      (json['by_type'] as Map).forEach((key, value) {
        byType[key.toString()] = parseDouble(value);
      });
    }

    final countByCategory = <String, int>{};
    if (json['count_by_category'] is Map) {
      (json['count_by_category'] as Map).forEach((key, value) {
        countByCategory[key.toString()] = parseInt(value);
      });
    }

    return ExpenseStatisticsData(
      totalExpenses: parseDouble(json['total_expenses']),
      byCategory: byCategory,
      byType: byType,
      countByCategory: countByCategory,
    );
  }
}

/// Full reports data model
class ReportsData {
  final SalesOverviewData salesOverview;
  final StoreHealthData storeHealth;
  final String aiInsight;
  final List<ProductModel> lowStockItems;
  final List<MonthlySalesData> salesSummary;
  final String salesSummaryFilter;
  final ExpenseStatisticsData? expenseStatistics;
  final List<StockLevelData> stockLevel;
  final List<SaleModel> topSales;
  final String? topSalesError;
  final bool isTopSalesLoading;
  final String? salesSummaryError;
  final bool isSalesSummaryLoading;
  final String? lowStockError;
  final bool isLowStockLoading;
  final String? salesOverviewError;
  final bool isSalesOverviewLoading;
  final String? stockLevelError;
  final bool isStockLevelLoading;
  final String? expensesError;
  final bool isExpensesLoading;

  const ReportsData({
    required this.salesOverview,
    required this.storeHealth,
    required this.aiInsight,
    required this.lowStockItems,
    required this.salesSummary,
    this.salesSummaryFilter = '12months',
    this.expenseStatistics,
    required this.stockLevel,
    required this.topSales,
    this.topSalesError,
    this.isTopSalesLoading = false,
    this.salesSummaryError,
    this.isSalesSummaryLoading = false,
    this.lowStockError,
    this.isLowStockLoading = false,
    this.salesOverviewError,
    this.isSalesOverviewLoading = false,
    this.stockLevelError,
    this.isStockLevelLoading = false,
    this.expensesError,
    this.isExpensesLoading = false,
  });

  ReportsData copyWith({
    SalesOverviewData? salesOverview,
    StoreHealthData? storeHealth,
    String? aiInsight,
    List<ProductModel>? lowStockItems,
    List<MonthlySalesData>? salesSummary,
    String? salesSummaryFilter,
    ExpenseStatisticsData? expenseStatistics,
    List<StockLevelData>? stockLevel,
    List<SaleModel>? topSales,
    String? topSalesError,
    bool? isTopSalesLoading,
    String? salesSummaryError,
    bool? isSalesSummaryLoading,
    String? lowStockError,
    bool? isLowStockLoading,
    String? salesOverviewError,
    bool? isSalesOverviewLoading,
    String? stockLevelError,
    bool? isStockLevelLoading,
    String? expensesError,
    bool? isExpensesLoading,
    bool clearTopSalesError = false,
    bool clearSalesSummaryError = false,
    bool clearLowStockError = false,
    bool clearSalesOverviewError = false,
    bool clearStockLevelError = false,
    bool clearExpensesError = false,
  }) {
    return ReportsData(
      salesOverview: salesOverview ?? this.salesOverview,
      storeHealth: storeHealth ?? this.storeHealth,
      aiInsight: aiInsight ?? this.aiInsight,
      lowStockItems: lowStockItems ?? this.lowStockItems,
      salesSummary: salesSummary ?? this.salesSummary,
      salesSummaryFilter: salesSummaryFilter ?? this.salesSummaryFilter,
      expenseStatistics: expenseStatistics ?? this.expenseStatistics,
      stockLevel: stockLevel ?? this.stockLevel,
      topSales: topSales ?? this.topSales,
      topSalesError: clearTopSalesError
          ? null
          : (topSalesError ?? this.topSalesError),
      isTopSalesLoading: isTopSalesLoading ?? this.isTopSalesLoading,
      salesSummaryError: clearSalesSummaryError
          ? null
          : (salesSummaryError ?? this.salesSummaryError),
      isSalesSummaryLoading:
          isSalesSummaryLoading ?? this.isSalesSummaryLoading,
      lowStockError: clearLowStockError
          ? null
          : (lowStockError ?? this.lowStockError),
      isLowStockLoading: isLowStockLoading ?? this.isLowStockLoading,
      salesOverviewError: clearSalesOverviewError
          ? null
          : (salesOverviewError ?? this.salesOverviewError),
      isSalesOverviewLoading:
          isSalesOverviewLoading ?? this.isSalesOverviewLoading,
      stockLevelError: clearStockLevelError
          ? null
          : (stockLevelError ?? this.stockLevelError),
      isStockLevelLoading: isStockLevelLoading ?? this.isStockLevelLoading,
      expensesError: clearExpensesError
          ? null
          : (expensesError ?? this.expensesError),
      isExpensesLoading: isExpensesLoading ?? this.isExpensesLoading,
    );
  }
}
