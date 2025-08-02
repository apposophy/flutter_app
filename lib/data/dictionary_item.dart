// lib/data/dictionary_item.dart

/// Abstract base class for dictionary items.
abstract class DictionaryItem {
  final String name;
  final String frenchTranslation;
  final String arabicTranslation;
  final String definition;

  DictionaryItem({
    required this.name,
    required this.frenchTranslation,
    required this.arabicTranslation,
    required this.definition,
  });
}
