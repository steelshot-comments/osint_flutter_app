import 'package:flutter/material.dart';
enum SquircleButtonWidth {
  wrapContent,   // size to child
  expand,        // fill max width
  specific,      // use provided width
}

class SquircleButton extends StatelessWidget {
  const SquircleButton({
    super.key,
    required this.onTap,
    required this.title,
    this.background,
    this.gradient,
    this.textColor,
    this.elevation = 10,
    this.shadowColor,
    this.icon,
    this.widthMode = SquircleButtonWidth.expand,
    this.width, // only used when widthMode == specific
  });

  final VoidCallback onTap;
  final String? title;
  final Color? background;
  final LinearGradient? gradient;
  final Color? textColor;
  final double elevation;
  final Color? shadowColor;
  final IconData? icon;

  /// NEW: controls how wide the button should be
  final SquircleButtonWidth widthMode;

  /// NEW: specific width only when widthMode == SquircleButtonWidth.specific
  final double? width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final baseColor = background ?? theme.colorScheme.primary;
    final effectiveBackground = baseColor.withAlpha(25);

    // Decide width based on mode
    Widget content = Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: gradient,
        color: gradient == null ? effectiveBackground : null,
      ),
      child: Row(
        mainAxisSize: widthMode == SquircleButtonWidth.wrapContent
            ? MainAxisSize.min
            : MainAxisSize.max,
        spacing: 4.0,
        children: [
          if (icon != null)
            Icon(icon, color: textColor ?? baseColor),
          Text(
            title ?? '',
            style: TextStyle(
              fontSize: 16,
              color: textColor ?? baseColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );

    // Apply fixed width if needed
    // if (widthMode == SquircleButtonWidth.specific && width != null) {
    //   content = SizedBox(width: width, child: content);
    // }

    // // Expand mode → make it fill available width
    // if (widthMode == SquircleButtonWidth.expand) {
    //   content = SizedBox(width: double.infinity, child: content);
    // }

    return Material(
      color: Colors.transparent,
      elevation: elevation,
      shadowColor: shadowColor ?? Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: GestureDetector(
        onTap: onTap,
        child: content,
      ),
    );
  }
}
