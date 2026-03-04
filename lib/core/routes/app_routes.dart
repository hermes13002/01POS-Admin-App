import 'package:flutter/material.dart';
import 'package:onepos_admin_app/features/low_stock/presentation/screens/low_stock_screen.dart';
import 'package:onepos_admin_app/features/products/presentation/screens/add_product_screen.dart';
import 'package:onepos_admin_app/features/sales/presentation/screens/sales_screen.dart';
import 'package:onepos_admin_app/features/products/presentation/screens/products_screen.dart';
import 'package:onepos_admin_app/features/reports/presentation/screens/reports_screen.dart';
import 'package:onepos_admin_app/features/store/presentation/screens/add_category_screen.dart';
import 'package:onepos_admin_app/features/store/presentation/screens/add_sub_category_screen.dart';
import 'package:onepos_admin_app/features/store/presentation/screens/my_store_screen.dart';

/// centralized route configuration
class AppRoutes {
  // private constructor
  AppRoutes._();

  // route names
  static const String reports = '/reports';
  static const String products = '/products';
  static const String addProduct = '/add-product';
  static const String myStore = '/my-store';
  static const String addCategory = '/add-category';
  static const String addSubCategory = '/add-sub-category';
  static const String lowStock = '/low-stock';
  static const String sales = '/sales';

  // route map
  static Map<String, WidgetBuilder> get routes => {
        reports: (context) => const ReportsScreen(),
        products: (context) => const ProductsScreen(),
        addProduct: (context) => const AddProductScreen(),
        myStore: (context) => const MyStoreScreen(),
        addCategory: (context) => const AddCategoryScreen(),
        addSubCategory: (context) => const AddSubCategoryScreen(),
        lowStock: (context) => const LowStockScreen(),
        sales: (context) => const SalesScreen(),
      };
}
