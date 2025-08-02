// lib/widgets/favorites_tablet_desktop_layout.dart
import 'package:flutter/material.dart';
import 'home_vertical_divider.dart'; // Reuse the divider widget
import 'collapsible_nav_item.dart'; // Reuse the nav item widget
import '../data/fruit_data.dart'; // Adjust import path if needed
import '../screens/detail_screen.dart'; // Adjust import path if needed

class FavoritesTabletDesktopLayout extends StatefulWidget {
  final List<FruitInfo> favoriteFruits;
  final TextEditingController searchController;
  final Function() toggleTheme;
  final int keys;
  final Function(String) unlockItem; // For unlock dialog
  final Function(String) isItemUnlocked;
  final Function(String) toggleFavorite; // Remove from favorites
  final Function() filterFavorites;
  final Function(String) showUnlockDialog; // Show dialog for specific fruit
  final Function() showUnlockFirstDialog;
  final Function(FruitInfo) selectFruit; // Update selected fruit in parent
  final FruitInfo? selectedFruit; // Currently selected fruit
  final int currentIndex;
  final Function(int) onTabTapped;
  final double initialLeftPanelWidth;
  final double minLeftPanelWidth;
  final double maxLeftPanelWidth;
  final bool isNavBarCollapsed; // Initial collapse state

  const FavoritesTabletDesktopLayout({
    super.key,
    required this.favoriteFruits,
    required this.searchController,
    required this.toggleTheme,
    required this.keys,
    required this.unlockItem,
    required this.isItemUnlocked,
    required this.toggleFavorite,
    required this.filterFavorites,
    required this.showUnlockDialog,
    required this.showUnlockFirstDialog,
    required this.selectFruit,
    required this.selectedFruit,
    required this.currentIndex,
    required this.onTabTapped,
    required this.initialLeftPanelWidth,
    required this.minLeftPanelWidth,
    required this.maxLeftPanelWidth,
    required this.isNavBarCollapsed,
  });

  @override
  State<FavoritesTabletDesktopLayout> createState() =>
      _FavoritesTabletDesktopLayoutState();
}

class _FavoritesTabletDesktopLayoutState
    extends State<FavoritesTabletDesktopLayout> {
  late bool _isNavBarCollapsed;
  late double _leftPanelWidth;

  @override
  void initState() {
    super.initState();
    _isNavBarCollapsed = widget.isNavBarCollapsed;
    _leftPanelWidth = widget.initialLeftPanelWidth;
  }

  @override
  void didUpdateWidget(covariant FavoritesTabletDesktopLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync collapse state if it changes from parent (optional but robust)
    if (oldWidget.isNavBarCollapsed != widget.isNavBarCollapsed) {
      setState(() {
        _isNavBarCollapsed = widget.isNavBarCollapsed;
      });
    }
  }

  void _toggleNavBarCollapse() {
    setState(() {
      _isNavBarCollapsed = !_isNavBarCollapsed;
    });
  }

  void _updateLeftPanelWidth(double newWidth) {
    setState(() {
      _leftPanelWidth = newWidth;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Vertical navigation bar
        Container(
          width: _isNavBarCollapsed
              ? 60
              : 150, // Match FavoritesScreen original width
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Column(
            children: [
              IconButton(
                icon: Icon(_isNavBarCollapsed
                    ? Icons.arrow_forward
                    : Icons.arrow_back),
                onPressed: _toggleNavBarCollapse,
              ),
              if (!_isNavBarCollapsed) ...[
                const SizedBox(height: 20),
                CollapsibleNavItem(
                  icon: Icons.lock_open,
                  label: 'Unlocked',
                  isActive: widget.currentIndex == 0,
                  onTap: () => widget.onTabTapped(0),
                  isCollapsed: _isNavBarCollapsed, // Pass current state
                ),
                const SizedBox(height: 20),
                CollapsibleNavItem(
                  icon: Icons.home_outlined,
                  label: 'Home',
                  isActive: widget.currentIndex == 1,
                  onTap: () => widget.onTabTapped(1),
                  isCollapsed: _isNavBarCollapsed,
                ),
                const SizedBox(height: 20),
                CollapsibleNavItem(
                  icon: Icons.favorite_border,
                  label: 'Favorites',
                  isActive: widget.currentIndex == 2,
                  onTap: () => widget.onTabTapped(2),
                  isCollapsed: _isNavBarCollapsed,
                ),
              ] else ...[
                const SizedBox(height: 20),
                IconButton(
                  icon: Icon(
                    Icons.info_outline,
                    color: widget.currentIndex == 0
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  onPressed: () => widget.onTabTapped(0),
                ),
                const SizedBox(height: 20),
                IconButton(
                  icon: Icon(
                    Icons.home_outlined,
                    color: widget.currentIndex == 1
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  onPressed: () => widget.onTabTapped(1),
                ),
                const SizedBox(height: 20),
                IconButton(
                  icon: Icon(
                    Icons.favorite_border,
                    color: widget.currentIndex == 2
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  onPressed: () => widget.onTabTapped(2),
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
              SizedBox(
                // Use SizedBox for fixed width
                width: _leftPanelWidth,
                child: Container(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest, // Match original
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: TextField(
                          controller: widget.searchController,
                          decoration: InputDecoration(
                            hintText: 'Search favorites...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onChanged: (_) => widget.filterFavorites(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: widget.favoriteFruits.isEmpty
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
                                itemCount: widget.favoriteFruits.length,
                                separatorBuilder: (_, __) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final FruitInfo fruit =
                                      widget.favoriteFruits[index];
                                  final bool isUnlocked =
                                      widget.isItemUnlocked(fruit.name);
                                  return ListTile(
                                    selected: widget.selectedFruit?.name ==
                                        fruit.name,
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
                                              widget.selectFruit(
                                                  fruit); // Update selection in parent
                                            } else {
                                              if (widget.keys > 0) {
                                                widget.showUnlockDialog(fruit
                                                    .name); // Show unlock dialog
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
                                          padding: const EdgeInsets.all(4),
                                          splashRadius: 18,
                                        ),
                                        const SizedBox(width: 4),
                                        IconButton(
                                          icon: const Icon(Icons.favorite,
                                              color: Colors.red, size: 20),
                                          onPressed: () =>
                                              widget.toggleFavorite(fruit
                                                  .name), // Remove favorite
                                          padding: const EdgeInsets.all(4),
                                          splashRadius: 18,
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      if (isUnlocked) {
                                        widget.selectFruit(
                                            fruit); // Update selection in parent
                                      } else {
                                        widget
                                            .showUnlockFirstDialog(); // Prompt to unlock via lock icon
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
              // Draggable divider
              HomeVerticalDivider(
                minPanelWidth: widget.minLeftPanelWidth,
                maxPanelWidth: widget.maxLeftPanelWidth,
                currentPanelWidth: _leftPanelWidth,
                onWidthChanged: _updateLeftPanelWidth,
              ),
              const SizedBox(width: 16),
              // Right panel (app bar + view content)
              Expanded(
                flex: 3, // Adjust flex as needed
                child: Column(
                  children: [
                    AppBar(
                      title: const Text('Favorite Fruits'),
                      backgroundColor:
                          Theme.of(context).colorScheme.inversePrimary,
                      actions: [
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
                    Expanded(
                      child: Container(
                        color: Theme.of(context).colorScheme.surface,
                        child: widget.selectedFruit != null
                            ? DetailScreen(
                                fruit: widget.selectedFruit!,
                                isFavorite: true, // It's in the favorites list
                                onToggleFavorite: (itemName) {
                                  // Handle toggle from detail screen (remove from favorites)
                                  widget.toggleFavorite(itemName);
                                  // The parent screen's _toggleFavorite already handles
                                  // updating _favoriteFruits and clearing _selectedFruit if needed.
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
