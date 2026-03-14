/// API endpoint constants
class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String register = '/auth/register';

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
  static const String expenses = '/expenses';
  static const String expenseById = '/expenses/{id}';

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

  // Discounts
  static const String discounts = '/discounts';

  // Bills
  static const String bills = '/bills';

  // Cashier
  static const String registerCashier = '/cashier/register';
}
