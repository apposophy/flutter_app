// lib/widgets/home_tablet_desktop_layout.dart
import 'package:flutter/material.dart';
import '../widgets/search_bar.dart'; // Assuming this exists and is compatible
import '../widgets/home_vertical_divider.dart'; // Assuming this exists
import '../widgets/collapsible_nav_item.dart'; // Assuming this exists
import '../data/dictionary_item.dart'; // Import the base class
import '../data/dictionary_manager.dart'; // Import the manager
import '../screens/detail_screen.dart'; // Assuming this exists

class HomeTabletDesktopLayout extends StatefulWidget {
  // 1. Update parameters to use DictionaryItem types
  final List<DictionaryItem> filteredItems; // Changed from List<FruitInfo>
  final List<String> favoriteItems;
  final TextEditingController searchController;
  final Function() toggleTheme;
  final int keys;
  final Function(String) unlockItem; // Takes item name
  final Function(String) isItemUnlocked; // Takes item name, returns bool
  final Function(String) toggleFavorite; // Takes item name
  final Function() filterItems; // Trigger search/filter
  final Function(String) showUnlockDialog; // Takes item name
  final Function() showUnlockFirstDialog;
  final Function(DictionaryItem) selectFruit; // Takes DictionaryItem
  final DictionaryItem? selectedFruit; // Nullable DictionaryItem
  final int currentIndex;
  final Function(int) onTabTapped;
  final double initialLeftPanelWidth;
  final double minLeftPanelWidth;
  final double maxLeftPanelWidth;
  final bool isNavBarCollapsed;

  // 2. Add new parameters for dictionary selection
  final Function(DictionaryType)
      onChangeDictionary; // Callback for dictionary change
  final DictionaryType selectedDictionary; // Current selected dictionary

  const HomeTabletDesktopLayout({
    super.key,
    required this.filteredItems, // Changed type
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
    required this.selectFruit, // Changed type
    required this.selectedFruit, // Changed type
    required this.currentIndex,
    required this.onTabTapped,
    required this.initialLeftPanelWidth,
    required this.minLeftPanelWidth,
    required this.maxLeftPanelWidth,
    required this.isNavBarCollapsed,
    // 3. Add new parameters to constructor
    required this.onChangeDictionary, // Add this
    required this.selectedDictionary, // Add this
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
    _isNavBarCollapsed = widget.isNavBarCollapsed;
    _leftPanelWidth = widget.initialLeftPanelWidth;
  }

  @override
  void didUpdateWidget(covariant HomeTabletDesktopLayout oldWidget) {
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
          width: _isNavBarCollapsed ? 60 : 150, // Adjusted width for labels
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
                  // Assuming this widget exists and is compatible
                  icon: Icons.info_outline,
                  label: 'Info',
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
              // Left panel (search bar + item list) with draggable width
              SizedBox(
                width: _leftPanelWidth,
                child: Container(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceVariant, // Or any desired background
                  child: Column(
                    children: [
                      // 4. Add Dropdown for dictionary selection
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: DropdownButton<DictionaryType>(
                          value: widget.selectedDictionary, // Use passed state
                          items: DictionaryManager.getAvailableDictionaries()
                              .map((DictionaryType type) {
                            return DropdownMenuItem<DictionaryType>(
                              value: type,
                              child:
                                  Text(DictionaryManager.getDisplayName(type)),
                            );
                          }).toList(),
                          onChanged: (DictionaryType? newValue) {
                            if (newValue != null) {
                              // 5. Call the callback when selection changes
                              widget.onChangeDictionary(newValue);
                            }
                          },
                          isExpanded: true, // Take full width
                          underline: Container(), // Remove default underline
                          borderRadius: BorderRadius.circular(10),
                          icon: const Icon(Icons.arrow_drop_down),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Search bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: FruitSearchBar(
                          // Assuming this widget exists and is compatible
                          controller: widget.searchController,
                          onChanged: (_) =>
                              widget.filterItems(), // Trigger filtering
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Item list
                      Expanded(
                        child: widget.filteredItems
                                .isEmpty // Use DictionaryItem list
                            ? const Center(
                                child: Text(
                                  'No items found',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.grey),
                                ),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0),
                                itemCount: widget.filteredItems
                                    .length, // Iterate over DictionaryItem list
                                separatorBuilder: (_, __) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  // 6. Cast item to DictionaryItem
                                  final DictionaryItem item =
                                      widget.filteredItems[index];
                                  final bool isFavorite =
                                      widget.favoriteItems.contains(item.name);
                                  final bool isUnlocked = widget.isItemUnlocked(
                                      item.name); // Check unlock status

                                  return ListTile(
                                    selected: widget.selectedFruit?.name ==
                                        item.name, // Check selection
                                    selectedTileColor: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.1),
                                    leading: const Icon(Icons.shopping_basket,
                                        color: Colors.green),
                                    // 7. Use DictionaryItem properties
                                    title: Text(
                                      item.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${item.frenchTranslation} | ${item.arabicTranslation}',
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
                                              // Already unlocked - select for detail view in parent
                                              widget.selectFruit(
                                                  item); // Pass DictionaryItem
                                            } else {
                                              // Not unlocked - show unlock dialog
                                              if (widget.keys > 0) {
                                                widget.showUnlockDialog(item
                                                    .name); // Pass item name
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
                                          icon: Icon(
                                            isFavorite
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color:
                                                isFavorite ? Colors.red : null,
                                            size: 20,
                                          ),
                                          onPressed: () =>
                                              widget.toggleFavorite(
                                                  item.name), // Pass item name
                                          padding: const EdgeInsets.all(4),
                                          splashRadius: 18,
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      // Main list item tap - behavior based on unlock state
                                      if (isUnlocked) {
                                        // Already unlocked - select for detail view in parent
                                        widget.selectFruit(
                                            item); // Pass DictionaryItem
                                      } else {
                                        // Not unlocked - show unlock first message
                                        widget
                                            .showUnlockFirstDialog(); // Show the dialog
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
                // Assuming this widget exists and is compatible
                minPanelWidth: widget.minLeftPanelWidth,
                maxPanelWidth: widget.maxLeftPanelWidth,
                currentPanelWidth: _leftPanelWidth,
                onWidthChanged: _updateLeftPanelWidth,
              ),
              const SizedBox(width: 16),
              // Right panel (app bar + view content)
              Expanded(
                flex: 3, // Adjust flex as needed for desired width ratio
                child: Column(
                  children: [
                    // App bar
                    AppBar(
                      title: const Text('Dictionary'), // Generic title
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
                        child: widget.selectedFruit !=
                                null // Check if an item is selected
                            ? DetailScreen(
                                // Assuming DetailScreen can handle DictionaryItem data
                                // or you adapt the data passed here.
                                fruit: widget
                                    .selectedFruit!, // Pass selected DictionaryItem
                                isFavorite: widget.favoriteItems.contains(widget
                                    .selectedFruit!
                                    .name), // Check favorite status
                                onToggleFavorite:
                                    widget.toggleFavorite, // Pass the callback
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
