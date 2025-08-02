// lib/widgets/home_mobile_layout.dart
import 'package:flutter/material.dart';
import '../widgets/search_bar.dart'; // Assuming this exists and is compatible
import '../data/dictionary_item.dart'; // Import the base class
import '../data/dictionary_manager.dart'; // Import the manager
import '../screens/detail_screen.dart'; // Assuming this exists

class HomeMobileLayout extends StatelessWidget {
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
  final Function() loadFavorites;

  // 2. Add new parameters for dictionary selection
  final Function(DictionaryType)
      onChangeDictionary; // Callback for dictionary change
  final DictionaryType selectedDictionary; // Current selected dictionary

  const HomeMobileLayout({
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
    required this.loadFavorites,
    // 3. Add new parameters to constructor
    required this.onChangeDictionary, // Add this
    required this.selectedDictionary, // Add this
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          title: const Text('Dictionary'), // Generic title
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
                // 4. Add Dropdown for dictionary selection
                DropdownButton<DictionaryType>(
                  value: selectedDictionary, // Use passed state
                  items: DictionaryManager.getAvailableDictionaries()
                      .map((DictionaryType type) {
                    return DropdownMenuItem<DictionaryType>(
                      value: type,
                      child: Text(DictionaryManager.getDisplayName(type)),
                    );
                  }).toList(),
                  onChanged: (DictionaryType? newValue) {
                    if (newValue != null) {
                      // 5. Call the callback when selection changes
                      onChangeDictionary(newValue);
                    }
                  },
                  isExpanded: true, // Take full width
                  underline: Container(), // Remove default underline
                  borderRadius: BorderRadius.circular(10),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 8.0),
                  icon: const Icon(
                      Icons.arrow_drop_down), // Explicitly show dropdown icon
                ),
                const SizedBox(height: 12),
                FruitSearchBar(
                  // Assuming this widget exists and is compatible
                  controller: searchController,
                  onChanged: (_) => filterItems(), // Trigger filtering
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: filteredItems.isEmpty // Use DictionaryItem list
                      ? const Center(
                          child: Text(
                            'No items found',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        )
                      : ListView.separated(
                          itemCount: filteredItems
                              .length, // Iterate over DictionaryItem list
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            // 6. Cast item to DictionaryItem
                            final DictionaryItem item = filteredItems[index];
                            final bool isFavorite =
                                favoriteItems.contains(item.name);
                            final bool isUnlocked = isItemUnlocked(
                                item.name); // Check unlock status

                            return ListTile(
                              leading: const Icon(Icons.shopping_basket,
                                  color: Colors.green),
                              // 7. Use DictionaryItem properties
                              title: Text(
                                item.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${item.frenchTranslation} | ${item.arabicTranslation}',
                                style: const TextStyle(
                                  fontSize: 14,
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
                                      size: 24,
                                    ),
                                    onPressed: () {
                                      if (isUnlocked) {
                                        // Already unlocked - go to detail
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => DetailScreen(
                                              // Assuming DetailScreen can handle DictionaryItem data
                                              // or you adapt the data passed here.
                                              // For now, passing the DictionaryItem and letting DetailScreen adapt
                                              // or casting if DetailScreen strictly needs FruitInfo for fruits.
                                              fruit:
                                                  item, // Pass DictionaryItem (might need casting if DetailScreen is strict)
                                              isFavorite: isFavorite,
                                              onToggleFavorite:
                                                  toggleFavorite, // Pass the callback
                                              toggleTheme: toggleTheme,
                                            ),
                                          ),
                                        ).then((_) =>
                                            loadFavorites()); // Reload favorites after detail screen closes
                                      } else {
                                        // Not unlocked - show unlock dialog
                                        if (keys > 0) {
                                          showUnlockDialog(
                                              item.name); // Pass item name
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
                                        item.name), // Pass item name
                                  ),
                                ],
                              ),
                              onTap: () {
                                // Main list item tap - behavior based on unlock state
                                if (isUnlocked) {
                                  // Already unlocked - go directly to detail page
                                  // (Same navigation logic as lock icon press when unlocked)
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailScreen(
                                        fruit: item, // Pass DictionaryItem
                                        isFavorite: isFavorite,
                                        onToggleFavorite:
                                            toggleFavorite, // Pass the callback
                                        toggleTheme: toggleTheme,
                                      ),
                                    ),
                                  ).then((_) =>
                                      loadFavorites()); // Reload favorites after detail screen closes
                                } else {
                                  // Not unlocked - show unlock first message
                                  showUnlockFirstDialog(); // Show the dialog
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
        // Bottom navigation bar is handled by MainScreen now for mobile.
      ],
    );
  }
}
