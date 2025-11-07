import 'package:flutter/material.dart';
import 'package:jomjalan/main.dart'; // For colors
import 'package:jomjalan/models/spot_model.dart';

class SpotCard extends StatelessWidget {
  final Spot spot;

  const SpotCard({Key? key, required this.spot}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200, // Fixed width for horizontal list
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              spot.imageUrl,
              height: 180,
              width: 200,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 12),
          // Title
          Text(
            spot.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: textColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Subtitle
          Text(
            spot.location,
            style: const TextStyle(fontSize: 14, color: subTextColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
