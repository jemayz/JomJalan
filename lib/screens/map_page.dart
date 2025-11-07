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

  // Start the camera in Kuala Lumpur
  static const CameraPosition _kualaLumpur = CameraPosition(
    target: LatLng(3.1390, 101.6869),
    zoom: 12,
  );

  // We just save the controller now, no style logic is needed here
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    print("Map controller created. Custom style will be applied by Map ID.");
  }

  // This function searches for the location and moves the camera
  Future<void> _searchAndMoveCamera() async {
    String address = _searchController.text;
    if (address.isEmpty || _mapController == null) {
      return;
    }
    try {
      // Get coordinates from the address
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        Location location = locations.first;
        // Move the camera to the new location
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(location.latitude, location.longitude),
              zoom: 15,
            ),
          ),
        );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // We use a Stack to place the search bar on top of the map
      body: Stack(
        children: [
          // The Google Map
          GoogleMap(
            initialCameraPosition: _kualaLumpur,
            onMapCreated: _onMapCreated,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            // --------------------------
          ),

          // This is the Search Bar UI
          Positioned(
            // Position it 50px from the top
            top: 50.0,
            left: 15.0,
            right: 15.0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Back Button
                  IconButton(
                    icon: const Icon(Ionicons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  // Search Text Field
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: "Search for a location...",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(left: 10),
                      ),
                      // Allow submitting search from the keyboard
                      onSubmitted: (_) => _searchAndMoveCamera(),
                    ),
                  ),
                  // Search Icon Button
                  IconButton(
                    icon: const Icon(Ionicons.search, color: primaryGreen),
                    onPressed: _searchAndMoveCamera,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
