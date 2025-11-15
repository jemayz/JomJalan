import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:jomjalan/main.dart'; // For colors
import 'package:jomjalan/models/spot_model.dart'; // <-- IMPORT Spot model
import 'package:jomjalan/providers/itinerary_provider.dart';
import 'package:provider/provider.dart';

class ItineraryPage extends StatelessWidget {
  const ItineraryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Watch for changes in the ItineraryProvider
    final itinerary = context.watch<ItineraryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Itinerary',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body:
          itinerary.spots.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Ionicons.map_outline, size: 80, color: subTextColor),
                    SizedBox(height: 16),
                    Text(
                      'Your itinerary is empty.',
                      style: TextStyle(fontSize: 18, color: subTextColor),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Add spots from the Home page!',
                      style: TextStyle(fontSize: 16, color: subTextColor),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: itinerary.spots.length,
                itemBuilder: (context, index) {
                  final spot = itinerary.spots[index];
                  // --- FIX: Replace ListTile with our new custom card ---
                  return _ItinerarySpotCard(spot: spot);
                  // --------------------------------------------------
                },
              ),
    );
  }
}

// --- NEW WIDGET ---
/// A custom card that displays the spot image on top and text below.
class _ItinerarySpotCard extends StatelessWidget {
  final Spot spot;

  const _ItinerarySpotCard({Key? key, required this.spot}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: secondaryBackgroundColor,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16), // Spacing between cards
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior:
          Clip.antiAlias, // Ensures the image clips to the rounded corners
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Image
          Image.network(
            spot.imageUrl,
            width: double.infinity,
            height: 150, // Give the image a good height
            fit: BoxFit.cover,
            // --- FIX: Add an errorBuilder ---
            // This shows a placeholder icon if the image URL is invalid
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 150,
                width: double.infinity,
                color: backgroundColor, // Your app's main background color
                child: const Icon(
                  Ionicons.image_outline,
                  color: subTextColor,
                  size: 50,
                ),
              );
            },
          ),

          // 2. Text Content (Name and Location)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        spot.name,
                        style: const TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        spot.location,
                        style: const TextStyle(
                          color: subTextColor,
                          fontSize: 14,
                        ),
                        maxLines: 3, // Allow location text to wrap
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // 3. Remove Button
                IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: () {
                    // Remove the spot from the itinerary
                    context.read<ItineraryProvider>().removeSpot(spot);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
