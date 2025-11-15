import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // <-- Import LatLng
import 'package:ionicons/ionicons.dart';
import 'package:jomjalan/models/spot_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// --- THIS IS YOUR REAL FLASK BACKEND URL ---
// 127.0.0.1 is 'localhost' on your computer.
// For Android Emulators, you must use 10.0.2.2 instead.
const String API_BASE_URL = "http://10.0.2.2:5000";

class MockApiService {
  Future<List<Spot>> getTrendingSpots(String state) async {
    print("API Service: Fetching trending spots for $state...");

    // --- THIS IS THE FIX ---
    // We must add the 'state' as a query parameter to the URL
    final uri = Uri.parse(
      '$API_BASE_URL/api/trending_spots?state=${Uri.encodeComponent(state)}',
    );
    // -----------------------

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Spot.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load spots from backend.");
      }
    } catch (e) {
      print("Error in getTrendingSpots: $e");
      throw Exception("Connection Error: Is the backend server running?");
    }
  }

  /// Calls your backend to find a place from a text query (e.g., "Taiping")
  Future<Map<String, dynamic>> findPlace(String query) async {
    final uri = Uri.parse(
      '$API_BASE_URL/api/find_place?query=${Uri.encodeComponent(query)}',
    );
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Failed to find place: ${response.body}");
      }
    } catch (e) {
      print("Error in findPlace: $e");
      rethrow;
    }
  }

  // --- NEW FUNCTION TO CALL YOUR BACKEND FOR PLACES ---
  Future<List<dynamic>> getNearbyPlaces(
    LatLng location,
    String category,
  ) async {
    // 1. Build the URL to call our Flask server
    final url = Uri.parse(
      '$API_BASE_URL/api/nearby_places?lat=${location.latitude}&lng=${location.longitude}&category=$category',
    );

    try {
      // 2. Make the API call
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // 3. Parse the JSON response
        return json.decode(response.body);
      } else {
        throw Exception("Failed to load places: ${response.body}");
      }
    } catch (e) {
      print("Error finding nearby places: $e");
      rethrow;
    }
  }
  // --------------------------------------------------

  // Simulates fetching challenges
  Future<List<Challenge>> getChallenges() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      Challenge(
        id: 'c1',
        title: "Foodie First-timer",
        description: "Add your first spot to an itinerary",
        points: 10,
        icon: Ionicons.restaurant_outline,
      ),
      Challenge(
        id: 'c2',
        title: "AI Explorer",
        description: "Generate a plan with the AI Assistant",
        points: 20,
        icon: Ionicons.sparkles_outline,
      ),
    ];
  }

  // Simulates a call to your AI Planner
  Future<String> getAiPlan(String userPrompt) async {
    final uri = Uri.parse('$API_BASE_URL/api/ai_planner');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'prompt': userPrompt}),
      );

      if (response.statusCode == 200) {
        // --- THIS IS THE FIX ---
        // Return the raw JSON string directly.
        // The AI Planner page will decode it.
        return response.body;
        // -----------------------
      } else {
        return "{\"friendly_response\": \"Sorry, the AI planner seems to be offline.\" }";
      }
    } catch (e) {
      print("Error in getAiPlan: $e");
      return "{\"friendly_response\": \"Error connecting to the AI planner. Is the server running?\" }";
    }
  }
}
