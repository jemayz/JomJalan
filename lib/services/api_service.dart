// ignore: unused_import
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:jomjalan/models/spot_model.dart';

class MockApiService {
  // A list of hardcoded spots (this data would come from your scraper)
  final List<Spot> _trendingSpots = [
    Spot(
      id: '1',
      name: 'Nasi Lemak Burung Hantu',
      location: 'Taman Tun Dr Ismail, KL',
      description:
          'Famous for its crispy fried chicken (Ayam Goreng) and fragrant rice. A must-visit spot that is constantly viral on TikTok and food blogs. Expect long queues during peak hours, but it\'s worth the wait!',
      imageUrl: 'https://cdn.klfoodie.com/2025/06/4-1024x1024.jpg',
    ),
    Spot(
      id: '2',
      name: 'Damascus',
      location: 'Bukit Bintang, KL',
      description:
          'We are a Syrian inspired restaurant loved all over the world. We pride ourselves on offering a diverse range. Our unbeatable grilled pieces complete with delicious options of chicken, lamb, seafood, and shawarma at a price for everyone.',
      imageUrl:
          'https://lh3.googleusercontent.com/p/AF1QipMAOqRDFlE_Rn6DAXRkV0RbzE2YJr19CaMisxPb=w289-h312-n-k-no',
    ),
    Spot(
      id: '3',
      name: 'Aquaria KLCC',
      location: 'KLCC, KL',
      description:
          'Aquaria KLCC is an oceanarium located beneath the Kuala Lumpur Convention Centre. It showcases more than 5,000 exhibits of aquatic and land-bound creatures from Malaysia and around the world.',
      imageUrl: 'https://hotspotpenang.com/wp-content/uploads/2023/07/f5.jpg',
    ),
  ];

  final List<Spot> _nearbySpots = [
    Spot(
      id: '4',
      name: 'Koppiku',
      location: '1.5km away',
      description:
          'A cozy cafe known for its artisanal coffee and delectable pastries. Perfect spot to relax and unwind.',
      imageUrl:
          'https://lh3.googleusercontent.com/p/AF1QipOdJyRF1iS96UYcKDaQDoBKND0UoWp-tKckYUc3=s1360-w1360-h1020-rw',
    ),
    Spot(
      id: '5',
      name: 'Monti Keopi',
      location: '700m away',
      description:
          'A trendy coffee shop offering a variety of brews and a vibrant atmosphere. Great for catching up with friends.',
      imageUrl:
          'https://lh3.googleusercontent.com/gps-cs-s/AG0ilSyzndhp7dz19yCEI5PNFBrvjegU99uUcy_KmpvO7QyEokKN130qiV0fi4GJLYjdyRwPmTxl3cgIG_UBkXyDCAbnO-Cv1C70AJG-arTlaItTsQ3Upmx_KK9vy8OdJUZ_IRYuWVPM=s1360-w1360-h1020-rw',
    ),
  ];

  final List<Challenge> _challenges = [
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
    Challenge(
      id: 'c3',
      title: "Kopi King",
      description: "Visit 3 different cafes",
      points: 50,
      icon: Ionicons.cafe_outline,
    ),
  ];

  // Simulates fetching trending spots
  Future<List<Spot>> getTrendingSpots() async {
    await Future.delayed(const Duration(seconds: 1));
    return _trendingSpots;
  }

  // Simulates fetching nearby spots
  Future<List<Spot>> getNearbySpots() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _nearbySpots;
  }

  // Simulates fetching challenges
  Future<List<Challenge>> getChallenges() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _challenges;
  }

  // Simulates a call to your AI Planner
  Future<String> getAiPlan(String userPrompt) async {
    await Future.delayed(const Duration(seconds: 2));
    if (userPrompt.toLowerCase().contains("penang")) {
      return "Here is your 3-day budget-friendly plan for Penang:\n\n"
          "**Day 1: George Town Heritage**\n"
          "- Morning: Explore the street art\n"
          "- Lunch: Nasi Kandar Line Clear\n"
          "- Evening: Gurney Drive Hawker Centre\n\n"
          "**Day 2: Nature & Hills**\n"
          "- Morning: Penang Hill\n"
          "- Evening: Batu Ferringhi Night Market\n\n"
          "**Day 3: Culture & Shopping**\n"
          "- Morning: Kek Lok Si Temple\n"
          "- Afternoon: Shopping at Prangin Mall\n";
    }
    return "I've created a custom plan for you!\n\n**Day 1:**\n- Explore the local markets.\n- Visit the national museum.\n- Try a local delicacy for dinner.";
  }
}
