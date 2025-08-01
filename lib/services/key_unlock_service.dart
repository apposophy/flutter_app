// lib/services/key_unlock_service.dart
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:flutter/foundation.dart'; // For ValueNotifier if needed, or just for Future

/// A service class to manage the app's key currency and item unlock status.
/// This class handles loading, saving, and modifying the key count and unlocked items list.
class KeyUnlockService {
  int _keys = 5;
  Set<String> _unlockedItems = <String>{};

  // Getters for current state
  int get keys => _keys;
  Set<String> get unlockedItems => Set.unmodifiable(
      _unlockedItems); // Return an unmodifiable view for safety

  bool isItemUnlocked(String item) => _unlockedItems.contains(item);

  /// Loads the current key count and unlocked items from persistent storage.
  Future<void> loadKeysAndUnlocks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _keys = prefs.getInt('app_keys') ?? 5;

      final List<String>? unlockedList = prefs.getStringList('unlocked_items');
      _unlockedItems =
          unlockedList != null ? Set<String>.from(unlockedList) : <String>{};
    } catch (e) {
      // Handle potential errors in loading, e.g., corrupted data
      // For simplicity, we'll reset to defaults.
      // A more robust app might show an error or attempt recovery.
      _keys = 5;
      _unlockedItems = <String>{};
      // Consider logging the error
      // print('Error loading keys/unlocks: $e');
    }
  }

  /// Saves the current key count and unlocked items to persistent storage.
  Future<void> _saveKeysAndUnlocks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('app_keys', _keys);
      await prefs.setStringList('unlocked_items', _unlockedItems.toList());
    } catch (e) {
      // Handle potential errors in saving
      // Consider logging the error or notifying the user
      // print('Error saving keys/unlocks: $e');
    }
  }

  /// Attempts to unlock an item.
  /// Decrements the key count if successful.
  /// Returns `true` if the item was unlocked, `false` otherwise (e.g., not enough keys, already unlocked).
  Future<bool> unlockItem(String item) async {
    if (_keys > 0 && !_unlockedItems.contains(item)) {
      _keys--;
      _unlockedItems.add(item);
      await _saveKeysAndUnlocks();
      return true; // Unlock successful
    }
    return false; // Unlock failed
  }

  /// Resets the key count to the default (5).
  Future<void> resetKeys() async {
    _keys = 5;
    await _saveKeysAndUnlocks();
  }

  /// Clears the list of unlocked items.
  Future<void> resetAllUnlocks() async {
    _unlockedItems.clear();
    await _saveKeysAndUnlocks();
  }

  /// (Optional) Method to add keys, e.g., from a purchase or reward.
  /// Returns the new key count.
  Future<int> addKeys(int amount) async {
    if (amount > 0) {
      _keys += amount;
      await _saveKeysAndUnlocks();
    }
    return _keys;
  }
}
