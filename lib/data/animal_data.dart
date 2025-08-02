// lib/data/animal_data.dart
import 'dictionary_item.dart'; // We'll create this base class

class AnimalInfo extends DictionaryItem {
  AnimalInfo({
    required super.name,
    required super.frenchTranslation,
    required super.arabicTranslation,
    required super.definition,
  });
}

class AnimalData {
  static List<AnimalInfo> animals = [
    AnimalInfo(
      name: 'Lion',
      frenchTranslation: 'Lion',
      arabicTranslation: 'أسد',
      definition:
          'A large carnivorous feline mammal living in Africa and northwest India.',
    ),
    AnimalInfo(
      name: 'Elephant',
      frenchTranslation: 'Éléphant',
      arabicTranslation: 'فيل',
      definition: 'A very large plant-eating mammal with a prehensile trunk.',
    ),
    AnimalInfo(
      name: 'Giraffe',
      frenchTranslation: 'Girafe',
      arabicTranslation: 'زرافة',
      definition: 'A tall African mammal with a very long neck and legs.',
    ),
    AnimalInfo(
      name: 'Monkey',
      frenchTranslation: 'Singe',
      arabicTranslation: 'قرد',
      definition:
          'A small to medium-sized primate that typically has a long tail.',
    ),
    // Add more animals...
  ];
}
