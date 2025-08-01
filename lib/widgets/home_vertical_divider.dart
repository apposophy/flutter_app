// lib/widgets/home_vertical_divider.dart
import 'package:flutter/material.dart';

class HomeVerticalDivider extends StatefulWidget {
  final double minPanelWidth;
  final double maxPanelWidth;
  final double currentPanelWidth;
  final Function(double) onWidthChanged; // Callback to update width in parent

  const HomeVerticalDivider({
    super.key,
    required this.minPanelWidth,
    required this.maxPanelWidth,
    required this.currentPanelWidth,
    required this.onWidthChanged,
  });

  @override
  State<HomeVerticalDivider> createState() => _HomeVerticalDividerState();
}

class _HomeVerticalDividerState extends State<HomeVerticalDivider> {
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeLeftRight, // Show resize cursor
      child: GestureDetector(
        onPanUpdate: (details) {
          // Calculate new width and clamp it
          double newWidth = (widget.currentPanelWidth + details.delta.dx)
              .clamp(widget.minPanelWidth, widget.maxPanelWidth);
          // Notify parent of the change
          widget.onWidthChanged(newWidth);
        },
        child: Container(
          width: 8.0,
          // height: 30.0, // Height is usually determined by parent Row/Column
          color: Colors.grey[300],
          child: Center(
            child: RotatedBox(
              quarterTurns: 2,
              child: Icon(
                Icons.drag_indicator_rounded, // Sleeker drag handle icon
                color: Colors.grey[600],
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
