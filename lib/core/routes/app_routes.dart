import 'package:flutter/material.dart';
import 'package:onepos_admin_app/features/auth/presentation/screens/login_screen.dart';
import 'package:onepos_admin_app/features/low_stock/presentation/screens/low_stock_screen.dart';
import 'package:onepos_admin_app/features/products/presentation/screens/add_product_screen.dart';
import 'package:onepos_admin_app/features/sales/presentation/screens/sales_screen.dart';
import 'package:onepos_admin_app/features/products/presentation/screens/products_screen.dart';
import 'package:onepos_admin_app/features/reports/presentation/screens/reports_screen.dart';
import 'package:onepos_admin_app/features/store/presentation/screens/add_category_screen.dart';
import 'package:onepos_admin_app/features/store/presentation/screens/add_sub_category_screen.dart';
import 'package:onepos_admin_app/features/store/presentation/screens/my_store_screen.dart';
import 'package:onepos_admin_app/features/customers/presentation/screens/customers_screen.dart';
import 'package:onepos_admin_app/features/customers/presentation/screens/add_customer_screen.dart';
import 'package:onepos_admin_app/features/expenses/presentation/screens/expenses_screen.dart';
import 'package:onepos_admin_app/features/expenses/presentation/screens/add_expense_screen.dart';
import 'package:onepos_admin_app/features/bill/presentation/screens/bills_screen.dart';
import 'package:onepos_admin_app/features/bill/presentation/screens/add_bill_screen.dart';
import 'package:onepos_admin_app/features/discount/presentation/screens/discount_screen.dart';
import 'package:onepos_admin_app/features/discount/presentation/screens/add_discount_screen.dart';
import 'package:onepos_admin_app/features/users/presentation/screens/users_screen.dart';
import 'package:onepos_admin_app/features/users/presentation/screens/add_user_screen.dart';
import 'package:onepos_admin_app/features/payment_method/presentation/screens/payment_method_screen.dart';
import 'package:onepos_admin_app/features/payment_method/presentation/screens/add_payment_method_screen.dart';
import 'package:onepos_admin_app/features/payment_method/presentation/screens/connect_bank_account_screen.dart';
import 'package:onepos_admin_app/features/online_store/presentation/screens/store_profile_screen.dart';
import 'package:onepos_admin_app/features/online_store/presentation/screens/edit_store_name_screen.dart';
import 'package:onepos_admin_app/features/online_store/presentation/screens/edit_email_address_screen.dart';
import 'package:onepos_admin_app/features/online_store/presentation/screens/edit_phone_number_screen.dart';
import 'package:onepos_admin_app/features/online_store/presentation/screens/edit_address_screen.dart';
import 'package:onepos_admin_app/features/online_store/presentation/screens/login_settings_screen.dart';
import 'package:onepos_admin_app/features/online_store/presentation/screens/receipt_template_screen.dart';
import 'package:onepos_admin_app/features/online_store/presentation/screens/update_receipt_template_screen.dart';
import 'package:onepos_admin_app/features/online_store/presentation/screens/currency_settings_screen.dart';

/// centralized route configuration
class AppRoutes {
  // private constructor
  AppRoutes._();

  // route names
  static const String login = '/login';
  static const String reports = '/reports';
  static const String products = '/products';
  static const String addProduct = '/add-product';
  static const String myStore = '/my-store';
  static const String addCategory = '/add-category';
  static const String addSubCategory = '/add-sub-category';
  static const String lowStock = '/low-stock';
  static const String sales = '/sales';
  static const String customers = '/customers';
  static const String addCustomer = '/add-customer';
  static const String expenses = '/expenses';
  static const String addExpense = '/add-expense';
  static const String bills = '/bill';
  static const String addBill = '/add-bill';
  static const String discount = '/discount';
  static const String addDiscount = '/add-discount';
  static const String users = '/users';
  static const String addUser = '/add-user';
  static const String paymentMethod = '/payment-method';
  static const String addPaymentMethod = '/add-payment-method';
  static const String connectBankAccount = '/connect-bank-account';
  static const String onlineStore = '/online-store';
  static const String editStoreName = '/edit-store-name';
  static const String editEmailAddress = '/edit-email-address';
  static const String editPhoneNumber = '/edit-phone-number';
  static const String editAddress = '/edit-address';
  static const String loginSettings = '/login-settings';
  static const String currencySettings = '/currency-settings';
  static const String receiptTemplateSettings = '/receipt-template-settings';
  static const String updateReceiptTemplate = '/update-receipt-template';

  // route map
  static Map<String, WidgetBuilder> get routes => {
    login: (context) => const LoginScreen(),
    reports: (context) => const ReportsScreen(),
    products: (context) => const ProductsScreen(),
    addProduct: (context) => const AddProductScreen(),
    myStore: (context) => const MyStoreScreen(),
    addCategory: (context) => const AddCategoryScreen(),
    addSubCategory: (context) => const AddSubCategoryScreen(),
    lowStock: (context) => const LowStockScreen(),
    sales: (context) => const SalesScreen(),
    customers: (context) => const CustomersScreen(),
    addCustomer: (context) => const AddCustomerScreen(),
    expenses: (context) => const ExpensesScreen(),
    addExpense: (context) => const AddExpenseScreen(),
    bills: (context) => const BillsScreen(),
    addBill: (context) => const AddBillScreen(),
    discount: (context) => const DiscountScreen(),
    addDiscount: (context) => const AddDiscountScreen(),
    users: (context) => const UsersScreen(),
    addUser: (context) => const AddUserScreen(),
    paymentMethod: (context) => const PaymentMethodScreen(),
    addPaymentMethod: (context) => const AddPaymentMethodScreen(),
    connectBankAccount: (context) => const ConnectBankAccountScreen(),
    onlineStore: (context) => const StoreProfileScreen(),
    editStoreName: (context) => const EditStoreNameScreen(),
    editEmailAddress: (context) => const EditEmailAddressScreen(),
    editPhoneNumber: (context) => const EditPhoneNumberScreen(),
    editAddress: (context) => const EditAddressScreen(),
    loginSettings: (context) => const LoginSettingsScreen(),
    currencySettings: (context) => const CurrencySettingsScreen(),
    receiptTemplateSettings: (context) => const ReceiptTemplateScreen(),
    updateReceiptTemplate: (context) => const UpdateReceiptTemplateScreen(),
  };
}
