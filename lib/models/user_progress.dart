class UserProgress {
  final String userId;
  final int currentLevel;
  final Map<int, int> bestScores; // level -> best score
  final List<int> unlockedLevels;
  final int totalQuestionsAnswered;
  final DateTime lastPlayed;

  UserProgress({
    required this.userId,
    this.currentLevel = 1,
    Map<int, int>? bestScores,
    List<int>? unlockedLevels,
    this.totalQuestionsAnswered = 0,
    DateTime? lastPlayed,
  })  : bestScores = bestScores ?? {},
        unlockedLevels = unlockedLevels ?? [1],
        lastPlayed = lastPlayed ?? DateTime.now();

  UserProgress copyWith({
    String? userId,
    int? currentLevel,
    Map<int, int>? bestScores,
    List<int>? unlockedLevels,
    int? totalQuestionsAnswered,
    DateTime? lastPlayed,
  }) {
    return UserProgress(
      userId: userId ?? this.userId,
      currentLevel: currentLevel ?? this.currentLevel,
      bestScores: bestScores ?? this.bestScores,
      unlockedLevels: unlockedLevels ?? this.unlockedLevels,
      totalQuestionsAnswered: totalQuestionsAnswered ?? this.totalQuestionsAnswered,
      lastPlayed: lastPlayed ?? this.lastPlayed,
    );
  }
}
