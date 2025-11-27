import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

// Defines the data structure for a travel "spot"
class Spot {
  final String id;
  final String name;
  final String location;
  final String description;
  final String imageUrl;

  // --- NEW FIELDS ---
  final double? rating;
  final int? userRatingsTotal;
  final int? priceLevel; // Google returns this as a number (0-4)
  // ------------------

  Spot({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.imageUrl,
    // --- ADD TO CONSTRUCTOR ---
    this.rating,
    this.userRatingsTotal,
    this.priceLevel,
    // ------------------------
  });

  // --- UPDATED 'fromJson' FACTORY ---
  factory Spot.fromJson(Map<String, dynamic> json) {
    return Spot(
      id: json['id'] ?? 'default_id',
      name: json['name'] ?? 'No Name',
      location: json['location'] ?? 'No Location',
      description: json['description'] ?? 'No Description',
      imageUrl: json['imageUrl'] ?? 'https://placehold.co/600x400',

      // --- PARSE NEW FIELDS ---
      // Use 'tryParse' to be safe
      rating: (json['rating'] as num?)?.toDouble(),
      userRatingsTotal: (json['user_ratings_total'] as num?)?.toInt(),
      priceLevel: (json['priceLevel'] as num?)?.toInt(),
      // ------------------------
    );
  }
  // ----------------------------------------
}

// Defines the data structure for a gamification "challenge"
// (I added IoniconData to match the mock service)
class Challenge {
  // ... (rest of this class is unchanged) ...
  final String id;
  final String title;
  final String description;
  final int points;
  final IconData icon;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.icon,
  });
}
