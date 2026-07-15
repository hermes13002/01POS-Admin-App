import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:onepos_admin_app/core/network/dio_client.dart';
import 'package:onepos_admin_app/features/online_store/data/datasources/billing_remote_datasource.dart';

import 'profile_provider.dart';

class SubscriptionPlanConfig {
  final String key;
  final String productId;
  final int amount;
  final int months;
  final String displayName;

  const SubscriptionPlanConfig({
    required this.key,
    required this.productId,
    required this.amount,
    required this.months,
    required this.displayName,
  });
}

const List<SubscriptionPlanConfig> kSubscriptionPlans = [
  SubscriptionPlanConfig(
    key: 'standard',
    productId: 'net.onepos.app.standard_monthly',
    amount: 6000,
    months: 1,
    displayName: 'Standard',
  ),
  SubscriptionPlanConfig(
    key: 'pro',
    productId: 'net.oneposadmin.app.pro_1month',
    amount: 11000,
    months: 1,
    displayName: 'Pro',
  ),
];

class SubscriptionBillingState {
  final bool isStoreAvailable;
  final bool isLoadingProducts;
  final Map<String, ProductDetails> productsById;
  final String? pendingProductId;
  final bool isRestoring;
  final String? errorMessage;
  final String? successMessage;

  const SubscriptionBillingState({
    required this.isStoreAvailable,
    required this.isLoadingProducts,
    required this.productsById,
    this.pendingProductId,
    required this.isRestoring,
    this.errorMessage,
    this.successMessage,
  });

  const SubscriptionBillingState.initial()
    : isStoreAvailable = false,
      isLoadingProducts = true,
      productsById = const {},
      pendingProductId = null,
      isRestoring = false,
      errorMessage = null,
      successMessage = null;

  SubscriptionBillingState copyWith({
    bool? isStoreAvailable,
    bool? isLoadingProducts,
    Map<String, ProductDetails>? productsById,
    String? pendingProductId,
    bool clearPendingProductId = false,
    bool? isRestoring,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
  }) {
    return SubscriptionBillingState(
      isStoreAvailable: isStoreAvailable ?? this.isStoreAvailable,
      isLoadingProducts: isLoadingProducts ?? this.isLoadingProducts,
      productsById: productsById ?? this.productsById,
      pendingProductId: clearPendingProductId
          ? null
          : (pendingProductId ?? this.pendingProductId),
      isRestoring: isRestoring ?? this.isRestoring,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
    );
  }
}

class SubscriptionBillingNotifier
    extends AsyncNotifier<SubscriptionBillingState> {
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  final Set<String> _processedPurchaseIds = <String>{};

  BillingRemoteDatasource get _billingDatasource =>
      BillingRemoteDatasourceImpl(DioClient());

  @override
  Future<SubscriptionBillingState> build() async {
    _purchaseSubscription ??= _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _purchaseSubscription?.cancel(),
      onError: (Object _) {
        _setState(
          _currentState.copyWith(
            clearPendingProductId: true,
            errorMessage: 'Purchase stream failed. Please try again.',
            clearSuccess: true,
          ),
        );
      },
    );

    ref.onDispose(() async {
      await _purchaseSubscription?.cancel();
      _purchaseSubscription = null;
    });

    return _loadProducts();
  }

  SubscriptionBillingState get _currentState =>
      state.valueOrNull ?? const SubscriptionBillingState.initial();

  Future<void> refreshProducts() async {
    _setState(
      _currentState.copyWith(
        isLoadingProducts: true,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      final loaded = await _loadProducts();
      _setState(loaded);
    } catch (_) {
      _setState(
        _currentState.copyWith(
          isLoadingProducts: false,
          errorMessage: 'Failed to load subscription products.',
        ),
      );
    }
  }

  Future<void> purchasePlan(String productId) async {
    final current = _currentState;

    if (!current.isStoreAvailable) {
      _setState(
        current.copyWith(
          errorMessage: 'In-app purchases are not available on this device.',
          clearSuccess: true,
        ),
      );
      return;
    }

    final product = current.productsById[productId];
    if (product == null) {
      _setState(
        current.copyWith(
          errorMessage: 'Plan is not available in App Store right now.',
          clearSuccess: true,
        ),
      );
      return;
    }

    final purchaseParam = PurchaseParam(productDetails: product);

    _setState(
      current.copyWith(
        pendingProductId: productId,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      final success = await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      if (!success) {
        _setState(
          _currentState.copyWith(
            clearPendingProductId: true,
            errorMessage: 'Unable to start purchase. Please try again.',
            clearSuccess: true,
          ),
        );
      }
    } catch (_) {
      _setState(
        _currentState.copyWith(
          clearPendingProductId: true,
          errorMessage: 'Unable to start purchase. Please try again.',
          clearSuccess: true,
        ),
      );
    }
  }

  Future<void> restorePurchases() async {
    final current = _currentState;

    if (!current.isStoreAvailable) {
      _setState(
        current.copyWith(
          errorMessage: 'In-app purchases are not available on this device.',
          clearSuccess: true,
        ),
      );
      return;
    }

    _setState(
      current.copyWith(isRestoring: true, clearError: true, clearSuccess: true),
    );

    try {
      await _iap.restorePurchases();
      _setState(_currentState.copyWith(isRestoring: false));
    } catch (_) {
      _setState(
        _currentState.copyWith(
          isRestoring: false,
          errorMessage: 'Unable to restore purchases right now.',
          clearSuccess: true,
        ),
      );
    }
  }

  void clearMessages() {
    _setState(_currentState.copyWith(clearError: true, clearSuccess: true));
  }

  Future<SubscriptionBillingState> _loadProducts() async {
    final isAvailable = await _iap.isAvailable();
    if (!isAvailable) {
      return _currentState.copyWith(
        isStoreAvailable: false,
        isLoadingProducts: false,
        productsById: const {},
        clearPendingProductId: true,
        isRestoring: false,
      );
    }

    final ids = kSubscriptionPlans.map((e) => e.productId).toSet();
    final response = await _iap.queryProductDetails(ids);

    final productsById = <String, ProductDetails>{
      for (final product in response.productDetails) product.id: product,
    };

    if (response.error != null) {
      return _currentState.copyWith(
        isStoreAvailable: true,
        isLoadingProducts: false,
        productsById: productsById,
        clearPendingProductId: true,
        isRestoring: false,
        errorMessage: 'Failed to load some plans. Please refresh.',
      );
    }

    return _currentState.copyWith(
      isStoreAvailable: true,
      isLoadingProducts: false,
      productsById: productsById,
      clearPendingProductId: true,
      isRestoring: false,
      clearError: true,
    );
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      bool shouldComplete = false;

      switch (purchase.status) {
        case PurchaseStatus.pending:
          _setState(
            _currentState.copyWith(
              pendingProductId: purchase.productID,
              clearError: true,
              clearSuccess: true,
            ),
          );
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          final success = await _handleCompletedPurchase(purchase);
          if (success) {
            shouldComplete = true;
          }
          break;
        case PurchaseStatus.error:
          _setState(
            _currentState.copyWith(
              clearPendingProductId: true,
              isRestoring: false,
              errorMessage:
                  purchase.error?.message ??
                  'Purchase failed. Please try again.',
              clearSuccess: true,
            ),
          );
          shouldComplete = true;
          break;
        case PurchaseStatus.canceled:
          _setState(
            _currentState.copyWith(
              clearPendingProductId: true,
              isRestoring: false,
              errorMessage: 'Purchase canceled.',
              clearSuccess: true,
            ),
          );
          shouldComplete = true;
          break;
      }

      if (shouldComplete && purchase.pendingCompletePurchase) {
        try {
          await _iap.completePurchase(purchase);
        } catch (_) {
          // Ignore complete purchase errors
        }
      }
    }
  }

  Future<bool> _handleCompletedPurchase(PurchaseDetails purchase) async {
    final purchaseId = purchase.purchaseID;
    if (purchaseId != null && _processedPurchaseIds.contains(purchaseId)) {
      _setState(
        _currentState.copyWith(
          clearPendingProductId: true,
          isRestoring: false,
          clearError: true,
        ),
      );
      return true;
    }

    final plan = kSubscriptionPlans
        .where((plan) => plan.productId == purchase.productID)
        .cast<SubscriptionPlanConfig?>()
        .firstWhere((_) => true, orElse: () => null);

    if (plan == null) {
      _setState(
        _currentState.copyWith(
          clearPendingProductId: true,
          isRestoring: false,
          errorMessage: 'Unknown purchased product: ${purchase.productID}',
          clearSuccess: true,
        ),
      );
      return true;
    }

    try {
      await _billingDatasource.upgradePlan(
        amount: plan.amount,
        months: plan.months,
        plan: plan.key,
        status: 'success',
        productId: purchase.productID,
        transactionId: purchase.verificationData.serverVerificationData,
        purchaseId: purchase.purchaseID,
      );

      if (purchaseId != null) {
        _processedPurchaseIds.add(purchaseId);
      }

      ref.invalidate(userProfileProvider);

      final restored = purchase.status == PurchaseStatus.restored;
      _setState(
        _currentState.copyWith(
          clearPendingProductId: true,
          isRestoring: false,
          clearError: true,
          successMessage: restored
              ? '${plan.displayName} restored successfully.'
              : '${plan.displayName} activated successfully.',
        ),
      );
      return true;
    } catch (e) {
      _setState(
        _currentState.copyWith(
          clearPendingProductId: true,
          isRestoring: false,
          errorMessage:
              'Sync failed: $e. Please tap Restore Purchases.',
          clearSuccess: true,
        ),
      );
      return false;
    }
  }

  void _setState(SubscriptionBillingState value) {
    state = AsyncData(value);
  }
}

final subscriptionBillingProvider =
    AsyncNotifierProvider<
      SubscriptionBillingNotifier,
      SubscriptionBillingState
    >(SubscriptionBillingNotifier.new);
