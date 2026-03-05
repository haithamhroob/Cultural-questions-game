import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../models/question.dart';
import '../models/user_progress.dart';
import '../services/auth_service.dart';
import '../services/progress_service.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final int level;
  final List<Question> questions;

  const QuizScreen({super.key, required this.level, required this.questions});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  int _score = 0;
  Timer? _timer;
  int _timeRemaining = 60; // 60 seconds per question
  bool _isAnswered = false;
  int? _selectedAnswerIndex;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        setState(() {
          _timeRemaining--;
        });
      } else {
        _autoSubmit();
      }
    });
  }

  void _autoSubmit() {
    _timer?.cancel();
    if (!_isAnswered) {
      _handleAnswer(-1); // -1 for timeout
    }
  }

  void _handleAnswer(int selectedIndex) {
    if (_isAnswered) return;
    _timer?.cancel(); // Stop timer immediately on answer

    final isCorrect = selectedIndex == widget.questions[_currentIndex].correctAnswerIndex;

    setState(() {
      _isAnswered = true;
      _selectedAnswerIndex = selectedIndex;

      if (isCorrect) {
        _score++;
      }
    });

    if (isCorrect) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('إجابة رائعة! +1 نقطة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          backgroundColor: const Color(0xFF27AE60),
          duration: const Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }

    // Shorter delay for wrong answers, longer for showing the green correct message
    Future.delayed(Duration(milliseconds: isCorrect ? 2000 : 1000), () {
      if (!mounted) return;
      if (_currentIndex < widget.questions.length - 1) {
        setState(() {
          _currentIndex++;
          _isAnswered = false;
          _selectedAnswerIndex = null;
          _timeRemaining = 60; 
          _startTimer(); // Re-start timer for next question
        });
      } else {
        _showResults();
      }
    });
  }

  void _showResults() async {
    _timer?.cancel();
    
    final authService = Provider.of<AuthService>(context, listen: false);
    final progressService = Provider.of<ProgressService>(context, listen: false);
    final userId = authService.userName ?? 'guest';

    // Load existing progress or create new
    UserProgress progress = await progressService.loadProgress(userId) ?? UserProgress(userId: userId);

    // Update scores if better
    final Map<int, int> newBestScores = Map.from(progress.bestScores);
    if (_score > (newBestScores[widget.level] ?? 0)) {
      newBestScores[widget.level] = _score;
    }

    // Unlock next level if passed (7/10)
    final List<int> newUnlockedLevels = List.from(progress.unlockedLevels);
    if (_score >= 7 && widget.level < 20) {
      if (!newUnlockedLevels.contains(widget.level + 1)) {
        newUnlockedLevels.add(widget.level + 1);
      }
    }

    final newProgress = progress.copyWith(
      bestScores: newBestScores,
      unlockedLevels: newUnlockedLevels,
      totalQuestionsAnswered: progress.totalQuestionsAnswered + widget.questions.length,
      lastPlayed: DateTime.now(),
    );

    await progressService.saveProgress(newProgress);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            level: widget.level,
            score: _score,
            totalQuestions: widget.questions.length,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('المستوى ${widget.level}')),
        body: const Center(child: Text('لا توجد أسئلة في هذا المستوى')),
      );
    }

    final question = widget.questions[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('المستوى ${widget.level} - سؤال ${_currentIndex + 1} / ${widget.questions.length}', style: TextStyle(color: Colors.white, fontSize: 18)),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Timer and Progress
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.timer, color: Color(0xFFE74C3C)),
                    const SizedBox(width: 8),
                    Text(
                      '${(_timeRemaining ~/ 60).toString().padLeft(2, '0')}:${(_timeRemaining % 60).toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Text(
                  'النقاط: $_score',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF27AE60)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Question Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  question.questionText,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.5),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Options
            Expanded(
              child: ListView.builder(
                itemCount: question.options.length,
                itemBuilder: (context, index) {
                  final isCorrect = index == question.correctAnswerIndex;
                  final isSelected = index == _selectedAnswerIndex;
                  
                  Color buttonColor = Colors.white;
                  Color textColor = Theme.of(context).primaryColor;
                  
                  if (_isAnswered) {
                    if (isSelected) {
                      if (isCorrect) {
                        buttonColor = const Color(0xFF27AE60); // Green
                        textColor = Colors.white;
                      } else {
                        buttonColor = const Color(0xFFE74C3C); // Red
                        textColor = Colors.white;
                      }
                    }
                    // For non-selected items, they remain neutral to not reveal the correct answer if user got it wrong.
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: ElevatedButton(
                      onPressed: _isAnswered ? null : () => _handleAnswer(index),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        foregroundColor: textColor,
                        disabledBackgroundColor: buttonColor,
                        disabledForegroundColor: textColor,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: _isAnswered ? Colors.transparent : Theme.of(context).primaryColor,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Text(
                        question.options[index],
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
