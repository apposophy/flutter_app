// lib/screens/main_screen.dart
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'favorites_screen.dart';
// 1. Import the new UnlockedItemsScreen
import 'unlocked_items_screen.dart'; // Adjust the path if necessary
import '../data/fruit_data.dart';

class MainScreen extends StatefulWidget {
  final Function() toggleTheme;
  final bool isDarkMode;
  final int keys;
  final Function(String) unlockItem;
  final Function() resetKeys;
  final Function(String) isItemUnlocked;
  // Assuming you have a way to get/set unlocked items in MyAppState
  // For example, passing the Set and a function to check
  final Set<String> unlockedItems; // Pass the Set of unlocked item names
  final Function() resetAllUnlocks;

  const MainScreen({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
    required this.keys,
    required this.unlockItem,
    required this.resetKeys,
    required this.isItemUnlocked,
    required this.unlockedItems, // Add this parameter
    required this.resetAllUnlocks,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 1; // Home is default (middle)
  List<String> _favoriteItems = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favorites = await FruitData.loadFavorites();
    setState(() {
      _favoriteItems = favorites;
    });
  }

  Future<void> _toggleFavorite(String item) async {
    // Load current favorites
    List<String> favorites = await FruitData.loadFavorites();

    // Toggle the item
    if (favorites.contains(item)) {
      favorites.remove(item);
    } else {
      favorites.add(item);
    }

    // Save updated favorites
    await FruitData.saveFavorites(favorites);

    // Update state
    setState(() {
      _favoriteItems = favorites;
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          // Small screens (mobile) - Show navigation bar here
          return _buildMobileLayout();
        } else {
          // Medium and Large screens (tablet/desktop) - Let child screens handle layout
          return _buildTabletDesktopLayout();
        }
      },
    );
  }

  Widget _buildMobileLayout() {
    // Current screen based on index (without its own BottomNavigationBar)
    Widget currentScreen;
    switch (_currentIndex) {
      case 0:
        // 2. Use UnlockedItemsScreen instead of InfoScreen
        currentScreen = UnlockedItemsScreen(
          // 3. Pass the correct parameters expected by UnlockedItemsScreen
          unlockedItemNames: widget.unlockedItems, // Pass the Set
          isItemUnlocked: widget.isItemUnlocked, // Pass the check function
          toggleTheme: widget.toggleTheme,
          keys: widget.keys,
          currentIndex:
              _currentIndex, // Might be needed if UnlockedScreen has nav logic
          onTabTapped:
              _onTabTapped, // Might be needed if UnlockedScreen has nav logic
          favoriteItems: _favoriteItems,
          onToggleFavorite: _toggleFavorite,
        );
        break;
      case 1:
        currentScreen = HomeScreen(
          onFavoritesUpdated: (favorites) {
            setState(() {
              _favoriteItems = favorites;
            });
          },
          toggleTheme: widget.toggleTheme,
          keys: widget.keys,
          unlockItem: widget.unlockItem,
          isItemUnlocked: widget.isItemUnlocked,
          // Pass null or dummy values for nav related params not used in mobile layout
          currentIndex: _currentIndex,
          onTabTapped: _onTabTapped,
        );
        break;
      case 2:
        currentScreen = FavoritesScreen(
          favoriteItems: _favoriteItems,
          onToggleFavorite: _toggleFavorite,
          toggleTheme: widget.toggleTheme,
          keys: widget.keys,
          unlockItem: widget.unlockItem,
          isItemUnlocked: widget.isItemUnlocked,
          // Pass null or dummy values for nav related params not used in mobile layout
          currentIndex: _currentIndex,
          onTabTapped: _onTabTapped,
        );
        break;
      default:
        // 4. Default to UnlockedItemsScreen or HomeScreen
        currentScreen = UnlockedItemsScreen(
          unlockedItemNames: widget.unlockedItems,
          isItemUnlocked: widget.isItemUnlocked,
          toggleTheme: widget.toggleTheme,
          keys: widget.keys,
          currentIndex: _currentIndex,
          onTabTapped: _onTabTapped,
          favoriteItems: _favoriteItems,
          onToggleFavorite: _toggleFavorite,
        );
    }

    return Scaffold(
      body: currentScreen,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        items: [
          // 5. Update label and icon for Unlocked Items
          const BottomNavigationBarItem(
            icon: Icon(Icons.lock_open), // Use lock_open icon
            activeIcon: Icon(Icons.lock_open), // Use lock_open icon
            label: 'Unlocked', // Update label
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: _buildFavoriteIconWithBadge(
                active: false), // Use the badge method
            activeIcon: _buildFavoriteIconWithBadge(
                active: true), // Use the badge method
            label: 'Favorites',
          ),
        ],
      ),
    );
  }

  Widget _buildTabletDesktopLayout() {
    // Current screen based on index (expects its own layout handling)
    Widget currentScreen;
    switch (_currentIndex) {
      case 0:
        // 6. Use UnlockedItemsScreen instead of InfoScreen
        currentScreen = UnlockedItemsScreen(
          // 7. Pass the correct parameters expected by UnlockedItemsScreen
          unlockedItemNames: widget.unlockedItems,
          isItemUnlocked: widget.isItemUnlocked,
          toggleTheme: widget.toggleTheme,
          keys: widget.keys,
          currentIndex: _currentIndex,
          onTabTapped: _onTabTapped,
          favoriteItems: _favoriteItems,
          onToggleFavorite: _toggleFavorite,
        );
        break;
      case 1:
        currentScreen = HomeScreen(
          onFavoritesUpdated: (favorites) {
            setState(() {
              _favoriteItems = favorites;
            });
          },
          toggleTheme: widget.toggleTheme,
          keys: widget.keys,
          unlockItem: widget.unlockItem,
          isItemUnlocked: widget.isItemUnlocked,
          currentIndex: _currentIndex,
          onTabTapped: _onTabTapped,
        );
        break;
      case 2:
        currentScreen = FavoritesScreen(
          favoriteItems: _favoriteItems,
          onToggleFavorite: _toggleFavorite,
          toggleTheme: widget.toggleTheme,
          keys: widget.keys,
          unlockItem: widget.unlockItem,
          isItemUnlocked: widget.isItemUnlocked,
          currentIndex: _currentIndex,
          onTabTapped: _onTabTapped,
        );
        break;
      default:
        currentScreen = UnlockedItemsScreen(
          unlockedItemNames: widget.unlockedItems,
          isItemUnlocked: widget.isItemUnlocked,
          toggleTheme: widget.toggleTheme,
          keys: widget.keys,
          currentIndex: _currentIndex,
          onTabTapped: _onTabTapped,
          favoriteItems: _favoriteItems,
          onToggleFavorite: _toggleFavorite,
        );
    }

    return Scaffold(
      body: currentScreen,
      // No BottomNavigationBar for tablet/desktop
    );
  }

  Widget _buildFavoriteIconWithBadge({bool active = false}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          active ? Icons.favorite : Icons.favorite_border,
        ),
        if (_favoriteItems.isNotEmpty)
          Positioned(
            right: -6, // Adjusted position for BottomNavigationBar icon size
            top: -3,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                '${_favoriteItems.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10, // Adjusted font size
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
