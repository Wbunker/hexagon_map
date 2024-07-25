import 'dart:math';
import 'package:flutter/material.dart';

class Hexagon extends StatelessWidget {
  final String imagePath;
  const Hexagon({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
        clipper: _Hexagon(), child: Image(image: AssetImage(imagePath)));
  }
}

class _Hexagon extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // // this follows the pointy-top orientation
    final hexSize = size.height / 2;
    final height = hexSize * 2;
    final width = sqrt(3) * hexSize;
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // move to bottom left corner
    path.moveTo(centerX - width / 2, centerY - height / 4);
    // line to top left corner
    path.lineTo(centerX - width / 2, centerY + height / 4);
    // line to top middle corner
    path.lineTo(centerX, centerY + height / 2);
    // line to top right corner
    path.lineTo(centerX + width / 2, centerY + height / 4);
    // line to bottom right corner
    path.lineTo(centerX + width / 2, centerY - height / 4);
    // line to bottom middle corner
    path.lineTo(centerX, centerY - height / 2);
    // line to bottom left corner
    path.lineTo(centerX - width / 2, centerY - height / 4);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
