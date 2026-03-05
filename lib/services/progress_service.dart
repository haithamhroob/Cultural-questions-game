import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_progress.dart';

class ProgressService extends ChangeNotifier {
  
  // Save progress to local storage
  Future<void> saveProgress(UserProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> data = {
      'userId': progress.userId,
      'currentLevel': progress.currentLevel,
      'bestScores': progress.bestScores.map((key, value) => MapEntry(key.toString(), value)),
      'unlockedLevels': progress.unlockedLevels,
      'totalQuestionsAnswered': progress.totalQuestionsAnswered,
      'lastPlayed': progress.lastPlayed.toIso8601String(),
    };
    await prefs.setString('user_progress_${progress.userId}', jsonEncode(data));
    notifyListeners();
  }

  // Load progress from local storage
  Future<UserProgress?> loadProgress(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final dataStr = prefs.getString('user_progress_$userId');
    if (dataStr != null) {
      final Map<String, dynamic> data = jsonDecode(dataStr);
      Map<int, int> bestScores = {};
      if (data['bestScores'] != null) {
        (data['bestScores'] as Map<String, dynamic>).forEach((key, value) {
           bestScores[int.parse(key)] = value as int;
        });
      }
      
      return UserProgress(
        userId: data['userId'],
        currentLevel: data['currentLevel'] ?? 1,
        bestScores: bestScores,
        unlockedLevels: List<int>.from(data['unlockedLevels'] ?? [1]),
        totalQuestionsAnswered: data['totalQuestionsAnswered'] ?? 0,
        lastPlayed: data['lastPlayed'] != null ? DateTime.parse(data['lastPlayed']) : DateTime.now(),
      );
    }
    return null;
  }
}
