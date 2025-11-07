import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
// ignore: unused_import
import 'package:jomjalan/main.dart';
import 'package:jomjalan/models/spot_model.dart';
import 'package:jomjalan/screens/ai_planner_page.dart';
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
  void _goToAiPlanner() {
    // This is tricky navigation. We need to tell the MainNavScreen
    // to change tabs. This requires a more complex state setup.
    // For a prototype, a simpler way is to just navigate to the page directly.
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AiPlannerPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 1.0,
        automaticallyImplyLeading: false,
        title: Text(
          "JomJalan",
          style: TextStyle(
            color: Colors.white, // Use your main green color
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
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
          // AI Planner Card
          GestureDetector(onTap: _goToAiPlanner, child: const LocationCard()),
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
