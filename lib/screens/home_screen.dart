// lib/screens/home_screen.dart
import 'package:flutter/material.dart';

import '../data/fruit_data.dart';
// 1. Import the new widget files
import '../widgets/home_mobile_layout.dart';
import '../widgets/home_tablet_desktop_layout.dart';

class HomeScreen extends StatefulWidget {
  final Function(List<String>)? onFavoritesUpdated;
  final Function() toggleTheme;
  final int keys;
  final Function(String) unlockItem;
  final Function(String) isItemUnlocked;
  final int currentIndex;
  final Function(int) onTabTapped;

  const HomeScreen({
    super.key,
    this.onFavoritesUpdated,
    required this.toggleTheme,
    required this.keys,
    required this.unlockItem,
    required this.isItemUnlocked,
    required this.currentIndex,
    required this.onTabTapped,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<FruitInfo> filteredItems;
  List<String> favoriteItems = [];
  final TextEditingController _searchController = TextEditingController();
  FruitInfo? _selectedFruit;
  final bool _isNavBarCollapsed = true; // Track if the nav bar is collapsed
  final double _leftPanelWidth = 300.0; // Initial width of the left panel
  static const double _minLeftPanelWidth = 300.0;
  static const double _maxLeftPanelWidth = 450.0;

  @override
  void initState() {
    super.initState();
    filteredItems = FruitData.fruits;
    _loadFavorites();
    _searchController.addListener(_filterItems);
  }

  Future<void> _loadFavorites() async {
    final favorites = await FruitData.loadFavorites();
    setState(() {
      favoriteItems = favorites;
    });
    // Only call if provided
    if (widget.onFavoritesUpdated != null) {
      widget.onFavoritesUpdated!(favoriteItems);
    }
  }

  Future<void> _toggleFavorite(String itemName) async {
    setState(() {
      if (favoriteItems.contains(itemName)) {
        favoriteItems.remove(itemName);
      } else {
        favoriteItems.add(itemName);
      }
    });
    await FruitData.saveFavorites(favoriteItems);
    // Only call if provided
    if (widget.onFavoritesUpdated != null) {
      widget.onFavoritesUpdated!(favoriteItems);
    }
  }

  void _filterItems() {
    final String query = _searchController.text.toLowerCase();
    setState(() {
      filteredItems = FruitData.fruits
          .where((fruit) =>
              fruit.name.toLowerCase().contains(query) ||
              fruit.frenchTranslation.toLowerCase().contains(query) ||
              fruit.arabicTranslation.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          // Small screens (mobile) - use the new widget
          return HomeMobileLayout(
            // 2. Use the new widget
            filteredItems: filteredItems,
            favoriteItems: favoriteItems,
            searchController: _searchController,
            toggleTheme: widget.toggleTheme,
            keys: widget.keys,
            unlockItem: (itemName) =>
                widget.unlockItem(itemName), // Wrap for consistency if needed
            isItemUnlocked: widget.isItemUnlocked,
            toggleFavorite: (itemName) =>
                _toggleFavorite(itemName), // Wrap method
            filterItems: _filterItems,
            showUnlockDialog: (fruit) =>
                _showUnlockDialog(fruit.name), // Wrap for widget
            showUnlockFirstDialog: _showUnlockFirstDialog,
            loadFavorites: _loadFavorites, // Pass the method
          );
        } else {
          // Medium and Large screens (tablet/desktop) - use the new widget
          return HomeTabletDesktopLayout(
            // 3. Use the new widget
            filteredItems: filteredItems,
            favoriteItems: favoriteItems,
            searchController: _searchController,
            toggleTheme: widget.toggleTheme,
            keys: widget.keys,
            unlockItem: (itemName) => widget.unlockItem(itemName), // Wrap
            isItemUnlocked: widget.isItemUnlocked,
            toggleFavorite: (itemName) => _toggleFavorite(itemName), // Wrap
            filterItems: _filterItems,
            showUnlockDialog: (fruit) => _showUnlockDialog(fruit.name), // Wrap
            showUnlockFirstDialog: _showUnlockFirstDialog,
            selectFruit: _selectFruit, // Pass the method
            selectedFruit: _selectedFruit, // Pass the state
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
