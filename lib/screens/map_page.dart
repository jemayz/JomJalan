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
  ); // Default: Kuala Lumpur
  Set<Marker> _markers = {};
  String? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();

  // --- ADDED ---
  // Create an instance of your API service
  final MockApiService _apiService = MockApiService();
  // -----------

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

  Future<void> _searchPlace() async {
    final query = _searchController.text;
    if (query.isEmpty) return;

    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        final pos = LatLng(loc.latitude, loc.longitude);
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(CameraPosition(target: pos, zoom: 14)),
        );
        setState(() {
          _currentLocation = pos;
          _markers.clear();
          _selectedCategory = null;
          _markers.add(
            Marker(
              markerId: MarkerId(query),
              position: pos,
              infoWindow: InfoWindow(title: query),
            ),
          );
        });
      }
    } catch (e) {
      print("Search error: $e");
    }
  }

  // --- THIS FUNCTION IS NOW MODIFIED ---
  Future<void> _findNearby(String category) async {
    if (_selectedCategory == category) {
      setState(() {
        _markers.clear();
        _selectedCategory = null;
      });
      return;
    }

    setState(() {
      _markers.clear();
      _selectedCategory = category;
    });

    // The Google API key is no longer needed here.
    // It's safely on your server.

    final Map<String, String> categoryTypes = {
      'cafe': 'cafe',
      'restaurants': 'restaurant',
      'hotels': 'lodging',
      'attractions': 'tourist_attraction',
      'activities': 'point_of_interest',
    };

    final type = categoryTypes[category] ?? 'point_of_interest';

    try {
      // --- THIS IS THE FIX ---
      // Call your API Service instead of calling Google directly
      final results = await _apiService.getNearbyPlaces(_currentLocation, type);
      // -----------------------

      if (results.isNotEmpty) {
        Set<Marker> newMarkers =
            results.map((place) {
              final lat = place['lat'];
              final lng = place['lng'];
              final name = place['name'];

              return Marker(
                markerId: MarkerId(name),
                position: LatLng(lat, lng),
                infoWindow: InfoWindow(title: name),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueGreen, // Use JomJalan's green
                ),
              );
            }).toSet();

        setState(() {
          _markers = newMarkers;
        });
      } else {
        print('Places API returned no results.');
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
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
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
            ),

            // Search Bar
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: secondaryBackgroundColor.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: textColor), // White text
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
              top: 80, // Positioned below the search bar
              left: 0,
              right: 0,
              child: SizedBox(
                height: 50, // Set a fixed height
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildCategoryChip("Cafes", Ionicons.cafe_outline, "cafe"),
                    _buildCategoryChip(
                      "Hotels",
                      Ionicons.bed_outline,
                      "hotels",
                    ),
                    _buildCategoryChip(
                      "Restaurants",
                      Ionicons.fast_food_outline,
                      "restaurants",
                    ),
                    _buildCategoryChip(
                      "Attractions",
                      Ionicons.map_outline,
                      "attractions",
                    ),
                    _buildCategoryChip(
                      "Activities",
                      Ionicons.walk_outline,
                      "activities",
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Category Chip Widget
  Widget _buildCategoryChip(String label, IconData icon, String category) {
    final bool selected = _selectedCategory == category;
    return GestureDetector(
      onTap: () => _findNearby(category),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          // Use PrimaryGreen when selected, and dark bg color when not
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
            Icon(
              icon,
              // Use white for selected icon, and green for unselected
              color: selected ? Colors.white : primaryGreen,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                // Text is always white, as requested
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
