import 'package:flutter/material.dart';
import 'package:onepos_admin_app/core/routes/app_routes.dart';

/// Tool model for tools screen and quick actions
class ToolModel {
  final String id;
  final String name;
  final String iconPath;
  final IconData icon;
  final String route;

  const ToolModel({
    required this.id,
    required this.name,
    required this.iconPath,
    required this.icon,
    required this.route,
  });

  ToolModel copyWith({
    String? id,
    String? name,
    String? iconPath,
    IconData? icon,
    String? route,
  }) {
    return ToolModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconPath: iconPath ?? this.iconPath,
      icon: icon ?? this.icon,
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
      icon: Icons.bar_chart,
      route: '/reports',
    ),
    ToolModel(
      id: 'products',
      name: 'Products',
      iconPath: 'assets/icons/products.png',
      icon: Icons.inventory_2_outlined,
      route: '/products',
    ),
    ToolModel(
      id: 'my_store',
      name: 'My Store',
      iconPath: 'assets/icons/my_store.png',
      icon: Icons.storefront_outlined,
      route: '/my-store',
    ),
    ToolModel(
      id: 'low_stock',
      name: 'Low Stock',
      iconPath: 'assets/icons/low_stock.png',
      icon: Icons.warning_amber_outlined,
      route: '/low-stock',
    ),
    // ToolModel(
    //   id: 'low_stock_ai',
    //   name: 'Low Stock AI',
    //   iconPath: 'assets/icons/low_stock_ai.png',
    //   icon: Icons.smart_toy_outlined,
    //   route: '/low-stock-ai',
    // ),
    ToolModel(
      id: 'sales',
      name: 'Sales',
      iconPath: 'assets/icons/sales.png',
      icon: Icons.point_of_sale_outlined,
      route: '/sales',
    ),
    // ToolModel(
    //   id: 'orders',
    //   name: 'Orders',
    //   iconPath: 'assets/icons/orders.png',
    //   icon: Icons.shopping_cart_outlined,
    //   route: '/orders',
    // ),
    ToolModel(
      id: 'customers',
      name: 'Customers',
      iconPath: 'assets/icons/customers.png',
      icon: Icons.people_outline,
      route: '/customers',
    ),
    ToolModel(
      id: 'invoices',
      name: 'Invoices',
      iconPath: 'assets/icons/invoices.png',
      icon: Icons.receipt_long_outlined,
      route: AppRoutes.invoices,
    ),
    ToolModel(
      id: 'expenses',
      name: 'Expenses',
      iconPath: 'assets/icons/expenses.png',
      icon: Icons.account_balance_wallet_outlined,
      route: '/expenses',
    ),
    ToolModel(
      id: 'bill',
      name: 'Bill',
      iconPath: 'assets/icons/bill.png',
      icon: Icons.receipt_outlined,
      route: '/bill',
    ),
    ToolModel(
      id: 'discount',
      name: 'Discount',
      iconPath: 'assets/icons/discount.png',
      icon: Icons.local_offer_outlined,
      route: '/discount',
    ),
    ToolModel(
      id: 'users',
      name: 'Users',
      iconPath: 'assets/icons/users.png',
      icon: Icons.person_outline,
      route: '/users',
    ),
    ToolModel(
      id: 'payment_method',
      name: 'Payment Method',
      iconPath: 'assets/icons/payment_method.png',
      icon: Icons.payment_outlined,
      route: '/payment-method',
    ),
    // ToolModel(
    //   id: 'online_store',
    //   name: 'Online Store',
    //   iconPath: 'assets/icons/online_store.png',
    //   icon: Icons.language_outlined,
    //   route: '/online-store',
    // ),
    ToolModel(
      id: 'new_product',
      name: 'New Product',
      iconPath: 'assets/icons/new_product.png',
      icon: Icons.add_box_outlined,
      route: '/add-product',
    ),
  ];

  /// Default quick actions (first 6 tools)
  static List<ToolModel> get defaultQuickActions => allTools.take(6).toList();
}
