import 'package:flutter/material.dart';
// import 'package:jomjalan/main.dart'; // No longer needed
import 'package:jomjalan/models/spot_model.dart';
import 'package:jomjalan/main.dart'; // Import theme
import 'package:ionicons/ionicons.dart';

class SpotCard extends StatelessWidget {
  final Spot spot;

  const SpotCard({Key? key, required this.spot}) : super(key: key);

  // --- NEW HELPER WIDGET ---
  /// Builds the price level (e.g., $$, $$$)
  Widget _buildPriceLevel(int level) {
    // ... (this function is unchanged) ...
    List<Widget> icons = [];
    for (int i = 0; i < level; i++) {
      icons.add(
        Text(
          '\$',
          style: TextStyle(
            color: primaryGreen,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      );
    }
    // If free, show "Free"
    if (level == 0) {
      return Text(
        "Free",
        style: TextStyle(
          color: primaryGreen,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      );
    }
    return Row(children: icons);
  }
  // -------------------------

  @override
  Widget build(BuildContext context) {
    return Container(
      // width: 200, // <-- REMOVED fixed width
      // margin: const EdgeInsets.only(right: 16), // <-- REMOVED right margin
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              spot.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,

              // 1. Show a loading spinner while fetching
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  height: 200,
                  width: double.infinity,
                  color: secondaryBackgroundColor,
                  child: const Center(child: CircularProgressIndicator()),
                );
              },

              // 2. CRITICAL: Handle errors and print them
              errorBuilder: (context, error, stackTrace) {
                print(
                  "IMAGE ERROR for ${spot.name}: $error",
                ); // Check your terminal for this!
                return Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Ionicons.image_outline,
                        size: 40,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Failed to load",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          // Title
          Text(
            // ... (rest of the widget is unchanged) ...
            spot.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: textColor,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),

          // --- NEW: Rating and Price Row ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Rating
              Row(
                children: [
                  Icon(Ionicons.star, color: Colors.yellow, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    "${spot.rating?.toStringAsFixed(1) ?? 'N/A'} (${spot.userRatingsTotal ?? 0})",
                    style: const TextStyle(fontSize: 14, color: subTextColor),
                  ),
                ],
              ),
              // Price (if it exists)
              if (spot.priceLevel != null) _buildPriceLevel(spot.priceLevel!),
            ],
          ),

          // --------------------------------
          const SizedBox(height: 4),
          // Subtitle (Location)
          Text(
            spot.location,
            style: const TextStyle(fontSize: 14, color: subTextColor),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
