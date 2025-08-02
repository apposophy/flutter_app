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
  bool _isDragging = false; // Track dragging state for visual feedback

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeLeftRight, // Show resize cursor
      child: Listener(
        // Use Listener for potentially smoother/ more direct control
        onPointerDown: (_) {
          // Provide immediate visual feedback when drag starts
          setState(() {
            _isDragging = true;
          });
        },
        onPointerMove: (PointerMoveEvent details) {
          // Calculate new width and clamp it based on delta movement
          double newWidth = (widget.currentPanelWidth + details.delta.dx)
              .clamp(widget.minPanelWidth, widget.maxPanelWidth);
          // Notify parent of the change
          // Consider if calling setState in parent is too expensive here.
          // For smoother updates, ensure parent efficiently handles this.
          widget.onWidthChanged(newWidth);
        },
        onPointerUp: (_) {
          // Reset visual feedback when drag ends normally
          setState(() {
            _isDragging = false;
          });
        },
        onPointerCancel: (_) {
          // Reset visual feedback if drag is cancelled (e.g., interrupted)
          setState(() {
            _isDragging = false;
          });
        },
        child: Container(
          width: 8.0,
          // height: double.infinity, // Let it expand vertically
          // Use decoration for easier addition of effects like shadows
          decoration: BoxDecoration(
            color: _isDragging
                ? Colors.grey[400]
                : Colors.grey[300], // Visual feedback
            // Add a subtle shadow when dragging for depth
            boxShadow: _isDragging
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 2,
                      offset: const Offset(1, 0), // Shadow to the right
                    )
                  ]
                : null,
          ),
          child: Center(
            child: RotatedBox(
              quarterTurns: 2, // 180 degrees
              child: Icon(
                Icons.drag_handle, // Standard drag handle icon
                color: _isDragging
                    ? Colors.grey[800]
                    : Colors.grey[600], // Feedback
                size: 20, // Slightly smaller icon might look better
              ),
            ),
          ),
        ),
      ),
    );
  }
}
