// lib/widgets/collapsible_nav_item.dart
import 'package:flutter/material.dart';

class CollapsibleNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool isCollapsed; // Control whether label is shown

  const CollapsibleNavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.isCollapsed = false, // Default to showing label
  });

  @override
  Widget build(BuildContext context) {
    if (isCollapsed) {
      // If collapsed, only show the icon button
      return IconButton(
        icon: Icon(
          icon,
          color: isActive ? Theme.of(context).colorScheme.primary : null,
        ),
        onPressed: onTap,
      );
    } else {
      // If not collapsed, show icon button and label in a row
      return Row(
        children: [
          IconButton(
            icon: Icon(
              icon,
              color: isActive ? Theme.of(context).colorScheme.primary : null,
            ),
            onPressed: onTap,
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Theme.of(context).colorScheme.primary : null,
              fontSize: 12,
            ),
          ),
        ],
      );
    }
  }
}
