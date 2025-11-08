import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:google_fonts/google_fonts.dart';
// ignore: unused_import
import 'package:jomjalan/main.dart';
import 'package:jomjalan/models/spot_model.dart';
import 'package:jomjalan/screens/map_page.dart';
import 'package:jomjalan/screens/spot_details_page.dart';
import 'package:jomjalan/services/api_service.dart';
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
  late Future<List<Spot>> _trendingSpots;
  late Future<List<Spot>> _nearbySpots;

  @override
  void initState() {
    super.initState();
    // "Fetch" the data when the page loads
    _trendingSpots = _apiService.getTrendingSpots();
    _nearbySpots = _apiService.getNearbySpots();
  }

  // Function to navigate to a Spot's Details
  void _goToSpotDetails(Spot spot) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SpotDetailsPage(spot: spot)),
    );
  }

  // Function to navigate to the AI Planner tab
  void _goToMapPage() {
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
          // This tells the Row to only be as wide as its children
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
          GestureDetector(onTap: _goToMapPage, child: const LocationCard()),
          const SizedBox(height: 24),

          // Trending Spots Section
          SectionHeader(
            title: "Trending on Social Media",
            onViewAll: () {
              /* TODO: View All Page */
            },
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<Spot>>(
            future: _trendingSpots,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();
              final spots = snapshot.data!;
              return SizedBox(
                height: 260,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: spots.length,
                  itemBuilder: (context, index) {
                    final spot = spots[index];
                    return GestureDetector(
                      onTap: () => _goToSpotDetails(spot),
                      child: SpotCard(spot: spot),
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Nearby Spots Section
          SectionHeader(
            title: "Nearby You",
            onViewAll: () {
              /* TODO: View All Page */
            },
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<Spot>>(
            future: _nearbySpots,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();
              final spots = snapshot.data!;
              return SizedBox(
                height: 260,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: spots.length,
                  itemBuilder: (context, index) {
                    final spot = spots[index];
                    return GestureDetector(
                      onTap: () => _goToSpotDetails(spot),
                      child: SpotCard(spot: spot),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
