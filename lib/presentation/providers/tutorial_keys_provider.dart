import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TutorialKeys {
  final GlobalKey homeTab = GlobalKey();
  final GlobalKey loanTab = GlobalKey();
  final GlobalKey toolsTab = GlobalKey();

  final GlobalKey messagesIcon = GlobalKey();
  final GlobalKey notificationsIcon = GlobalKey();
  final GlobalKey profileIcon = GlobalKey();
  final GlobalKey viewReportButton = GlobalKey();
  final GlobalKey editQuickActionsButton = GlobalKey();

  final GlobalKey quickProducts = GlobalKey();
  final GlobalKey quickLowStock = GlobalKey();
  final GlobalKey quickSales = GlobalKey();
  final GlobalKey quickUsers = GlobalKey();
  final GlobalKey quickNewProduct = GlobalKey();
  final GlobalKey quickCustomers = GlobalKey();

  // the order here determines the sequence of the tutorial
  List<GlobalKey> get allKeys => [
    homeTab,
    loanTab,
    toolsTab,
    messagesIcon,
    notificationsIcon,
    profileIcon,
    viewReportButton,
    editQuickActionsButton,
    quickProducts,
    quickLowStock,
    quickSales,
    quickUsers,
    quickNewProduct,
    quickCustomers,
  ];
}

final tutorialKeysProvider = Provider<TutorialKeys>((ref) {
  return TutorialKeys();
});

/// signal to restart the tutorial showcase
final tutorialRestartProvider = StateProvider<bool>((ref) => false);
