import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:jomjalan/main.dart'; // No longer needed
import 'package:jomjalan/models/spot_model.dart';
import 'package:jomjalan/screens/map_page.dart';
import 'package:jomjalan/screens/spot_details_page.dart';
import 'package:jomjalan/services/mock_api_service.dart';
import 'package:jomjalan/main.dart'; // Import theme
import 'package:jomjalan/widgets/location_card.dart';
import 'package:jomjalan/widgets/section_header.dart';
import 'package:jomjalan/widgets/spot_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MockApiService _apiService = MockApiService();

  // --- NEW STATE MANAGEMENT ---
  late Future<List<Spot>> _trendingSpotsFuture;

  // List of Malaysian states for the dropdown
  final List<String> _malaysianStates = [
    'Kuala Lumpur',
    'Selangor',
    'Perak',
    'Penang',
    'Johor',
    'Sabah',
    'Sarawak',
    'Melaka',
    'Negeri Sembilan',
    'Kedah',
    'Pahang',
    'Terengganu',
    'Kelantan',
    'Perlis',
  ];
  String _selectedState = 'Kuala Lumpur'; // Default state
  // ----------------------------

  @override
  void initState() {
    super.initState();
    // --- THIS IS THE FIX ---
    // Initialize the future directly, without calling setState.
    // The FutureBuilder will handle the first build.
    _trendingSpotsFuture = _apiService.getTrendingSpots(_selectedState);
    // --------------------
  }

  // --- THIS FUNCTION IS NOW UPDATED ---
  /// Fetches spots from the API and updates the future
  void _loadTrendingSpots(String state) {
    setState(() {
      // This is correct. When the state changes (from the dropdown),
      // we assign a *new* future and call setState to rebuild.
      _selectedState = state; // <-- Don't forget to update the selected state
      _trendingSpotsFuture = _apiService.getTrendingSpots(state);
    });
  }
  // ------------------------------------

  // Function to navigate to a Spot's Details
  void _goToSpotDetails(Spot spot) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SpotDetailsPage(spot: spot)),
    );
  }

  // Function to navigate to the AI Planner tab
  void _goToMapPage() {
    // This is not the AI planner, it's the Map Page.
    // The best way to navigate is to tell the MainNavScreen to change tabs.
    // We'll use your existing (simpler) navigation for now.
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 1.0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Jom",
              style: GoogleFonts.pacifico(
                color: textColor, // Your accent color
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            Text(
              "J",
              style: GoogleFonts.pacifico(
                color: accentColor, // Your main text color
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            Text(
              "alan",
              style: GoogleFonts.pacifico(
                color: textColor, // Your main text color
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Ionicons.notifications_outline,
              color: textColor, // Use a neutral text color
            ),
            onPressed: () {
              /* TODO: Implement notifications */
            },
          ),
          const SizedBox(width: 8), // Add some padding to the edge
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          // --- REMOVED Search Bar ---
          // GestureDetector(onTap: _goToMapPage, child: const LocationCard()),
          // const SizedBox(height: 24),

          // --- NEW: State Selection Dropdown ---
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: DropdownButtonFormField<String>(
              value: _selectedState,
              decoration: InputDecoration(
                filled: true,
                fillColor: secondaryBackgroundColor,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                prefixIcon: const Icon(
                  Ionicons.map_outline,
                  color: primaryGreen,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: textColor, fontSize: 16),
              dropdownColor: secondaryBackgroundColor,
              iconEnabledColor: primaryGreen,
              items:
                  _malaysianStates.map((String state) {
                    return DropdownMenuItem<String>(
                      value: state,
                      child: Text(state),
                    );
                  }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  // When the state changes, re-load the spots
                  _loadTrendingSpots(newValue);
                }
              },
            ),
          ),
          // ------------------------------------

          // Trending Spots Section
          SectionHeader(
            title: "Trending in $_selectedState", // Title is now dynamic
            onViewAll: () {
              /* TODO: View All Page */
            },
          ),
          const SizedBox(height: 12),

          // --- UPDATED FutureBuilder ---
          FutureBuilder<List<Spot>>(
            future: _trendingSpotsFuture, // Use the new future
            builder: (context, snapshot) {
              // Handle loading state
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              // Handle error state
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Error: ${snapshot.error}",
                    style: const TextStyle(color: subTextColor),
                  ),
                );
              }
              // Handle empty or no data
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    "No trending spots found.",
                    style: const TextStyle(color: subTextColor),
                  ),
                );
              }

              // Success state
              final spots = snapshot.data!;
              return ListView.builder(
                shrinkWrap: true, // <-- ADDED
                physics: const NeverScrollableScrollPhysics(), // <-- ADDED
                // scrollDirection: Axis.horizontal, // <-- REMOVED
                itemCount: spots.length,
                itemBuilder: (context, index) {
                  final spot = spots[index];
                  // Add padding between the vertical cards
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0), // <-- ADDED
                    child: GestureDetector(
                      onTap: () => _goToSpotDetails(spot),
                      child: SpotCard(spot: spot),
                    ),
                  );
                },
              );
            },
          ),

          // ------------------------------------
          const SizedBox(height: 24),

          // --- REMOVED Nearby Places section ---
          // This page is now focused on "Trending"
        ],
      ),
    );
  }
}
