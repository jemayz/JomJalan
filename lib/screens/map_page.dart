import 'dart:math'; // Used for dummy marker locations
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:ionicons/ionicons.dart';
import 'package:jomjalan/main.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();

  // --- NEW ---
  // This set will hold all the pins (Markers) on the map
  final Set<Marker> _markers = {};
  String? _selectedCategory;
  LatLng _currentLocation = const LatLng(3.1390, 101.6869); // Default to KL

  // Start the camera in Kuala Lumpur
  static const CameraPosition _kualaLumpur = CameraPosition(
    target: LatLng(3.1390, 101.6869),
    zoom: 12,
  );

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    print("Map controller created. Custom style will be applied by Map ID.");
  }

  Future<void> _searchAndMoveCamera() async {
    String address = _searchController.text;
    if (address.isEmpty || _mapController == null) {
      return;
    }
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        Location location = locations.first;
        _currentLocation = LatLng(location.latitude, location.longitude);
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: _currentLocation, zoom: 15),
          ),
        );
        // After searching, clear the markers
        _findNearby(null);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Location not found.")));
      }
    } catch (e) {
      print("Error searching location: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }

  // --- NEW FUNCTION ---
  /// Simulates finding nearby places and adds dummy markers to the map
  void _findNearby(String? category) {
    // If the user taps the same category, deselect it
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

      if (category == null) return;

      // Create dummy markers around the _currentLocation
      // In a real app, this data would come from the Google Places API
      Map<String, List<Map<String, dynamic>>> dummyData = {
        'cafe': [
          {'name': 'VCR Cafe', 'lat': 0.005, 'lng': -0.005},
          {'name': 'PULP by Papa Palheta', 'lat': -0.002, 'lng': 0.003},
        ],
        'restaurants': [
          {'name': 'Din Tai Fung', 'lat': 0.004, 'lng': 0.001},
          {'name': 'Marini\'s on 57', 'lat': 0.001, 'lng': -0.001},
        ],
        'attractions': [
          {'name': 'Petronas Twin Towers', 'lat': 0.01, 'lng': 0.01},
          {'name': 'Batu Caves', 'lat': 0.1, 'lng': -0.05},
        ],
        'hotels': [
          {'name': 'Mandarin Oriental', 'lat': 0.011, 'lng': 0.009},
          {'name': 'Traders Hotel', 'lat': 0.009, 'lng': 0.011},
        ],
        'activities': [
          {'name': 'KL Bird Park', 'lat': -0.01, 'lng': -0.02},
          {'name': 'Aquaria KLCC', 'lat': 0.01, 'lng': 0.012},
        ],
      };

      if (dummyData.containsKey(category)) {
        for (var place in dummyData[category]!) {
          _markers.add(
            Marker(
              markerId: MarkerId(place['name']),
              position: LatLng(
                _currentLocation.latitude + place['lat'],
                _currentLocation.longitude + place['lng'],
              ),
              infoWindow: InfoWindow(title: place['name']),
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // The Google Map
          GoogleMap(
            initialCameraPosition: _kualaLumpur,
            onMapCreated: _onMapCreated,
            myLocationEnabled: true,
            myLocationButtonEnabled: false, // We'll add our own
            markers: _markers, // <-- Display the markers
          ),

          // The Search Bar UI
          Positioned(
            top: 50.0,
            left: 15.0,
            right: 15.0,
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor, // Use dark background
                borderRadius: BorderRadius.circular(30.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Ionicons.arrow_back, color: textColor),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: textColor),
                      decoration: const InputDecoration(
                        hintText: "Search for a location...",
                        hintStyle: TextStyle(color: subTextColor),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(
                          left: 10,
                          right: 10,
                          bottom: 5,
                        ),
                      ),
                      onSubmitted: (_) => _searchAndMoveCamera(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Ionicons.search, color: primaryGreen),
                    onPressed: _searchAndMoveCamera,
                  ),
                ],
              ),
            ),
          ),

          // --- NEW: Category Buttons ---
          Positioned(
            top: 110.0, // Place it below the search bar
            left: 0,
            right: 0,
            child: _buildCategoryChips(),
          ),
        ],
      ),
    );
  }

  // --- NEW WIDGET ---
  /// Builds the horizontal scrolling list of category chips
  Widget _buildCategoryChips() {
    return Container(
      height: 50,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Row(
          children: [
            _buildCategoryChip(
              "Attractions",
              Ionicons.eye_outline,
              'attractions',
            ),
            _buildCategoryChip("Hotels", Ionicons.bed_outline, 'hotels'),
            _buildCategoryChip(
              "Activities",
              Ionicons.walk_outline,
              'activities',
            ),
            _buildCategoryChip("Cafe", Ionicons.cafe_outline, 'cafe'),
            _buildCategoryChip(
              "Restaurants",
              Ionicons.restaurant_outline,
              'restaurants',
            ),
          ],
        ),
      ),
    );
  }

  // --- NEW WIDGET ---
  /// Helper to build a single category chip
  Widget _buildCategoryChip(String label, IconData icon, String categoryKey) {
    bool isSelected = _selectedCategory == categoryKey;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ActionChip(
        avatar: Icon(
          icon,
          color: isSelected ? Colors.white : primaryGreen,
          size: 18,
        ),
        label: Text(
          label,
          style: TextStyle(color: isSelected ? Colors.white : textColor),
        ),
        backgroundColor: isSelected ? primaryGreen : secondaryBackgroundColor,
        onPressed: () => _findNearby(categoryKey),
      ),
    );
  }
}
