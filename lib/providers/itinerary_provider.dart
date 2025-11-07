import 'package:flutter/material.dart';
import 'package:jomjalan/models/spot_model.dart';

class ItineraryProvider with ChangeNotifier {
  final List<Spot> _itinerarySpots = [];

  List<Spot> get spots => _itinerarySpots;

  void addSpot(Spot spot) {
    if (!_itinerarySpots.any((s) => s.id == spot.id)) {
      _itinerarySpots.add(spot);
      notifyListeners(); // Tell widgets to rebuild
    }
  }

  void removeSpot(Spot spot) {
    _itinerarySpots.removeWhere((s) => s.id == spot.id);
    notifyListeners(); // Tell widgets to rebuild
  }

  bool isSpotInItinerary(Spot spot) {
    return _itinerarySpots.any((s) => s.id == spot.id);
  }
}
