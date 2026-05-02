import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'guided_tour_provider.g.dart';

enum TourType { addProduct, addPayment, addCashier, checkSales }

@Riverpod(keepAlive: true)
class GuidedTour extends _$GuidedTour {
  @override
  TourType? build() {
    return null;
  }

  void startTour(TourType type) {
    state = type;
  }

  Future<void> completeTour(TourType type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tour_completed_${type.name}', true);
    if (state == type) {
      state = null;
    }
  }

  void clearTour() {
    state = null;
  }

  Future<bool> hasCompletedTour(TourType type) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('tour_completed_${type.name}') ?? false;
  }

  Future<void> resetAllTours() async {
    final prefs = await SharedPreferences.getInstance();
    for (var type in TourType.values) {
      await prefs.remove('tour_completed_${type.name}');
    }
    state = null;
  }
}
