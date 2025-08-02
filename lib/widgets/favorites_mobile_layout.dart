// lib/widgets/favorites_mobile_layout.dart
import 'package:flutter/material.dart';
import '../data/fruit_data.dart';
import '../screens/detail_screen.dart';

class FavoritesMobileLayout extends StatelessWidget {
  final List<FruitInfo> favoriteFruits;
  final TextEditingController searchController;
  final VoidCallback toggleTheme; // Changed type for clarity
  final int keys;
  final Function(FruitInfo)
      selectFruit; // For navigating/tapping unlocked items
  final Function(String)
      showUnlockDialog; // Takes item name to show unlock dialog
  final VoidCallback showUnlockFirstDialog; // For prompting to unlock first
  final Function(String) toggleFavorite; // Takes item name to remove favorite
  final VoidCallback filterFavorites; // Trigger search/filter
  final FruitInfo? selectedFruit;
  // Function to check if an item is unlocked
  final Function(String) isItemUnlocked;
  // Add the missing showSnackbar function or handle snackbar logic via a callback
  // For now, let's add a simple snackbar callback
  final Function(String)
      showSnackbar; // e.g., (message) => ScaffoldMessenger.of(context).showSnackBar(...)

  const FavoritesMobileLayout({
    super.key,
    required this.favoriteFruits,
    required this.searchController,
    required this.toggleTheme,
    required this.keys,
    required this.selectFruit,
    required this.showUnlockDialog,
    required this.showUnlockFirstDialog,
    required this.toggleFavorite,
    required this.filterFavorites,
    this.selectedFruit,
    required this.isItemUnlocked,
    required this.showSnackbar, // Add this parameter
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          title: const Text('Favorite Fruits'),
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
                if (keys > 0)
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
                        '$keys',
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
              onPressed: toggleTheme,
            ),
          ],
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search favorites...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (_) => filterFavorites(),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: favoriteFruits.isEmpty
                      ? const Center(
                          child: Text(
                            'No favorite fruits yet',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(12),
                          itemCount: favoriteFruits.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final FruitInfo fruit = favoriteFruits[index];
                            // 1. Check if the item is unlocked
                            final bool isUnlocked = isItemUnlocked(fruit.name);
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
                              // 2. Update trailing to include both icons
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Lock icon - TAP THIS TO UNLOCK/VIEW
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
                                        selectFruit(fruit);
                                      } else {
                                        // Not unlocked - show unlock dialog
                                        if (keys > 0) {
                                          // Call the callback to show the unlock dialog
                                          showUnlockDialog(fruit.name);
                                        } else {
                                          // Show snackbar if no keys left
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
                                  // Favorite icon - TAP THIS TO REMOVE FROM FAVORITES
                                  IconButton(
                                    icon: const Icon(Icons.favorite,
                                        color: Colors.red, size: 20),
                                    onPressed: () => toggleFavorite(fruit.name),
                                    padding: const EdgeInsets.all(4),
                                    splashRadius: 18,
                                  ),
                                ],
                              ),
                              // 3. Main item tap behavior (consistent with tablet/desktop & original)
                              onTap: () {
                                // Main list item tap - behavior based on unlock state
                                if (isUnlocked) {
                                  // Use the already determined isUnlocked value
                                  // Already unlocked - go directly to detail page (like HomeScreen)
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailScreen(
                                        fruit: fruit,
                                        // It's a favorite item.
                                        isFavorite: true, // Default to true
                                        onToggleFavorite: (itemName) {
                                          // Call the passed toggle function (likely _toggleFavorite from parent)
                                          toggleFavorite(itemName);
                                          // The DetailScreen handles its internal UI update.
                                          // The parent screen (_FavoritesScreenState) handles updating _favoriteFruits.
                                        },
                                        toggleTheme:
                                            toggleTheme, // Pass the theme toggle function
                                      ),
                                    ),
                                  );
                                  // No need for .then() here as _toggleFavorite handles local state update
                                } else {
                                  // Not unlocked - show unlock first message
                                  showUnlockFirstDialog(); // Use the passed callback
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
}
