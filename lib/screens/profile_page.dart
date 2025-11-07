import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:jomjalan/main.dart'; // For colors
import 'package:jomjalan/models/spot_model.dart'; // For Challenge
import 'package:jomjalan/providers/gamification_provider.dart';
import 'package:jomjalan/services/api_service.dart';
import 'package:jomjalan/widgets/section_header.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final MockApiService _apiService = MockApiService();
  late Future<List<Challenge>> _challenges;

  @override
  void initState() {
    super.initState();
    _challenges = _apiService.getChallenges();
  }

  @override
  Widget build(BuildContext context) {
    final gamification = context.watch<GamificationProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: primaryGreen,
                  child: Icon(Ionicons.person, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 16),
                const Text(
                  "JomJalan User",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: primaryGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${gamification.points} Points",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Challenges Section
          SectionHeader(title: "Available Challenges", onViewAll: () {}),
          const SizedBox(height: 12),
          FutureBuilder<List<Challenge>>(
            future: _challenges,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();
              final challenges = snapshot.data!;
              return Column(
                children:
                    challenges.map((challenge) {
                      bool isCompleted = gamification.isChallengeCompleted(
                        challenge,
                      );
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: Icon(
                            challenge.icon,
                            color: isCompleted ? primaryGreen : subTextColor,
                          ),
                          title: Text(
                            challenge.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration:
                                  isCompleted
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                            ),
                          ),
                          subtitle: Text(challenge.description),
                          trailing: Text(
                            "+${challenge.points} pts",
                            style: const TextStyle(
                              color: primaryGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap:
                              isCompleted
                                  ? null // Do nothing if completed
                                  : () {
                                    // Complete the challenge
                                    context
                                        .read<GamificationProvider>()
                                        .completeChallenge(challenge);
                                  },
                        ),
                      );
                    }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
