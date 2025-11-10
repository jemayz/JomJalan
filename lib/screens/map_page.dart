import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:ionicons/ionicons.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jomjalan/main.dart';
import 'package:jomjalan/screens/home_page.dart';
import 'package:jomjalan/services/mock_api_service.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _mapController;
  LatLng _currentLocation = const LatLng(
    3.2512,
    101.7383,
  ); // Default: Gombak/Kuala Lumpur
  Set<Marker> _markers = {};
  String? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();

  final MockApiService _apiService = MockApiService();

  // --- NEW: This holds the data for the bottom card ---
  Map<String, dynamic>? _selectedPlace;
  // --------------------------------------------------

  // --- NEW: Define all your categories here ---
  final Map<String, Map<String, dynamic>> _categories = {
    'restaurants': {
      'label': 'Restaurants',
      'icon': Ionicons.fast_food_outline,
      'type': 'restaurant',
    },
    'hotels': {
      'label': 'Hotels',
      'icon': Ionicons.bed_outline,
      'type': 'lodging',
    },
    'attractions': {
      'label': 'Attractions',
      'icon': Ionicons.eye_outline,
      'type': 'tourist_attraction',
    },
    'museums': {
      'label': 'Museums',
      'icon': Ionicons.library_outline,
      'type': 'museum',
    },
    'cafes': {'label': 'Cafes', 'icon': Ionicons.cafe_outline, 'type': 'cafe'},
    'transits': {
      'label': 'Transits',
      'icon': Ionicons.train_outline,
      'type': 'transit_station',
    },
    'pharmacies': {
      'label': 'Pharmacies',
      'icon': Ionicons.medkit_outline,
      'type': 'pharmacy',
    },
    'atms': {'label': 'ATMs', 'icon': Ionicons.card_outline, 'type': 'atm'},
    'petrol': {
      'label': 'Petrol',
      'icon': Ionicons.car_sport_outline,
      'type': 'gas_station',
    },
  };
  // ------------------------------------------

  static const String _darkMapStyle = '''[
    {"elementType":"geometry","stylers":[{"color":"#0f2027"}]},
    {"elementType":"labels.text.fill","stylers":[{"color":"#b2dfdb"}]},
    {"elementType":"labels.text.stroke","stylers":[{"color":"#0f2027"}]},
    {"featureType":"administrative","elementType":"geometry","stylers":[{"color":"#004d40"}]},
    {"featureType":"poi","elementType":"geometry","stylers":[{"color":"#004d40"}]},
    {"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#1b5e20"}]},
    {"featureType":"road","elementType":"geometry.fill","stylers":[{"color":"#004d40"}]},
    {"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#00251a"}]},
    {"featureType":"road.highway","elementType":"geometry.fill","stylers":[{"color":"#00796b"}]},
    {"featureType":"water","elementType":"geometry","stylers":[{"color":"#001f24"}]},
    {"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#4db6ac"}]}
  ]''';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _mapController?.setMapStyle(_darkMapStyle);
  }

  // --- THIS FUNCTION IS NOW FIXED ---
  Future<void> _searchPlace() async {
    final query = _searchController.text;
    if (query.isEmpty) return;

    try {
      // 1. Call your API Service, which calls your Flask server
      final result = await _apiService.findPlace(query);

      // 2. Check if the server found a place
      if (result['status'] == 'OK' && result['location'] != null) {
        final loc = result['location'];
        final pos = LatLng(loc['lat'], loc['lng']);

        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(CameraPosition(target: pos, zoom: 14)),
        );
        setState(() {
          // 3. Update the app's "current location" to the new place
          _currentLocation = pos;
          _markers.clear();
          _selectedCategory = null;
          _selectedPlace = null; // Close info card
          // Add a single marker for the searched place
          _markers.add(
            Marker(
              markerId: MarkerId(query),
              position: pos,
              // --- NO InfoWindow, use onTap instead ---
              // infoWindow: InfoWindow(title: query),
              onTap: () {
                // Show a simple card for the searched place
                setState(() {
                  _selectedPlace = {
                    "name": query,
                    "vicinity": "Searched Location",
                    "rating": 0.0,
                    "user_ratings_total": 0,
                    "imageUrl":
                        "https://placehold.co/400x400/0f2027/b2dfdb?text=${query.replaceAll(' ', '+')}",
                  };
                });
              },
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen,
              ),
            ),
          );
        });
      } else {
        print("findPlace API error: ${result['status']}");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Could not find '$query'.")));
      }
    } catch (e) {
      print("Search error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error searching: ${e.toString()}")),
      );
    }
  }

  Future<void> _findNearby(String categoryType) async {
    if (_selectedCategory == categoryType) {
      setState(() {
        _markers.clear();
        _selectedCategory = null;
        _selectedPlace = null; // Close info card
      });
      return;
    }

    setState(() {
      _markers.clear();
      _selectedCategory = categoryType;
      _selectedPlace = null; // Close info card
    });

    try {
      // This is correct: it uses the (now updated) _currentLocation
      final results = await _apiService.getNearbyPlaces(
        _currentLocation,
        categoryType,
      );

      if (results.isNotEmpty) {
        Set<Marker> newMarkers =
            results.map((place) {
              final lat = place['lat'];
              final lng = place['lng'];
              final name = place['name'];
              // This 'place' map is the full JSON object from your server
              // We will pass this whole object to our _selectedPlace variable

              return Marker(
                markerId: MarkerId(name),
                position: LatLng(lat, lng),
                // --- REMOVED InfoWindow ---
                // We now use onTap to show our custom card
                onTap: () {
                  setState(() {
                    _selectedPlace = place;
                  });
                },
                icon: _getMarkerColor(categoryType), // Uses the helper function
              );
            }).toSet();

        setState(() {
          _markers = newMarkers;
        });
      } else {
        print('Places API returned no results for $categoryType.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No nearby ${categoryType}s found.")),
        );
      }
    } catch (e) {
      print('Error fetching nearby places: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    // This page is now just the body content for the main nav screen.
    return Stack(
      children: [
        GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _currentLocation,
            zoom: 13,
          ),
          markers: _markers,
          myLocationEnabled: true,
          zoomControlsEnabled: false,
          myLocationButtonEnabled: true,
          padding: const EdgeInsets.only(bottom: 50.0),
          // --- NEW: Close card when map is tapped ---
          onTap: (LatLng) {
            setState(() {
              _selectedPlace = null;
            });
          },
          // ----------------------------------------
        ),

        // Search Bar
        Positioned(
          top: MediaQuery.of(context).padding.top + 16.0,
          left: 16,
          right: 16,
          child: Container(
            decoration: BoxDecoration(
              color: secondaryBackgroundColor.withOpacity(0.95),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 8),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: textColor),
                    decoration: const InputDecoration(
                      hintText: "Search a place...",
                      hintStyle: TextStyle(color: Colors.grey),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _searchPlace(),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Ionicons.search_outline,
                    color: primaryGreen,
                  ),
                  onPressed: _searchPlace,
                ),
              ],
            ),
          ),
        ),

        // Category Chips
        Positioned(
          top: MediaQuery.of(context).padding.top + 80,
          left: 0,
          right: 0,
          child: SizedBox(
            height: 50, // Set a fixed height
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children:
                  _categories.entries.map((entry) {
                    final categoryKey = entry.key; // e.g., 'restaurants'
                    final details =
                        entry.value; // The map with label, icon, type
                    return _buildCategoryChip(
                      details['label'],
                      details['icon'],
                      details['type'], // Pass the API type (e.g., 'restaurant')
                    );
                  }).toList(),
            ),
          ),
        ),

        // --- NEW: Custom Info Window Card ---
        // This will animate from the bottom
        _buildPlaceDetailsCard(),

        // ------------------------------------
      ],
    );
  }

  // Category Chip Widget
  Widget _buildCategoryChip(String label, IconData icon, String categoryType) {
    // ... (This function is unchanged) ...
    final bool selected = _selectedCategory == categoryType;
    return GestureDetector(
      onTap: () => _findNearby(categoryType),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color:
              selected
                  ? primaryGreen
                  : secondaryBackgroundColor.withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? Colors.white : primaryGreen, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to get marker colors
  BitmapDescriptor _getMarkerColor(String categoryType) {
    switch (categoryType) {
      case 'cafe':
      case 'restaurant':
        return BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueViolet,
        );
      case 'lodging':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
      case 'tourist_attraction':
      case 'museum':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan);
      case 'transit_station':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose);
      case 'pharmacy':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      case 'atm':
      case 'gas_station':
        return BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueMagenta,
        );
      default:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    }
  }

  Widget _buildPlaceDetailsCard() {
    // This positions the card at the bottom of the screen.
    // It will be off-screen if _selectedPlace is null.
    return AnimatedPositioned(
      bottom: _selectedPlace == null ? -150 : 60, // 60 to be above nav bar
      left: 16,
      right: 16,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Material(
        color: Colors.transparent, // Let the Container handle color
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: secondaryBackgroundColor, // Your dark bg color
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10),
            ],
          ),
          child: Row(
            children: [
              // 1. Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  _selectedPlace?['imageUrl'] ?? 'https://placehold.co/100',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  // Add a loading builder
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      width: 100,
                      height: 100,
                      color: backgroundColor,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),

              // 2. Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      _selectedPlace?['name'] ?? 'Loading...',
                      style: const TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Rating
                    Row(
                      children: [
                        Text(
                          // Format rating to 1 decimal place
                          (_selectedPlace?['rating'] ?? 0.0).toStringAsFixed(1),
                          style: const TextStyle(
                            color: subTextColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Ionicons.star,
                          color: Colors.yellow,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "(${_selectedPlace?['user_ratings_total'] ?? 0})",
                          style: const TextStyle(color: subTextColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Vicinity (Address)
                    Text(
                      _selectedPlace?['vicinity'] ?? '...',
                      style: const TextStyle(color: subTextColor, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // 3. Close Button
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Ionicons.close_circle, color: Colors.grey),
                  onPressed: () {
                    setState(() {
                      _selectedPlace = null;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
