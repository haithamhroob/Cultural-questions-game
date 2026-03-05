import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../data/sample_questions.dart';
import 'quiz_screen.dart';

class ResultScreen extends StatelessWidget {
  final int level;
  final int score;
  final int totalQuestions;

  const ResultScreen({
    super.key,
    required this.level,
    required this.score,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    final bool passed = score >= 7; // Require 7/10 to pass

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                passed ? Icons.emoji_events : Icons.refresh,
                size: 100,
                color: passed ? const Color(0xFFF39C12) : const Color(0xFFE74C3C),
              ),
              const SizedBox(height: 20),
              Text(
                passed ? 'أحسنت!' : 'حاول مرة أخرى',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: passed ? const Color(0xFF27AE60) : const Color(0xFFE74C3C),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'نتيجتك في المستوى $level',
                style: const TextStyle(fontSize: 20, color: Color(0xFF2C3E50)),
              ),
              const SizedBox(height: 20),
              Text(
                '$score / $totalQuestions',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                passed ? 'لقد اجتزت هذا المستوى بنجاح!' : 'تحتاج إلى 7 إجابات صحيحة على الأقل لاجتياز المستوى.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // Pop back to dashboard
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    icon: const Icon(Icons.home),
                    label: const Text('الرئيسية'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (passed && level < 20)
                    ElevatedButton.icon(
                      onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuizScreen(
                            level: level + 1,
                            questions: getQuestionsForLevel(level + 1), 
                          ),
                        ),
                      );
                    },
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('المستوى التالي'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF27AE60),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  if (!passed)
                    ElevatedButton.icon(
                      onPressed: () {
                        // Pop result screen off, the quiz screen is below it, but we want to reset it or re-push it
                        // For simplicity, just pop to dashboard for now and let user click again
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      icon: const Icon(Icons.replay),
                      label: const Text('إعادة المحاولة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE74C3C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
