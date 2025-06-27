import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import 'package:flutter/material.dart';

class FallingItem {
  final int id;
  double x; // -1.0 ~ 1.0 (横位置)
  double y; // -1.0 ~ 1.0 (縦位置)
  final Color color;
  final int score;
  final int type;
  final String imagePath;
  FallingItem({
    required this.id,
    required this.x,
    required this.y,
    required this.color,
    required this.score,
    required this.type,
    required this.imagePath,
  });
}

class ItemListNotifier extends StateNotifier<List<FallingItem>> {
  ItemListNotifier() : super([]);
  int _nextId = 0;
  final Random _random = Random();

  // アイテムの種類と出現重み
  final List<_ItemType> _itemTypes = [
    _ItemType(
      type: 0,
      color: Colors.blue,
      score: 5,
      weight: 50,
      imagePath: 'images/jonas_01.jpg',
    ),
    _ItemType(
      type: 1,
      color: Colors.green,
      score: 10,
      weight: 30,
      imagePath: 'images/jonas_02.jpg',
    ),
    _ItemType(
      type: 2,
      color: Colors.orange,
      score: 30,
      weight: 12,
      imagePath: 'images/jonas_03.jpg',
    ),
    _ItemType(
      type: 3,
      color: Colors.red,
      score: 50,
      weight: 6,
      imagePath: 'images/jonas_04.jpg',
    ),
    _ItemType(
      type: 4,
      color: Colors.purple,
      score: 100,
      weight: 2,
      imagePath: 'images/jonas_05.jpg',
    ),
  ];

  void spawnItem() {
    // 重み付きランダムでアイテムタイプを選択
    final totalWeight = _itemTypes.fold<int>(0, (sum, t) => sum + t.weight);
    int rand = _random.nextInt(totalWeight);
    _ItemType selected = _itemTypes.first;
    for (final t in _itemTypes) {
      if (rand < t.weight) {
        selected = t;
        break;
      }
      rand -= t.weight;
    }
    final x = _random.nextDouble() * 1.8 - 0.9;
    state = [
      ...state,
      FallingItem(
        id: _nextId++,
        x: x,
        y: -1.0,
        color: selected.color,
        score: selected.score,
        type: selected.type,
        imagePath: selected.imagePath,
      ),
    ];
  }

  void updateItems(double speed) {
    state = [
      for (final item in state)
        FallingItem(
          id: item.id,
          x: item.x,
          y: item.y + speed,
          color: item.color,
          score: item.score,
          type: item.type,
          imagePath: item.imagePath,
        ),
    ];
  }

  void removeItem(int id) {
    state = state.where((item) => item.id != id).toList();
  }

  void removeItemsBelow() {
    state = state.where((item) => item.y < 1.1).toList();
  }
}

class _ItemType {
  final int type;
  final Color color;
  final int score;
  final int weight;
  final String imagePath;
  const _ItemType({
    required this.type,
    required this.color,
    required this.score,
    required this.weight,
    required this.imagePath,
  });
}

final itemListProvider =
    StateNotifierProvider<ItemListNotifier, List<FallingItem>>(
      (ref) => ItemListNotifier(),
    );
