import 'package:dj_catch/page/game_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int? _highScore;
  String? _highScoreUser;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchHighScore();
  }

  Future<void> _fetchHighScore() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('highscores')
          .doc('global')
          .get();
      final data = doc.data();
      setState(() {
        _highScore = data != null ? data['score'] ?? 0 : 0;
        _highScoreUser = data != null ? data['username'] ?? '' : '';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _highScore = null;
        _highScoreUser = null;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
              // ゲームタイトル
              const Text(
                'JONAS CATCH',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 8,
                  shadows: [
                    Shadow(
                      color: Colors.purple,
                      blurRadius: 20,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // ハイスコア表示
              Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 16),
                child: _loading
                    ? const CircularProgressIndicator()
                    : Column(
                        children: [
                          const Text(
                            '現在のオンライン記録',
                            style: TextStyle(
                              color: Colors.amber,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          Text(
                            _highScore != null
                                ? '${_highScore!}（${_highScoreUser ?? ''}）'
                                : '取得できません',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),

              // const Text(
              //   'GAME',
              //   style: TextStyle(
              //     fontSize: 24,
              //     fontWeight: FontWeight.w300,
              //     color: Colors.purpleAccent,
              //     letterSpacing: 4,
              //   ),
              // ),
              const SizedBox(height: 80),

              // スタートボタン
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const GamePage()),
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
                    'START',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: SizedBox(
                  width: 300,
                  child: Text(
                    '落ちてくるジョナスをキャッチしてハイスコアを目指します。5回ジョナスを落とすとゲームオーバーです。',
                    style: TextStyle(color: Colors.grey[400], fontSize: 16),
                  ),
                ),
              ),

              // 設定ボタン
              // Container(
              //   width: 150,
              //   height: 45,
              //   decoration: BoxDecoration(
              //     border: Border.all(color: Colors.purpleAccent, width: 2),
              //     borderRadius: BorderRadius.circular(25),
              //   ),
              //   child: OutlinedButton(
              //     onPressed: () {
              //       // TODO: ルール画面に遷移
              //     },
              //     style: OutlinedButton.styleFrom(
              //       foregroundColor: Colors.purpleAccent,
              //       side: BorderSide.none,
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(25),
              //       ),
              //     ),
              //     child: const Text(
              //       'RULES',
              //       style: TextStyle(
              //         fontSize: 16,
              //         fontWeight: FontWeight.w500,
              //         letterSpacing: 1,
              //       ),
              //     ),
              //   ),
              // ),

              // const Spacer(),

              // フッター
              // Padding(
              //   padding: const EdgeInsets.only(bottom: 20),
              //   child: Text(
              //     '© 2024 DJ Catch Game',
              //     style: TextStyle(color: Colors.grey[400], fontSize: 12),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
