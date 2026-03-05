import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/progress_service.dart';
import '../models/user_progress.dart';
import 'quiz_screen.dart';
import '../data/sample_questions.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('أهلاً ${authService.userName ?? ""}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => authService.signOut(),
          tooltip: 'تغيير اللاعب',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => authService.signOut(),
            tooltip: 'خروج',
          )
        ],
      ),
      body: Consumer<ProgressService>(
        builder: (context, progressService, child) {
          return FutureBuilder<UserProgress?>(
            future: progressService.loadProgress(authService.userName ?? 'guest'),
            builder: (context, snapshot) {
              // We use a FutureBuilder inside a Consumer.
              // When progressService calls notifyListeners(), Consumer re-runs, and FutureBuilder re-fetches.
              final progress = snapshot.data;
              final unlockedLevels = progress?.unlockedLevels ?? [1];

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 for mobile, maybe 4 for web? keeping 2 for better UI on small screens
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                  ),
                  itemCount: 20,
                  itemBuilder: (context, index) {
                    final level = index + 1;
                    final isUnlocked = unlockedLevels.contains(level); 
                    final bestScore = progress?.bestScores[level];

                    return LevelCard(
                      level: level,
                      isUnlocked: isUnlocked,
                      bestScore: bestScore,
                      onTap: isUnlocked ? () {
                        final questions = getQuestionsForLevel(level);
                        if (questions.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuizScreen(
                                level: level,
                                questions: questions,
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('قريباً: أسئلة هذا المستوى تحت الإعداد')),
                          );
                        }
                      } : null,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class LevelCard extends StatelessWidget {
  final int level;
  final bool isUnlocked;
  final int? bestScore;
  final VoidCallback? onTap;

  const LevelCard({
    super.key,
    required this.level,
    required this.isUnlocked,
    this.bestScore,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUnlocked ? Colors.white : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isUnlocked ? Theme.of(context).primaryColor : Colors.grey[400]!,
            width: isUnlocked ? 2 : 1,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'المستوى $level',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isUnlocked ? Theme.of(context).primaryColor : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                if (isUnlocked && bestScore != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF27AE60).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Color(0xFFF39C12), size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '$bestScore / 10',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF27AE60),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (isUnlocked)
                   const Text(
                    'لم يبدأ بعد',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
            if (!isUnlocked)
              const Positioned(
                top: 0,
                right: 0,
                child: Icon(Icons.lock, size: 20, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}
