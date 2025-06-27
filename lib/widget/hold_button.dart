import 'package:flutter/material.dart';

class HoldButton extends StatelessWidget {
  final IconData icon;
  final void Function(TapDownDetails) onTapDown;
  final void Function(TapUpDetails) onTapUp;
  final void Function() onTapCancel;
  const HoldButton({
    required this.icon,
    required this.onTapDown,
    required this.onTapUp,
    required this.onTapCancel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: onTapDown,
      onTapUp: onTapUp,
      onTapCancel: onTapCancel,
      child: ElevatedButton(
        onPressed: null, // GestureDetectorで制御するためonPressedはnull
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(20),
          backgroundColor: Colors.deepPurple.withOpacity(0.5),
          foregroundColor: Colors.white,
        ),
        child: Icon(icon, size: 30),
      ),
    );
  }
}
