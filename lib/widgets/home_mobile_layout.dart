// lib/widgets/home_mobile_layout.dart
import 'package:flutter/material.dart';
import '../widgets/search_bar.dart'; // Adjust path if necessary
import '../data/fruit_data.dart'; // Adjust path if necessary
import '../screens/detail_screen.dart'; // Adjust path if necessary

// Assuming HomeScreenWidgetParams is defined elsewhere or pass parameters directly
class HomeMobileLayout extends StatelessWidget {
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
  final Future<void> Function() loadFavorites;
  //final Function(FruitInfo)
  // loadFavorites; // Consider if this needs to be passed or handled differently

  const HomeMobileLayout({
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
    required this.loadFavorites, // Consider if this needs to be passed or handled differently
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          title: const Text('Fruit Dictionary'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            // Key icon with badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const Icon(Icons.key_outlined),
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
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
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
                FruitSearchBar(
                  controller: searchController,
                  onChanged: (_) => filterItems(), // Pass the filter function
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: filteredItems.isEmpty
                      ? const Center(
                          child: Text(
                            'No fruits found',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        )
                      : ListView.separated(
                          itemCount: filteredItems.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final FruitInfo fruit = filteredItems[index];
                            final bool isFavorite =
                                favoriteItems.contains(fruit.name);
                            final bool isUnlocked = isItemUnlocked(
                                fruit.name); // Call the passed function
                            return ListTile(
                              //leading: const Icon(Icons.shopping_basket, color: Colors.green),
                              title: Directionality(
                                textDirection: TextDirection
                                    .rtl, // Force RTL for the title
                                child: Text(
                                  fruit.name,
                                  style: const TextStyle(
                                    fontSize: 18, // Or 16 for tablet/desktop
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              subtitle: Directionality(
                                textDirection: TextDirection
                                    .ltr, // Force LTR for the subtitle
                                child: Text(
                                  '${fruit.frenchTranslation} | ${fruit.arabicTranslation}',
                                  style: const TextStyle(
                                    fontSize: 14, // Or 12 for tablet/desktop
                                    color: Colors.grey,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              leading: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Lock icon - TAP THIS TO UNLOCK
                                  IconButton(
                                    icon: Icon(
                                      isUnlocked ? Icons.lock_open : Icons.lock,
                                      color: isUnlocked
                                          ? Colors.green
                                          : Colors.red,
                                      size: 24,
                                    ),
                                    onPressed: () {
                                      if (isUnlocked) {
                                        // Already unlocked - go to detail
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => DetailScreen(
                                              fruit: fruit,
                                              isFavorite: isFavorite,
                                              onToggleFavorite: (itemName) =>
                                                  toggleFavorite(
                                                      itemName), // Wrap in lambda
                                              toggleTheme: toggleTheme,
                                            ),
                                          ),
                                        ).then((_) =>
                                            loadFavorites()); // Call the passed function
                                      } else {
                                        // Not unlocked - show unlock dialog
                                        if (keys > 0) {
                                          showUnlockDialog(
                                              fruit); // Call the passed function
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
                                    icon: Icon(
                                      isFavorite
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: isFavorite ? Colors.red : null,
                                    ),
                                    onPressed: () => toggleFavorite(
                                        fruit.name), // Call the passed function
                                  ),
                                ],
                              ),
                              onTap: () {
                                // Main list item tap - behavior based on unlock state
                                if (isUnlocked) {
                                  // Already unlocked - go directly to detail page
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailScreen(
                                        fruit: fruit,
                                        isFavorite: isFavorite,
                                        onToggleFavorite: (itemName) =>
                                            toggleFavorite(
                                                itemName), // Wrap in lambda
                                        toggleTheme: toggleTheme,
                                      ),
                                    ),
                                  ).then((_) =>
                                      loadFavorites()); // Call the passed function
                                } else {
                                  // Not unlocked - show unlock first message
                                  showUnlockFirstDialog(); // Call the passed function
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
