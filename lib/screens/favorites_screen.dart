// lib/screens/favorites_screen.dart
import 'package:flutter/material.dart';
import '../data/fruit_data.dart';
// 1. Import the new layout widgets
import '../widgets/favorites_mobile_layout.dart';
import '../widgets/favorites_tablet_desktop_layout.dart';

// Make sure these are also available if not already imported via favorites_*.dart
// import 'detail_screen.dart'; // Should be imported by favorites_tablet_desktop_layout.dart
// import '../widgets/home_vertical_divider.dart'; // Imported by favorites_tablet_desktop_layout.dart
// import '../widgets/collapsible_nav_item.dart'; // Imported by favorites_tablet_desktop_layout.dart

class FavoritesScreen extends StatefulWidget {
  final List<String>? favoriteItems;
  final Function(String)? onToggleFavorite;
  final Function() toggleTheme;
  final int keys;
  final Function(String) unlockItem;
  final Function(String) isItemUnlocked;
  final int currentIndex;
  final Function(int) onTabTapped;

  const FavoritesScreen({
    super.key,
    this.favoriteItems,
    this.onToggleFavorite,
    required this.toggleTheme,
    required this.keys,
    required this.unlockItem,
    required this.isItemUnlocked,
    required this.currentIndex,
    required this.onTabTapped,
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late List<FruitInfo> _favoriteFruits;
  final TextEditingController _searchController = TextEditingController();
  FruitInfo? _selectedFruit;
  final bool _isNavBarCollapsed = false; // Track if the nav bar is collapsed
  final double _leftPanelWidth = 300.0; // Initial width of the left panel
  static const double _minLeftPanelWidth = 250.0; // Match or adjust as needed
  static const double _maxLeftPanelWidth = 500.0; // Match or adjust as needed

  @override
  void initState() {
    super.initState();
    _updateFavoriteFruits();
    _searchController.addListener(_filterFavorites);
  }

  @override
  void didUpdateWidget(covariant FavoritesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.favoriteItems != oldWidget.favoriteItems) {
      _updateFavoriteFruits();
    }
  }

  void _updateFavoriteFruits() {
    final favoriteNames = widget.favoriteItems ?? [];
    setState(() {
      _favoriteFruits = FruitData.fruits
          .where((fruit) => favoriteNames.contains(fruit.name))
          .toList();
      if (_selectedFruit != null &&
          !favoriteNames.contains(_selectedFruit!.name)) {
        _selectedFruit = null;
      }
    });
  }

  void _filterFavorites() {
    final String query = _searchController.text.toLowerCase();
    final favoriteNames = widget.favoriteItems ?? [];
    setState(() {
      _favoriteFruits = FruitData.fruits
          .where((fruit) =>
              favoriteNames.contains(fruit.name) &&
              (fruit.name.toLowerCase().contains(query) ||
                  fruit.frenchTranslation.toLowerCase().contains(query) ||
                  fruit.arabicTranslation.toLowerCase().contains(query)))
          .toList();
      if (_selectedFruit != null &&
          !_favoriteFruits.any((fruit) => fruit.name == _selectedFruit!.name)) {
        _selectedFruit = null;
      }
    });
  }

  Future<void> _toggleFavorite(String itemName) async {
    if (widget.onToggleFavorite != null) {
      widget.onToggleFavorite!(itemName);
    }
    setState(() {
      _favoriteFruits.removeWhere((fruit) => fruit.name == itemName);
      if (_selectedFruit?.name == itemName) {
        _selectedFruit = null;
      }
    });
  }

  void _showUnlockDialog(String itemName) {
    final fruit = FruitData.fruits.firstWhere((f) => f.name == itemName);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Unlock ${fruit.name}'),
          content: Text(
              'Spend 1 key to unlock ${fruit.name}? You have ${widget.keys} keys left.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.unlockItem(itemName);
              },
              child: const Text('Unlock'),
            ),
          ],
        );
      },
    );
  }

  void _showUnlockFirstDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Unlock Required'),
          content: const Text('Tap the lock icon first to unlock this item.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _selectFruit(FruitInfo fruit) {
    setState(() {
      _selectedFruit = fruit;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          // Small screens (mobile) - use the new widget
          return FavoritesMobileLayout(
            favoriteFruits: _favoriteFruits,
            searchController: _searchController,
            toggleTheme: widget.toggleTheme,
            keys: widget.keys,
            selectFruit:
                _selectFruit, // Handles navigation logic internally or via callback
            showUnlockDialog: (itemName) =>
                _showUnlockDialog(itemName), // Wrap for signature
            showUnlockFirstDialog: _showUnlockFirstDialog,
            toggleFavorite: (itemName) =>
                _toggleFavorite(itemName), // Wrap for signature
            filterFavorites: _filterFavorites,
            selectedFruit: _selectedFruit,
            isItemUnlocked:
                widget.isItemUnlocked, // Pass the unlock check function
            showSnackbar: (String message) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          );
        } else {
          // Medium and Large screens (tablet/desktop) - use the new widget
          return FavoritesTabletDesktopLayout(
            favoriteFruits: _favoriteFruits,
            searchController: _searchController,
            toggleTheme: widget.toggleTheme,
            keys: widget.keys,
            unlockItem:
                widget.unlockItem, // For internal unlock dialog in list item
            isItemUnlocked: widget.isItemUnlocked,
            toggleFavorite: (itemName) => _toggleFavorite(itemName), // Wrap
            filterFavorites: _filterFavorites,
            showUnlockDialog: _showUnlockDialog,
            showUnlockFirstDialog: _showUnlockFirstDialog,
            selectFruit: _selectFruit,
            selectedFruit: _selectedFruit,
            currentIndex: widget.currentIndex,
            onTabTapped: widget.onTabTapped,
            initialLeftPanelWidth: _leftPanelWidth,
            minLeftPanelWidth: _minLeftPanelWidth,
            maxLeftPanelWidth: _maxLeftPanelWidth,
            isNavBarCollapsed: _isNavBarCollapsed,
          );
        }
      },
    );
  }
}
