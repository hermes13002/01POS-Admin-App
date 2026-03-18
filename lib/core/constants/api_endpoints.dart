/// API endpoint constants
class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String register = '/auth/register';
  static const String resetPassword = '/auth/rest-password';

  // Dashboard
  static const String dashboard = '/dashboard';
  static const String businessPerformance = '/dashboard/performance';

  // Products
  static const String products = '/products';
  static const String productById = '/products/{id}';
  static const String createProduct = '/products';
  static const String updateProduct = '/products/{id}';
  static const String deleteProduct = '/products/{id}';

  // Sales
  static const String sales = '/sales';
  static const String saleById = '/sales/{id}';
  static const String allSales = '/admin/dashboard/all-sales';

  // Orders
  static const String orders = '/orders';
  static const String orderById = '/orders/{id}';

  // Customers
  static const String customers = '/customers';
  static const String customerById = '/customers/{id}';
  static const String allCustomers = '/admin/customers';
  static const String showCustomer = '/admin/customers/show';
  static const String storeCustomer = '/admin/customers/store';
  static const String updateCustomer = '/admin/customers/update';
  static const String deleteCustomer = '/admin/customers/delete';

  // Invoices
  static const String invoices = '/invoices';
  static const String invoiceById = '/invoices/{id}';
  static const String generateInvoice = '/invoices/generate';

  // Expenses
  static const String expenses = '/admin/expenses';
  static const String expenseById = '/admin/expenses/{id}';
  static const String expenseMetadata = '/admin/expenses/metadata';

  // Inventory
  static const String inventory = '/inventory';
  static const String lowStock = '/inventory/low-stock';
  static const String lowStockAI = '/inventory/low-stock-ai';

  // Reports
  static const String reports = '/reports';
  static const String salesReport = '/reports/sales';
  static const String inventoryReport = '/reports/inventory';

  // Users
  static const String users = '/users';
  static const String allUsers = '/admin/users';
  static const String userById = '/users/{id}';
  static const String showUser = '/admin/users/show';
  static const String activateUser = '/admin/users/activate';
  static const String deactivateUser = '/admin/users/deactivate';
  static const String storeUser = '/admin/users/store';
  static const String updateUser = '/admin/users/update';
  static const String getRoles = '/admin/roles';
  static const String deleteUser = '/admin/users/delete';

  // Payment Methods
  static const String paymentMethods = '/payment-methods';
  static const String allPaymentMethods = '/admin/payment-methods';
  static const String showPaymentMethod = '/admin/payment-methods/show';
  static const String storePaymentMethod = '/admin/payment-methods/store';
  static const String updatePaymentMethod = '/admin/payment-methods/update';
  static const String deletePaymentMethod = '/admin/payment-methods/delete';

  // Store Settings
  static const String storeSettings = '/store/settings';
  static const String myStore = '/store/my-store';
  static const String receiptTemplate = '/admin/receipt-template';
  static const String currencySettings = '/admin/currency-settings';
  static const String currencySettingsCurrencies =
      '/admin/currency-settings/currencies';
  static const String currencySettingsUpdate =
      '/admin/currency-settings/update';

  // Discounts
  static const String discounts = '/discounts';

  // Bills
  static const String bills = '/bills';

  // Cashier
  static const String registerCashier = '/cashier/register';

  // Notifications
  static const String notifications = '/admin/notifications';
  static const String categories = '/admin/categories';
  static const String storeCategory = '/admin/categories/store';
  static const String updateCategory = '/admin/categories/update/'; // {id}
  static const String showCategory = '/admin/categories/show/'; // {id}
  static const String viewNotification = '/admin/notifications/view/';
  static const String readNotification = '/admin/notifications/read/';
  static const String deleteNotification = '/admin/notifications/delete/';
  static const String deleteAllReadNotifications =
      '/admin/notifications/allread/delete';
  static const String deleteCategory = '/admin/categories/delete/'; // {id}
  static const String activateCategory = '/admin/categories/activate/'; // {id}
  static const String deactivateCategory =
      '/admin/categories/deactivate/'; // {id}
  static const String subCategories = '/admin/sub_categories';
  static const String storeSubCategory = '/admin/sub_categories/store';
  static const String updateSubCategory =
      '/admin/sub_categories/update/'; // {id}
  static const String showSubCategory = '/admin/sub_categories/show/'; // {id}
  static const String deleteSubCategory =
      '/admin/sub_categories/delete/'; // {id}
  static const String activateSubCategory =
      '/admin/sub_categories/activate/'; // {id}
  static const String deactivateSubCategory =
      '/admin/sub_categories/deactivate/'; // {id}
}
