import 'package:flutter/material.dart';
import 'package:jomjalan/models/spot_model.dart';
import 'package:jomjalan/services/mock_api_service.dart';

class ItineraryProvider with ChangeNotifier {
  final List<Spot> _itinerarySpots = [];

  List<Spot> get spots => _itinerarySpots;

  void addSpot(Spot spot) {
    if (!_itinerarySpots.any((s) => s.id == spot.id)) {
      _itinerarySpots.add(spot);
      notifyListeners(); // Tell widgets to rebuild
    }
  }

  /// Clears existing itinerary and adds all new spots from the AI plan
  Future<void> addSpotsFromAi(
    List<dynamic> itineraryDays,
    MockApiService apiService,
  ) async {
    // 1. Clear the old list
    _itinerarySpots.clear();

    // 2. Loop through the JSON from the AI
    for (var day in itineraryDays) {
      if (day['activities'] == null) continue;

      for (var activity in day['activities']) {
        final name = activity['name'];
        final description = activity['description'];

        try {
          // 3. Get REAL data from Google using the 'findPlace' API
          final result = await apiService.findPlace(name);

          String imageUrl =
              'https://placehold.co/400x400/00bd6c/white?text=${Uri.encodeComponent(name)}';
          String location = description; // Fallback

          // --- THIS IS THE FIX ---
          // Your backend now returns 'imageUrl' and 'location'
          if (result['status'] == 'OK') {
            imageUrl = result['imageUrl'];
            location = result['location'];
          }
          // -----------------------

          // 4. Create a new Spot object with REAL data
          final newSpot = Spot(
            id: 'ai_${DateTime.now().millisecondsSinceEpoch}_$name',
            name: name,
            location: location,
            description: description,
            imageUrl: imageUrl, // The REAL image URL
            rating: null,
            userRatingsTotal: null,
            priceLevel: null,
          );

          // 5. Add the new spot to the list (if not already added)
          if (!_itinerarySpots.any((s) => s.name == newSpot.name)) {
            _itinerarySpots.add(newSpot);
          }
        } catch (e) {
          print("Error enriching AI spot '$name': $e");
          // If enrichment fails, add with placeholder data
          _itinerarySpots.add(
            Spot(
              id: 'ai_${DateTime.now().millisecondsSinceEpoch}_$name',
              name: name,
              location: description,
              description: description,
              imageUrl: 'https://placehold.co/400x400/00bd6c/white?text=Error',
            ),
          );
        }
      }
    }

    // 6. Tell the ItineraryPage to rebuild
    notifyListeners();
  }

  void removeSpot(Spot spot) {
    _itinerarySpots.removeWhere((s) => s.id == spot.id);
    notifyListeners(); // Tell widgets to rebuild
  }

  bool isSpotInItinerary(Spot spot) {
    return _itinerarySpots.any((s) => s.id == spot.id);
  }
}
