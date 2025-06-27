import 'package:dj_catch/page/home_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ResultPage extends StatelessWidget {
  final int score;
  const ResultPage({super.key, required this.score});

  Future<Map<String, dynamic>?> fetchHighScore() async {
    final doc = await FirebaseFirestore.instance
        .collection('highscores')
        .doc('V31RnAACew0KnE6tG9Ms')
        .get();
    return doc.data();
  }

  Future<void> updateHighScore(String username, int newScore) async {
    await FirebaseFirestore.instance.collection('highscores').doc('global').set(
      {'username': username, 'score': newScore},
    );
  }

  void showScoreDialog(BuildContext context) async {
    final highScoreData = await fetchHighScore();
    final int highScore = highScoreData != null
        ? highScoreData['score'] ?? 0
        : 0;
    final String highScoreUser = highScoreData != null
        ? highScoreData['username'] ?? ''
        : '';
    final TextEditingController nameController = TextEditingController();
    bool isNewRecord = score > highScore;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('スコア結果'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('ハイスコア: $highScore ($highScoreUser)'),
              Text('今回のスコア: $score'),
              if (isNewRecord) ...[
                const SizedBox(height: 16),
                const Text('新記録！ユーザー名を入力してください'),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'ユーザー名'),
                ),
              ],
            ],
          ),
          actions: [
            if (isNewRecord)
              TextButton(
                onPressed: () async {
                  final username = nameController.text.trim();
                  if (username.isNotEmpty) {
                    await updateHighScore(username, score);
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('保存'),
              )
            else
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showScoreDialog(context);
    });
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
              Color(0xFF0f3460),
              Color(0xFF533483),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'GAME OVER',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 6,
                  shadows: [
                    Shadow(
                      color: Colors.purple,
                      blurRadius: 20,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'SCORE: $score',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.purpleAccent,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 80),
              Container(
                width: 200,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.purple, Colors.deepPurple],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const HomePage()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'HOMEに戻る',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
