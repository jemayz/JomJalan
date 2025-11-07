import 'package:flutter/material.dart';

// Defines the data structure for a travel "spot"
class Spot {
  final String id;
  final String name;
  final String location;
  final String description;
  final String imageUrl;

  // This is your original constructor
  Spot({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.imageUrl,
  });

  // --- ADD THIS NEW FACTORY CONSTRUCTOR ---
  // This "factory" is a translator that builds a Spot object from a JSON map.
  // It matches the keys from your Python scraper ('id', 'name', 'location', etc.)
  // to the variables in your Spot class.
  factory Spot.fromJson(Map<String, dynamic> json) {
    return Spot(
      id: json['id'] ?? 'default_id', // Use ?? for safety
      name: json['name'] ?? 'No Name',
      location: json['location'] ?? 'No Location',
      description: json['description'] ?? 'No Description',
      imageUrl: json['imageUrl'] ?? 'https://placehold.co/600x400',
    );
  }
  // ----------------------------------------
}

// Defines the data structure for a gamification "challenge"
// (I added IoniconData to match the mock service)
class Challenge {
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
