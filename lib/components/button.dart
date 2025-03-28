import 'package:flutter/material.dart';

class SquircleButton extends StatelessWidget {
  const SquircleButton(
      {super.key,
      required this.onTap,
      required this.title,
      this.background,
      this.gradient,
      this.textColor});

  final VoidCallback onTap;
  final String? title;
  final Color? background;
  final LinearGradient? gradient;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: gradient,
          color: background,
        ),
        child: Center(
          child: Text(
            title!,
            style: TextStyle(
              fontSize: 16,
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
