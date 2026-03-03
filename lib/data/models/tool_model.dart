/// Tool model for tools screen and quick actions
class ToolModel {
  final String id;
  final String name;
  final String iconPath;
  final String route;

  const ToolModel({
    required this.id,
    required this.name,
    required this.iconPath,
    required this.route,
  });

  ToolModel copyWith({
    String? id,
    String? name,
    String? iconPath,
    String? route,
  }) {
    return ToolModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconPath: iconPath ?? this.iconPath,
      route: route ?? this.route,
    );
  }
}

/// Available tools in the app
class AppTools {
  // private constructor
  AppTools._();

  static const List<ToolModel> allTools = [
    ToolModel(
      id: 'reports',
      name: 'Reports',
      iconPath: 'assets/icons/reports.png',
      route: '/reports',
    ),
    ToolModel(
      id: 'products',
      name: 'Products',
      iconPath: 'assets/icons/products.png',
      route: '/products',
    ),
    ToolModel(
      id: 'my_store',
      name: 'My Store',
      iconPath: 'assets/icons/my_store.png',
      route: '/my-store',
    ),
    ToolModel(
      id: 'low_stock',
      name: 'Low Stock',
      iconPath: 'assets/icons/low_stock.png',
      route: '/low-stock',
    ),
    ToolModel(
      id: 'low_stock_ai',
      name: 'Low Stock AI',
      iconPath: 'assets/icons/low_stock_ai.png',
      route: '/low-stock-ai',
    ),
    ToolModel(
      id: 'sales',
      name: 'Sales',
      iconPath: 'assets/icons/sales.png',
      route: '/sales',
    ),
    ToolModel(
      id: 'orders',
      name: 'Orders',
      iconPath: 'assets/icons/orders.png',
      route: '/orders',
    ),
    ToolModel(
      id: 'customers',
      name: 'Customers',
      iconPath: 'assets/icons/customers.png',
      route: '/customers',
    ),
    ToolModel(
      id: 'invoices',
      name: 'Invoices',
      iconPath: 'assets/icons/invoices.png',
      route: '/invoices',
    ),
    ToolModel(
      id: 'expenses',
      name: 'Expenses',
      iconPath: 'assets/icons/expenses.png',
      route: '/expenses',
    ),
    ToolModel(
      id: 'bill',
      name: 'Bill',
      iconPath: 'assets/icons/bill.png',
      route: '/bill',
    ),
    ToolModel(
      id: 'discount',
      name: 'Discount',
      iconPath: 'assets/icons/discount.png',
      route: '/discount',
    ),
    ToolModel(
      id: 'users',
      name: 'Users',
      iconPath: 'assets/icons/users.png',
      route: '/users',
    ),
    ToolModel(
      id: 'payment_method',
      name: 'Payment Method',
      iconPath: 'assets/icons/payment_method.png',
      route: '/payment-method',
    ),
    ToolModel(
      id: 'online_store',
      name: 'Online Store',
      iconPath: 'assets/icons/online_store.png',
      route: '/online-store',
    ),
  ];

  /// Default quick actions (first 6 tools)
  static List<ToolModel> get defaultQuickActions => allTools.take(6).toList();
}
