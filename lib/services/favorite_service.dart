// lib/services/favorite_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteService {
  static const String _favoritesKey = 'favorite_fruits';

  // Save list of favorite fruits
  static Future<void> saveFavorites(List<String> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, favorites);
  }

  // Load list of favorite fruits
  static Future<List<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoritesKey) ?? [];
  }

  // Add a fruit to favorites
  static Future<void> addFavorite(String fruit) async {
    final favorites = await loadFavorites();
    if (!favorites.contains(fruit)) {
      favorites.add(fruit);
      await saveFavorites(favorites);
    }
  }

  // Remove a fruit from favorites
  static Future<void> removeFavorite(String fruit) async {
    final favorites = await loadFavorites();
    if (favorites.contains(fruit)) {
      favorites.remove(fruit);
      await saveFavorites(favorites);
    }
  }

  // Check if a fruit is favorited
  static Future<bool> isFavorite(String fruit) async {
    final favorites = await loadFavorites();
    return favorites.contains(fruit);
  }
}