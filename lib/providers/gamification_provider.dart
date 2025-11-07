import 'package:flutter/material.dart';
import 'package:jomjalan/models/spot_model.dart';

class GamificationProvider with ChangeNotifier {
  int _points = 0;
  final List<Challenge> _completedChallenges = [];

  int get points => _points;
  List<Challenge> get completedChallenges => _completedChallenges;

  bool isChallengeCompleted(Challenge challenge) {
    return _completedChallenges.any((c) => c.id == challenge.id);
  }

  void completeChallenge(Challenge challenge) {
    if (!isChallengeCompleted(challenge)) {
      _points += challenge.points;
      _completedChallenges.add(challenge);
      notifyListeners();
    }
  }
}
