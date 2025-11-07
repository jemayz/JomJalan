import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:jomjalan/main.dart'; // Import the app's colors

class LocationCard extends StatelessWidget {
  const LocationCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: secondaryBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 49, 49, 49).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Small map icon on the left
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor, // Use the light green accent
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Ionicons.location_outline,
              color: Colors.white, // Use the main green
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          // Column for the text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Your Location",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: textColor, // Use the main text color
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Gombak, KL",
                  style: TextStyle(
                    fontSize: 14,
                    color: subTextColor, // Use the subtext color
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
