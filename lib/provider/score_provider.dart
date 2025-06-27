import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScoreNotifier extends StateNotifier<int> {
  ScoreNotifier() : super(0);
  void addScore(int value) => state += value;
  void reset() => state = 0;
}

final scoreProvider = StateNotifierProvider<ScoreNotifier, int>(
  (ref) => ScoreNotifier(),
);
