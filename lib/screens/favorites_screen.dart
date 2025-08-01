// lib/screens/favorites_screen.dart
import 'package:flutter/material.dart';
import 'detail_screen.dart';
import '../data/fruit_data.dart';

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
  bool _isNavBarCollapsed = false; // Track if the nav bar is collapsed

  @override
  void initState() {
    super.initState();
    _updateFavoriteFruits();
    _searchController.addListener(_filterFavorites);
  }

  @override
  void didUpdateWidget(covariant FavoritesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update favorites when the list changes
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
      // Clear selection if selected item is no longer in favorites
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
      // Clear selection if selected item is filtered out
      if (_selectedFruit != null &&
          !_favoriteFruits.any((fruit) => fruit.name == _selectedFruit!.name)) {
        _selectedFruit = null;
      }
    });
  }

  Future<void> _toggleFavorite(String itemName) async {
    // Call the callback to update global state
    if (widget.onToggleFavorite != null) {
      widget.onToggleFavorite!(itemName);
    }

    // Update local list immediately
    setState(() {
      _favoriteFruits.removeWhere((fruit) => fruit.name == itemName);
      // If this was the selected fruit, clear selection
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
          // Small screens (mobile) - keep original layout
          return _buildMobileLayout();
        } else {
          // Medium and Large screens (tablet/desktop) - new layout
          return _buildTabletDesktopLayout();
        }
      },
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        AppBar(
          title: const Text('Favorite Fruits'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            // Key icon with badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const Icon(Icons.key),
                  onPressed: () {
                    // Optional: Show key info
                  },
                ),
                if (widget.keys > 0)
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${widget.keys}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            IconButton(
              icon: Icon(
                Theme.of(context).brightness == Brightness.dark
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
              onPressed: widget.toggleTheme,
            ),
          ],
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search favorites...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (_) => _filterFavorites(),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _favoriteFruits.isEmpty
                      ? const Center(
                          child: Text(
                            'No favorite fruits yet',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(12),
                          itemCount: _favoriteFruits.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final FruitInfo fruit = _favoriteFruits[index];
                            final bool isUnlocked =
                                widget.isItemUnlocked(fruit.name);

                            return ListTile(
                              selected: _selectedFruit?.name == fruit.name,
                              selectedTileColor: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.1),
                              leading: const Icon(Icons.shopping_basket,
                                  color: Colors.green),
                              title: Text(
                                fruit.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${fruit.frenchTranslation} | ${fruit.arabicTranslation}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Lock icon - TAP THIS TO UNLOCK
                                  IconButton(
                                    icon: Icon(
                                      isUnlocked ? Icons.lock_open : Icons.lock,
                                      color: isUnlocked
                                          ? Colors.green
                                          : Colors.red,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      if (isUnlocked) {
                                        // Already unlocked - select for detail view
                                        _selectFruit(fruit);
                                      } else {
                                        // Not unlocked - show unlock dialog
                                        if (widget.keys > 0) {
                                          _showUnlockDialog(fruit.name);
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'No keys left! Get more keys to unlock items.'),
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 4),
                                  IconButton(
                                    icon: const Icon(Icons.favorite,
                                        color: Colors.red, size: 20),
                                    onPressed: () =>
                                        _toggleFavorite(fruit.name),
                                  ),
                                ],
                              ),
                              onTap: () {
                                // Main list item tap - behavior based on unlock state
                                if (isUnlocked) {
                                  // Already unlocked - select for detail view
                                  _selectFruit(fruit);
                                } else {
                                  // Not unlocked - show unlock first message
                                  _showUnlockFirstDialog();
                                }
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletDesktopLayout() {
    return Row(
      children: [
        // Vertical navigation bar
        Container(
          width: _isNavBarCollapsed ? 60 : 80,
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Column(
            children: [
              // Collapse/expand button
              IconButton(
                icon: Icon(_isNavBarCollapsed
                    ? Icons.arrow_forward
                    : Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _isNavBarCollapsed = !_isNavBarCollapsed;
                  });
                },
              ),
              if (!_isNavBarCollapsed) ...[
                const SizedBox(height: 20),
                // Navigation icons
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () => widget.onTabTapped(0),
                  color: widget.currentIndex == 0
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                const SizedBox(height: 20),
                IconButton(
                  icon: const Icon(Icons.home_outlined),
                  onPressed: () => widget.onTabTapped(1),
                  color: widget.currentIndex == 1
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                const SizedBox(height: 20),
                IconButton(
                  icon: const Icon(Icons.favorite_border),
                  onPressed: () => widget.onTabTapped(2),
                  color: widget.currentIndex == 2
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Main content area
        Expanded(
          child: Row(
            children: [
              // Left panel (search bar + favorite list)
              Expanded(
                flex: 2,
                child: Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Column(
                    children: [
                      // Search bar
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search favorites...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onChanged: (_) => _filterFavorites(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Favorite list
                      Expanded(
                        child: _favoriteFruits.isEmpty
                            ? const Center(
                                child: Text(
                                  'No favorite fruits yet',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.grey),
                                ),
                              )
                            : ListView.separated(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                itemCount: _favoriteFruits.length,
                                separatorBuilder: (_, __) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final FruitInfo fruit =
                                      _favoriteFruits[index];
                                  final bool isUnlocked =
                                      widget.isItemUnlocked(fruit.name);

                                  return ListTile(
                                    selected:
                                        _selectedFruit?.name == fruit.name,
                                    selectedTileColor: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.1),
                                    leading: const Icon(Icons.shopping_basket,
                                        color: Colors.green),
                                    title: Text(
                                      fruit.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${fruit.frenchTranslation} | ${fruit.arabicTranslation}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Lock icon - TAP THIS TO UNLOCK
                                        IconButton(
                                          icon: Icon(
                                            isUnlocked
                                                ? Icons.lock_open
                                                : Icons.lock,
                                            color: isUnlocked
                                                ? Colors.green
                                                : Colors.red,
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            if (isUnlocked) {
                                              // Already unlocked - select for detail view
                                              _selectFruit(fruit);
                                            } else {
                                              // Not unlocked - show unlock dialog
                                              if (widget.keys > 0) {
                                                _showUnlockDialog(fruit.name);
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'No keys left! Get more keys to unlock items.'),
                                                    duration:
                                                        Duration(seconds: 2),
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                        ),
                                        const SizedBox(width: 4),
                                        IconButton(
                                          icon: const Icon(Icons.favorite,
                                              color: Colors.red, size: 20),
                                          onPressed: () =>
                                              _toggleFavorite(fruit.name),
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      // Main list item tap - behavior based on unlock state
                                      if (isUnlocked) {
                                        // Already unlocked - select for detail view
                                        _selectFruit(fruit);
                                      } else {
                                        // Not unlocked - show unlock first message
                                        _showUnlockFirstDialog();
                                      }
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Right panel (app bar + view content)
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    // App bar
                    AppBar(
                      title: const Text('Favorite Fruits'),
                      backgroundColor:
                          Theme.of(context).colorScheme.inversePrimary,
                      actions: [
                        // Key icon with badge
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.key),
                              onPressed: () {
                                // Optional: Show key info
                              },
                            ),
                            if (widget.keys > 0)
                              Positioned(
                                right: 4,
                                top: 4,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Text(
                                    '${widget.keys}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(
                            Theme.of(context).brightness == Brightness.dark
                                ? Icons.light_mode
                                : Icons.dark_mode,
                          ),
                          onPressed: widget.toggleTheme,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // View content
                    Expanded(
                      child: Container(
                        color: Theme.of(context).colorScheme.surface,
                        child: _selectedFruit != null
                            ? DetailScreen(
                                fruit: _selectedFruit!,
                                isFavorite: true,
                                onToggleFavorite: (itemName) async {
                                  // Handle toggle from detail screen
                                  if (widget.onToggleFavorite != null) {
                                    widget.onToggleFavorite!(itemName);
                                  }
                                  // Refresh local list and clear selection if needed
                                  setState(() {
                                    _favoriteFruits.removeWhere(
                                        (fruit) => fruit.name == itemName);
                                    // Clear selection if this was the selected item
                                    if (_selectedFruit?.name == itemName) {
                                      _selectedFruit = null;
                                    }
                                  });
                                },
                                toggleTheme: widget.toggleTheme,
                              )
                            : const Center(
                                child: Text(
                                  'Select an item to view details',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.grey),
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
