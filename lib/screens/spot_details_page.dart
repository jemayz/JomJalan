import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:jomjalan/main.dart'; // For colors
import 'package:jomjalan/models/spot_model.dart';
import 'package:jomjalan/providers/itinerary_provider.dart';
import 'package:provider/provider.dart';

class SpotDetailsPage extends StatelessWidget {
  final Spot spot;
  const SpotDetailsPage({Key? key, required this.spot}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Watch the provider to see if this spot is already in the itinerary
    final bool isInItinerary = context
        .watch<ItineraryProvider>()
        .isSpotInItinerary(spot);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // The default back button is fine
      ),
      extendBodyBehindAppBar: true, // Make body go behind appbar
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Image Header ---
            Stack(
              children: [
                Image.network(
                  spot.imageUrl,
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                // Gradient overlay for text
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
                // Title
                Positioned(
                  bottom: 5,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        maxLines: 2,
                        spot.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        maxLines: 2,
                        spot.location,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // --- Content Body ---
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "About this place",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    spot.description,
                    style: const TextStyle(
                      fontSize: 15,
                      color: subTextColor,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // --- Floating "Add to Itinerary" Button ---
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ElevatedButton.icon(
          icon: Icon(
            color: textColor,
            isInItinerary ? Ionicons.checkmark_circle : Ionicons.add,
          ),
          label: Text(
            isInItinerary ? 'Added to Itinerary' : 'Add to Itinerary',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: isInItinerary ? Colors.grey : primaryGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed:
              isInItinerary
                  ? null // Disable button if already added
                  : () {
                    // Use `context.read` to call the add function
                    context.read<ItineraryProvider>().addSpot(spot);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${spot.name} added!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
        ),
      ),
    );
  }
}
