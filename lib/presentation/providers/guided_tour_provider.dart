import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'guided_tour_provider.g.dart';

enum TourType { addProduct, addPayment, addCashier, checkSales }

@riverpod
class GuidedTour extends _$GuidedTour {
  @override
  TourType? build() {
    return null;
  }

  /// Start a tour. Sets it as the active tour in memory.
  void startTour(TourType type) {
    state = type;
  }

  /// Mark a tour as completed in persistent storage and clear active state.
  Future<void> completeTour(TourType type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tour_completed_${type.name}', true);
    if (state == type) {
      state = null;
    }
  }

  /// Clear the active tour without marking it completed.
  void clearTour() {
    state = null;
  }

  /// Check if a tour has been completed before (for organic triggers).
  Future<bool> hasCompletedTour(TourType type) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('tour_completed_${type.name}') ?? false;
  }

  /// Force reset all tour progress for testing or full reset
  Future<void> resetAllTours() async {
    final prefs = await SharedPreferences.getInstance();
    for (var type in TourType.values) {
      await prefs.remove('tour_completed_${type.name}');
    }
    state = null;
  }
}
