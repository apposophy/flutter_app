// lib/screens/unlocked_items_screen.dart
import 'package:flutter/material.dart';
import '../data/fruit_data.dart';
import 'detail_screen.dart';
import '../widgets/home_vertical_divider.dart'; // Import the divider

class UnlockedItemsScreen extends StatefulWidget {
  // Receive favorite items list and toggle function
  final List<String> favoriteItems; // Add this
  final Function(String) onToggleFavorite; // Add this
  final Set<String> unlockedItemNames;
  final Function(String) isItemUnlocked;
  final Function() toggleTheme;
  final int keys;
  final int currentIndex;
  final Function(int) onTabTapped;

  const UnlockedItemsScreen({
    super.key,
    required this.favoriteItems, // Add this
    required this.onToggleFavorite, // Add this
    required this.unlockedItemNames,
    required this.isItemUnlocked,
    required this.toggleTheme,
    required this.keys,
    required this.currentIndex,
    required this.onTabTapped,
  });

  @override
  State<UnlockedItemsScreen> createState() => _UnlockedItemsScreenState();
}

class _UnlockedItemsScreenState extends State<UnlockedItemsScreen> {
  late List<FruitInfo> _unlockedFruits;
  final TextEditingController _searchController = TextEditingController();
  FruitInfo? _selectedFruit;
  bool _isNavBarCollapsed = false;
  double _leftPanelWidth = 300.0;
  static const double _minLeftPanelWidth = 250.0;
  static const double _maxLeftPanelWidth = 500.0;

  @override
  void initState() {
    super.initState();
    _updateUnlockedFruits();
    _searchController.addListener(_filterUnlockedFruits);
  }

  @override
  void didUpdateWidget(covariant UnlockedItemsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.unlockedItemNames != oldWidget.unlockedItemNames ||
        widget.favoriteItems != oldWidget.favoriteItems) {
      // Add favoriteItems check
      _updateUnlockedFruits();
    }
  }

  void _updateUnlockedFruits() {
    setState(() {
      _unlockedFruits = FruitData.fruits
          .where((fruit) => widget.unlockedItemNames.contains(fruit.name))
          .toList();
      if (_selectedFruit != null &&
          !widget.unlockedItemNames.contains(_selectedFruit!.name)) {
        _selectedFruit = null;
      }
    });
  }

  void _filterUnlockedFruits() {
    final String query = _searchController.text.toLowerCase();
    setState(() {
      _unlockedFruits = FruitData.fruits
          .where((fruit) =>
              widget.unlockedItemNames.contains(fruit.name) &&
              (fruit.name.toLowerCase().contains(query) ||
                  fruit.frenchTranslation.toLowerCase().contains(query) ||
                  fruit.arabicTranslation.toLowerCase().contains(query)))
          .toList();
      if (_selectedFruit != null &&
          !_unlockedFruits.any((fruit) => fruit.name == _selectedFruit!.name)) {
        _selectedFruit = null;
      }
    });
  }

  void _selectFruit(FruitInfo fruit) {
    setState(() {
      _selectedFruit = fruit;
    });
  }

  // Add method to update left panel width
  void _updateLeftPanelWidth(double newWidth) {
    setState(() {
      _leftPanelWidth = newWidth;
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterUnlockedFruits);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return _buildMobileLayout(context);
        } else {
          return _buildTabletDesktopLayout(context);
        }
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        AppBar(
          title: const Text('Unlocked Fruits'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const Icon(Icons.key),
                  onPressed: () {},
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
                    hintText: 'Search unlocked fruits...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (_) => _filterUnlockedFruits(),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _unlockedFruits.isEmpty
                      ? const Center(
                          child: Text(
                            'No unlocked fruits yet',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(12),
                          itemCount: _unlockedFruits.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final FruitInfo fruit = _unlockedFruits[index];
                            // Determine if the item is a favorite
                            final bool isFavorite = widget.favoriteItems
                                .contains(fruit.name); // Use passed list
                            return ListTile(
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
                              // Show lock icon and favorite icon
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.lock_open,
                                      color: Colors.green, size: 20),
                                  const SizedBox(width: 4),
                                  IconButton(
                                    icon: Icon(
                                      isFavorite
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: isFavorite ? Colors.red : null,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      // Call the passed toggle function
                                      widget.onToggleFavorite(fruit.name);
                                    },
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailScreen(
                                      fruit: fruit,
                                      isFavorite:
                                          isFavorite, // Pass favorite status
                                      onToggleFavorite: widget
                                          .onToggleFavorite, // Pass toggle function
                                      toggleTheme: widget.toggleTheme,
                                    ),
                                  ),
                                );
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

  Widget _buildTabletDesktopLayout(BuildContext context) {
    return Row(
      children: [
        // Vertical navigation bar
        Container(
          width: _isNavBarCollapsed ? 60 : 80,
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Column(
            children: [
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
              ] else ...[
                const SizedBox(height: 20),
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
              // Left panel (search bar + unlocked list)
              SizedBox(
                width: _leftPanelWidth,
                child: Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search unlocked fruits...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onChanged: (_) => _filterUnlockedFruits(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: _unlockedFruits.isEmpty
                            ? const Center(
                                child: Text(
                                  'No unlocked fruits yet',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.grey),
                                ),
                              )
                            : ListView.separated(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                itemCount: _unlockedFruits.length,
                                separatorBuilder: (_, __) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final FruitInfo fruit =
                                      _unlockedFruits[index];
                                  // Determine if the item is a favorite
                                  final bool isFavorite = widget.favoriteItems
                                      .contains(fruit.name); // Use passed list
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
                                    // Show lock icon and favorite icon
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.lock_open,
                                            color: Colors.green, size: 20),
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
                                          onPressed: () {
                                            // Call the passed toggle function
                                            widget.onToggleFavorite(fruit.name);
                                          },
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      _selectFruit(fruit);
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
                minPanelWidth: _minLeftPanelWidth,
                maxPanelWidth: _maxLeftPanelWidth,
                currentPanelWidth: _leftPanelWidth,
                onWidthChanged: _updateLeftPanelWidth,
              ),
              const SizedBox(width: 16),
              // Right panel (app bar + view content)
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    AppBar(
                      title: const Text('Unlocked Fruits'),
                      backgroundColor:
                          Theme.of(context).colorScheme.inversePrimary,
                      actions: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.key),
                              onPressed: () {},
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
                        child: _selectedFruit != null
                            ? DetailScreen(
                                fruit: _selectedFruit!,
                                isFavorite: widget.favoriteItems.contains(
                                    _selectedFruit!
                                        .name), // Pass favorite status
                                onToggleFavorite: widget
                                    .onToggleFavorite, // Pass toggle function
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
