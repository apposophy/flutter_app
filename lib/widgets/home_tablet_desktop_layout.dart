// lib/widgets/home_tablet_desktop_layout.dart
import 'package:flutter/material.dart';
import '../widgets/search_bar.dart'; // Adjust path if necessary
import '../widgets/home_vertical_divider.dart'; // Import the new divider widget
import '../widgets/collapsible_nav_item.dart'; // We'll create this next
import '../data/fruit_data.dart'; // Adjust path if necessary
import '../screens/detail_screen.dart'; // Adjust path if necessary

class HomeTabletDesktopLayout extends StatefulWidget {
  final List<FruitInfo> filteredItems;
  final List<String> favoriteItems;
  final TextEditingController searchController;
  final Function() toggleTheme;
  final int keys;
  final Function(String) unlockItem;
  final Function(String) isItemUnlocked;
  final Function(String) toggleFavorite;
  final Function() filterItems;
  final Function(FruitInfo) showUnlockDialog;
  final Function() showUnlockFirstDialog;
  final void Function(FruitInfo) selectFruit;
  //final Function(FruitInfo?) selectFruit; // To update selected fruit
  final FruitInfo? selectedFruit; // Current selected fruit
  final int currentIndex;
  final Function(int) onTabTapped;
  final double initialLeftPanelWidth;
  final double minLeftPanelWidth;
  final double maxLeftPanelWidth;
  final bool isNavBarCollapsed;

  const HomeTabletDesktopLayout({
    super.key,
    required this.filteredItems,
    required this.favoriteItems,
    required this.searchController,
    required this.toggleTheme,
    required this.keys,
    required this.unlockItem,
    required this.isItemUnlocked,
    required this.toggleFavorite,
    required this.filterItems,
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
  State<HomeTabletDesktopLayout> createState() =>
      _HomeTabletDesktopLayoutState();
}

class _HomeTabletDesktopLayoutState extends State<HomeTabletDesktopLayout> {
  late bool _isNavBarCollapsed;
  late double _leftPanelWidth;

  @override
  void initState() {
    super.initState();
    // Initialize state from widget parameters or defaults
    _isNavBarCollapsed =
        true; // Default state, could be passed as a parameter if needed
    _leftPanelWidth = widget.initialLeftPanelWidth;
  }

  void _updateLeftPanelWidth(double newWidth) {
    setState(() {
      _leftPanelWidth = newWidth;
    });
  }

  void _toggleNavBarCollapse() {
    setState(() {
      _isNavBarCollapsed = !_isNavBarCollapsed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Vertical navigation bar
        Container(
          width: _isNavBarCollapsed ? 60 : 150,
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Column(
            children: [
              // Collapse/expand button
              IconButton(
                icon: Icon(_isNavBarCollapsed
                    ? Icons.arrow_forward
                    : Icons.arrow_back),
                onPressed: _toggleNavBarCollapse,
              ),
              if (!_isNavBarCollapsed) ...[
                const SizedBox(height: 20),
                CollapsibleNavItem(
                  // Use the new widget
                  icon: Icons.info_outline,
                  label: 'Info',
                  isActive: widget.currentIndex == 0,
                  onTap: () => widget.onTabTapped(0),
                  isCollapsed: _isNavBarCollapsed,
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
        // Left panel with draggable width
        SizedBox(
          width: _leftPanelWidth,
          child: Container(
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: FruitSearchBar(
                    controller: widget.searchController,
                    onChanged: (_) => widget.filterItems(),
                  ),
                ),
                const SizedBox(height: 12),
                // Item list
                Expanded(
                  child: widget.filteredItems.isEmpty
                      ? const Center(
                          child: Text(
                            'No fruits found',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          itemCount: widget.filteredItems.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final FruitInfo fruit = widget.filteredItems[index];
                            final bool isFavorite =
                                widget.favoriteItems.contains(fruit.name);
                            final bool isUnlocked =
                                widget.isItemUnlocked(fruit.name);
                            return ListTile(
                              selected:
                                  widget.selectedFruit?.name == fruit.name,
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
                                      isUnlocked ? Icons.lock_open : Icons.lock,
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
                                          widget.showUnlockDialog(fruit);
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
                                    padding: const EdgeInsets.all(4),
                                    splashRadius: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  IconButton(
                                    icon: Icon(
                                      isFavorite
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: isFavorite ? Colors.red : null,
                                      size: 20,
                                    ),
                                    onPressed: () =>
                                        widget.toggleFavorite(fruit.name),
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
                                  widget.showUnlockFirstDialog();
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
          // Use the new widget
          minPanelWidth: widget.minLeftPanelWidth,
          maxPanelWidth: widget.maxLeftPanelWidth,
          currentPanelWidth: _leftPanelWidth,
          onWidthChanged: _updateLeftPanelWidth,
        ),
        const SizedBox(width: 16),
        // Right panel (app bar + view content)
        Expanded(
          child: Column(
            children: [
              // App bar
              AppBar(
                title: const Text('Fruit Dictionary'),
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
              // View content
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.surface,
                  child: widget.selectedFruit != null
                      ? DetailScreen(
                          fruit: widget.selectedFruit!,
                          isFavorite: widget.favoriteItems
                              .contains(widget.selectedFruit!.name),
                          onToggleFavorite: (itemName) =>
                              widget.toggleFavorite(itemName), // Wrap
                          toggleTheme: widget.toggleTheme,
                        )
                      : const Center(
                          child: Text(
                            'Select an item to view details',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
