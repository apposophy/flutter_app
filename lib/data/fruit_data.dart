// lib/data/fruit_data.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dictionary_item.dart'; // Add this import

class FruitInfo extends DictionaryItem {
  // Extend DictionaryItem
  FruitInfo({
    required super.name,
    required super.frenchTranslation,
    required super.arabicTranslation,
    required super.definition,
  });
}

class FruitData {
  static List<FruitInfo> fruits = [
    FruitInfo(
      name: 'Apple',
      frenchTranslation: 'Pomme',
      arabicTranslation: 'تفاحة',
      definition:
          'A round fruit with red or green skin and a whitish interior.',
    ),
    FruitInfo(
      name: 'Banana',
      frenchTranslation: 'Banane',
      arabicTranslation: 'موزة',
      definition:
          'A long curved fruit with a yellow skin and soft sweet flesh.',
    ),
    FruitInfo(
      name: 'Orange',
      frenchTranslation: 'Orange',
      arabicTranslation: 'برتقال',
      definition:
          'A round citrus fruit with a tough bright reddish-yellow rind.',
    ),
    FruitInfo(
      name: 'Mango',
      frenchTranslation: 'Mangue',
      arabicTranslation: 'مانجو',
      definition: 'A tropical stone fruit with juicy flesh and sweet flavor.',
    ),
    FruitInfo(
      name: 'Strawberry',
      frenchTranslation: 'Fraise',
      arabicTranslation: 'فراولة',
      definition: 'A sweet soft red fruit with a seed-studded surface.',
    ),
    FruitInfo(
      name: 'Grapes',
      frenchTranslation: 'Raisin',
      arabicTranslation: 'عنب',
      definition: 'Small oval fruits that grow in clusters on vines.',
    ),
    FruitInfo(
      name: 'Pineapple',
      frenchTranslation: 'Ananas',
      arabicTranslation: 'أناناس',
      definition:
          'A tropical fruit with a tough brownish-yellow rind and sweet flesh.',
    ),
    FruitInfo(
      name: 'Watermelon',
      frenchTranslation: 'Pastèque',
      arabicTranslation: 'بطيخ أحمر',
      definition: 'A large fruit with a hard green rind and juicy red flesh.',
    ),
    FruitInfo(
      name: 'Kiwi',
      frenchTranslation: 'Kiwi',
      arabicTranslation: 'كيوي',
      definition:
          'A brown fuzzy fruit with bright green flesh and tiny black seeds.',
    ),
    FruitInfo(
      name: 'Blueberry',
      frenchTranslation: 'Myrtille',
      arabicTranslation: 'توت أزرق',
      definition:
          'Small round blue fruits that grow on bushes and are rich in antioxidants.',
    ),
    FruitInfo(
      name: 'Papaya',
      frenchTranslation: 'Papaye',
      arabicTranslation: 'بابايا',
      definition:
          'A tropical fruit with orange flesh and black seeds in the center.',
    ),
    FruitInfo(
      name: 'Cherry',
      frenchTranslation: 'Cerise',
      arabicTranslation: 'كرز',
      definition:
          'A small round stone fruit with red or black skin and sweet flesh.',
    ),
  ];

  // SharedPreferences keys
  static const String _favoritesKey = 'favorite_fruits';
  static const String _unlockedItemsKey = 'unlocked_items';

  // Load favorites from SharedPreferences
  static Future<List<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? favorites = prefs.getStringList(_favoritesKey);
    return favorites ?? [];
  }

  // Save favorites to SharedPreferences
  static Future<void> saveFavorites(List<String> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, favorites);
  }

  // Load unlocked items from SharedPreferences
  static Future<List<String>> loadUnlockedItems() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? unlocked = prefs.getStringList(_unlockedItemsKey);
    return unlocked ?? [];
  }

  // Save unlocked items to SharedPreferences
  static Future<void> saveUnlockedItems(List<String> unlockedItems) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_unlockedItemsKey, unlockedItems);
  }
}
