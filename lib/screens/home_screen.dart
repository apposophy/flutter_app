// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../data/dictionary_item.dart'; // Import the base class
import '../data/dictionary_manager.dart'; // Import the manager
import '../data/fruit_data.dart'; // Still needed for FruitInfo if DetailScreen uses it specifically
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
  late List<DictionaryItem> filteredItems; // 2. Change type to DictionaryItem
  List<String> favoriteItems = [];
  final TextEditingController _searchController = TextEditingController();
  DictionaryItem?
      _selectedFruit; // 3. Change type (or keep FruitInfo if DetailScreen requires it)
  final bool _isNavBarCollapsed = true;
  final double _leftPanelWidth = 300.0;
  static const double _minLeftPanelWidth = 300.0;
  static const double _maxLeftPanelWidth = 450.0;

  // 4. Add state for selected dictionary
  DictionaryType _selectedDictionary =
      DictionaryType.fruits; // Default to fruits

  @override
  void initState() {
    super.initState();
    // 5. Initialize with items from the default dictionary
    filteredItems = DictionaryManager.getItems(_selectedDictionary);
    _loadFavorites();
    _searchController.addListener(_filterItems);
  }

  Future<void> _loadFavorites() async {
    final favorites =
        await FruitData.loadFavorites(); // Assuming this loads global favorites
    setState(() {
      favoriteItems = favorites;
    });
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
    await FruitData.saveFavorites(
        favoriteItems); // Assuming this saves global favorites
    if (widget.onFavoritesUpdated != null) {
      widget.onFavoritesUpdated!(favoriteItems);
    }
  }

  // 6. Add method to change dictionary
  void _changeDictionary(DictionaryType newType) {
    setState(() {
      _selectedDictionary = newType;
      // Update the list of items
      filteredItems = DictionaryManager.getItems(_selectedDictionary);
      // Clear search filter
      _searchController.clear();
      // Clear selection
      _selectedFruit = null;
      // Note: Favorites are kept global. If you want per-dictionary favorites,
      // you'd need to manage that logic here or in the manager.
    });
  }

  // 7. Update _filterItems to work with DictionaryItem and the selected dictionary
  void _filterItems() {
    final String query = _searchController.text.toLowerCase();
    final allItems = DictionaryManager.getItems(
        _selectedDictionary); // Get items for current dict
    setState(() {
      filteredItems = allItems
          .where((item) =>
              item.name.toLowerCase().contains(query) ||
              item.frenchTranslation.toLowerCase().contains(query) ||
              item.arabicTranslation.toLowerCase().contains(query))
          .toList();
      // Clear selection if item is filtered out
      if (_selectedFruit != null &&
          !filteredItems.any((item) => item.name == _selectedFruit!.name)) {
        _selectedFruit = null;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showUnlockDialog(String itemName) {
    // Find the item in the currently selected dictionary's data
    final allItems = DictionaryManager.getItems(_selectedDictionary);
    final item = allItems.firstWhere((i) => i.name == itemName,
        orElse: () => allItems.first);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Unlock ${item.name}'),
          content: Text(
              'Spend 1 key to unlock ${item.name}? You have ${widget.keys} keys left.'),
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

  // 8. Update _selectFruit signature if needed (though it might work with DictionaryItem)
  void _selectFruit(DictionaryItem fruit) {
    // Or keep as FruitInfo if necessary
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
            // Pass all necessary data and callbacks
            filteredItems: filteredItems,
            favoriteItems: favoriteItems,
            searchController: _searchController,
            toggleTheme: widget.toggleTheme,
            keys: widget.keys,
            // Pass the dictionary-related callbacks
            onChangeDictionary: _changeDictionary, // Pass the new method
            selectedDictionary: _selectedDictionary, // Pass the current state
            unlockItem: (itemName) => widget.unlockItem(itemName),
            isItemUnlocked: widget.isItemUnlocked,
            toggleFavorite: (itemName) => _toggleFavorite(itemName),
            filterItems: _filterItems,
            showUnlockDialog: (itemName) {
              // Find the item by name to pass to the dialog
              final allItems = DictionaryManager.getItems(_selectedDictionary);
              final item = allItems.firstWhere((i) => i.name == itemName,
                  orElse: () => allItems.first);
              _showUnlockDialog(
                  item.name); // Or just pass itemName if dialog finds it again
            },
            showUnlockFirstDialog: _showUnlockFirstDialog,
            loadFavorites: _loadFavorites,
            // If DetailScreen needs FruitInfo specifically, you might need to cast or adapt here
            // For example, if _selectedFruit is a FruitInfo:
            // selectedFruit: _selectedFruit as FruitInfo?, // Only if _selectedFruit is guaranteed to be FruitInfo
            // Otherwise, let the layout/widget handle displaying DictionaryItem data.
          );
        } else {
          // Medium and Large screens (tablet/desktop) - use the new widget
          return HomeTabletDesktopLayout(
            // Pass all necessary data and callbacks
            filteredItems: filteredItems,
            favoriteItems: favoriteItems,
            searchController: _searchController,
            toggleTheme: widget.toggleTheme,
            keys: widget.keys,
            // Pass the dictionary-related callbacks
            onChangeDictionary: _changeDictionary, // Pass the new method
            selectedDictionary: _selectedDictionary, // Pass the current state
            unlockItem: (itemName) => widget.unlockItem(itemName),
            isItemUnlocked: widget.isItemUnlocked,
            toggleFavorite: (itemName) => _toggleFavorite(itemName),
            filterItems: _filterItems,
            showUnlockDialog: (itemName) {
              // Find the item by name to pass to the dialog
              final allItems = DictionaryManager.getItems(_selectedDictionary);
              final item = allItems.firstWhere((i) => i.name == itemName,
                  orElse: () => allItems.first);
              _showUnlockDialog(item.name);
            },
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
