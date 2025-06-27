import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dj_catch/page/result_page.dart';
import 'package:dj_catch/provider/character_provider.dart';
import 'package:dj_catch/provider/item_provider.dart';
import 'package:dj_catch/provider/score_provider.dart';
import 'package:dj_catch/widget/shining_item_image.dart';
import 'package:dj_catch/widget/hold_button.dart';

class GamePage extends ConsumerStatefulWidget {
  const GamePage({super.key});

  @override
  ConsumerState<GamePage> createState() => _GamePageState();
}

class _GamePageState extends ConsumerState<GamePage> {
  Timer? _leftTimer;
  Timer? _rightTimer;
  Timer? _itemTimer;
  Timer? _fallTimer;
  static const Duration interval = Duration(milliseconds: 50);
  static const Duration spawnInterval = Duration(milliseconds: 1500);
  static const double fallSpeed = 0.025;
  static const double characterWidth = 0.18; // Alignment基準
  static const double itemWidth = 0.18;
  static const double itemHeight = 0.13;
  int missCount = 0;
  bool isGameOver = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(scoreProvider.notifier).reset();
      ref.read(itemListProvider.notifier).state = [];
      ref.read(characterProvider.notifier).state = 0.0;
      missCount = 0;
      isGameOver = false;
    });
    // アイテム生成タイマー
    _itemTimer = Timer.periodic(spawnInterval, (_) {
      ref.read(itemListProvider.notifier).spawnItem();
    });
    // アイテム降下タイマー
    _fallTimer = Timer.periodic(interval, (_) {
      ref.read(itemListProvider.notifier).updateItems(fallSpeed);
      _checkCatch();
      _removeMissedItems();
    });
  }

  void _checkCatch() {
    final items = ref.read(itemListProvider);
    final characterX = ref.read(characterProvider);
    final List<int> caughtIds = [];
    for (final item in items) {
      // yが0.55〜1.0付近でキャッチ判定
      if (item.y > 0.55 && item.y < 1) {
        // x座標が重なっていればキャッチ（判定を緩く）
        if ((item.x - characterX).abs() < (characterWidth + itemWidth) / 0.9) {
          caughtIds.add(item.id);
          ref.read(scoreProvider.notifier).addScore(item.score);
        }
      }
    }
    if (caughtIds.isNotEmpty) {
      ref.read(itemListProvider.notifier).state = [
        for (final item in items)
          if (!caughtIds.contains(item.id)) item,
      ];
    }
  }

  void _removeMissedItems() {
    final items = ref.read(itemListProvider);
    final missed = items.where((item) => item.y >= 1.1).toList();
    if (missed.isNotEmpty) {
      missCount += missed.length;
      if (missCount >= 5 && !isGameOver) {
        isGameOver = true;
        Future.microtask(() {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => ResultPage(score: ref.read(scoreProvider)),
            ),
          );
        });
      }
      ref.read(itemListProvider.notifier).state = [
        for (final item in items)
          if (item.y < 1.1) item,
      ];
    }
  }

  void _startMoveLeft() {
    _leftTimer?.cancel();
    _leftTimer = Timer.periodic(interval, (_) {
      ref.read(characterProvider.notifier).moveLeft();
    });
  }

  void _stopMoveLeft() {
    _leftTimer?.cancel();
    _leftTimer = null;
  }

  void _startMoveRight() {
    _rightTimer?.cancel();
    _rightTimer = Timer.periodic(interval, (_) {
      ref.read(characterProvider.notifier).moveRight();
    });
  }

  void _stopMoveRight() {
    _rightTimer?.cancel();
    _rightTimer = null;
  }

  @override
  void dispose() {
    _leftTimer?.cancel();
    _rightTimer?.cancel();
    _itemTimer?.cancel();
    _fallTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final characterX = ref.watch(characterProvider);
    final items = ref.watch(itemListProvider);
    final score = ref.watch(scoreProvider);
    return WillPopScope(
      onWillPop: () async => false, // 戻る操作を禁止
      child: Scaffold(
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
            child: Stack(
              children: [
                // スコア・ミス数表示
                Positioned(
                  top: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'SCORE: $score',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(width: 24),
                          Text(
                            'MISS: $missCount/5',
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // アイテム
                ...items.map(
                  (item) => Align(
                    alignment: Alignment(item.x, item.y),
                    child: Container(
                      width: MediaQuery.of(context).size.width * itemWidth,
                      height: MediaQuery.of(context).size.height * itemHeight,
                      decoration: BoxDecoration(color: Colors.transparent),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (item.type == 4)
                            ShiningItemImage(
                              imagePath: item.imagePath,
                              width:
                                  MediaQuery.of(context).size.width * itemWidth,
                              height:
                                  MediaQuery.of(context).size.height *
                                  itemHeight,
                            )
                          else
                            Image.asset(
                              item.imagePath,
                              width:
                                  MediaQuery.of(context).size.width * itemWidth,
                              height:
                                  MediaQuery.of(context).size.height *
                                  itemHeight,
                              fit: BoxFit.contain,
                            ),
                          Positioned(
                            bottom: 2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '+${item.score}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  shadows: [
                                    Shadow(color: Colors.black, blurRadius: 4),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // キャラクター
                Align(
                  alignment: Alignment(characterX, 0.7),
                  child: Container(
                    width: MediaQuery.of(context).size.width * characterWidth,
                    height: MediaQuery.of(context).size.width * characterWidth,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
                // 操作ボタン
                Positioned(
                  bottom: 32,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      HoldButton(
                        icon: Icons.arrow_back,
                        onTapDown: (_) => _startMoveLeft(),
                        onTapUp: (_) => _stopMoveLeft(),
                        onTapCancel: _stopMoveLeft,
                      ),
                      HoldButton(
                        icon: Icons.arrow_forward,
                        onTapDown: (_) => _startMoveRight(),
                        onTapUp: (_) => _stopMoveRight(),
                        onTapCancel: _stopMoveRight,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
