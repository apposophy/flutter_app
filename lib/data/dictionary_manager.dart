// lib/data/dictionary_manager.dart
import 'dictionary_item.dart';
import 'fruit_data.dart';
import 'vegetable_data.dart';
import 'animal_data.dart';

enum DictionaryType {
  fruits('Fruits'),
  vegetables('Vegetables'),
  animals('Animals');

  const DictionaryType(this.displayName);
  final String displayName;
}

class DictionaryManager {
  static final Map<DictionaryType, List<DictionaryItem> Function()>
      _dictionaryMap = {
    DictionaryType.fruits: () => FruitData.fruits,
    DictionaryType.vegetables: () => VegetableData.vegetables,
    DictionaryType.animals: () => AnimalData.animals,
  };

  static List<DictionaryType> getAvailableDictionaries() {
    return DictionaryType.values;
  }

  static List<DictionaryItem> getItems(DictionaryType type) {
    final getter = _dictionaryMap[type];
    if (getter != null) {
      return List.unmodifiable(getter());
    }
    return const []; // Return empty list if type not found
  }

  static String getDisplayName(DictionaryType type) {
    return type.displayName;
  }
}
