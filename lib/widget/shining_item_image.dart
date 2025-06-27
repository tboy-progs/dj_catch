import 'package:flutter/material.dart';

class ShiningItemImage extends StatefulWidget {
  final String imagePath;
  final double width;
  final double height;
  const ShiningItemImage({
    required this.imagePath,
    required this.width,
    required this.height,
    super.key,
  });

  @override
  State<ShiningItemImage> createState() => _ShiningItemImageState();
}

class _ShiningItemImageState extends State<ShiningItemImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.0),
                Colors.white.withOpacity(0.7),
                Colors.white.withOpacity(0.0),
              ],
              stops: [
                (_controller.value - 0.2).clamp(0.0, 1.0),
                _controller.value,
                (_controller.value + 0.2).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          blendMode: BlendMode.lighten,
          child: Image.asset(
            widget.imagePath,
            width: widget.width,
            height: widget.height,
            fit: BoxFit.contain,
          ),
        );
      },
    );
  }
}
