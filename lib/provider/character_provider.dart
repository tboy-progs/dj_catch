import 'package:flutter_riverpod/flutter_riverpod.dart';

class CharacterNotifier extends StateNotifier<double> {
  CharacterNotifier() : super(0.0);

  final double _moveStep = 0.2;

  void moveLeft() {
    state = (state - _moveStep).clamp(-1.0, 1.0);
  }

  void moveRight() {
    state = (state + _moveStep).clamp(-1.0, 1.0);
  }
}

final characterProvider = StateNotifierProvider<CharacterNotifier, double>((
  ref,
) {
  return CharacterNotifier();
});
