// lib/data/vegetable_data.dart
import 'dictionary_item.dart'; // We'll create this base class

class VegetableInfo extends DictionaryItem {
  VegetableInfo({
    required super.name,
    required super.frenchTranslation,
    required super.arabicTranslation,
    required super.definition,
  });
}

class VegetableData {
  static List<VegetableInfo> vegetables = [
    VegetableInfo(
      name: 'Carrot',
      frenchTranslation: 'Carotte',
      arabicTranslation: 'جزر',
      definition: 'An orange root vegetable with a crisp texture when raw.',
    ),
    VegetableInfo(
      name: 'Broccoli',
      frenchTranslation: 'Brocoli',
      arabicTranslation: 'بروكلي',
      definition: 'A green plant grown for its edible flower heads.',
    ),
    VegetableInfo(
      name: 'Spinach',
      frenchTranslation: 'Épinard',
      arabicTranslation: 'سبانخ',
      definition: 'A leafy green flowering plant eaten as a vegetable.',
    ),
    VegetableInfo(
      name: 'Potato',
      frenchTranslation: 'Pomme de terre',
      arabicTranslation: 'بطاطا',
      definition: 'An edible tuber native to South America.',
    ),
    // Add more vegetables...
  ];
}
