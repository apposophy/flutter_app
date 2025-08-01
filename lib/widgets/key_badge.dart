// lib/widgets/key_badge.dart
import 'package:flutter/material.dart';

/// A widget that displays a Material Design 3 badge showing a key count
/// overlaid on top of another icon or widget.
class KeyBadge extends StatelessWidget {
  final int keyCount;
  final Color backgroundColor; // Allow customization
  final Color textColor; // Allow customization

  const KeyBadge({
    super.key,
    required this.keyCount,
    this.backgroundColor = Colors.orange, // Default to orange
    this.textColor = Colors.white, // Default to white
  });

  @override
  Widget build(BuildContext context) {
    // Only show the badge if keyCount is greater than 0
    if (keyCount <= 0) {
      // Return an empty SizedBox to take up no space, or just SizedBox.shrink()
      // Returning the child without a badge might be better depending on usage context.
      // For use inside a Stack with an IconButton, returning just the IconButton's icon
      // (without badge) is usually handled by the parent IconButton.
      // So, we return an empty widget that takes up minimal space.
      return const SizedBox.shrink();
    }

    // Use the Material 3 Badge widget
    return Badge.count(
      count: keyCount,
      backgroundColor: backgroundColor,
      textColor: textColor,
      // The child is typically the icon you want the badge on.
      // Since KeyBadge is used inside a Stack over an IconButton,
      // the visual icon is provided by the IconButton itself.
      // Therefore, KeyBadge just needs to render the badge part.
      // We can use an empty SizedBox as the child for the Badge widget.
      child: const SizedBox.shrink(),
    );
  }
}
