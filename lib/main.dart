// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/main_screen.dart';
// Remove direct SharedPreferences import from here
// import 'package:shared_preferences/shared_preferences.dart'; // <-- Remove or comment out
import 'themes/app_theme.dart';
// 1. Import the new service
import 'services/key_unlock_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<MyAppState>()!;

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  bool _isDarkMode = false;
  // 2. Create an instance of the service
  final KeyUnlockService _keyUnlockService = KeyUnlockService();

  @override
  void initState() {
    super.initState();
    _loadAppState(); // Load theme and key/unlock data
  }

  // 3. Consolidate loading logic
  Future<void> _loadAppState() async {
    // Load key/unlock data using the service
    await _keyUnlockService.loadKeysAndUnlocks();

    // If you had other app-wide state to load (e.g., user settings), you'd do it here too.
    // For now, we just trigger a rebuild after loading the service data.
    setState(() {
      // setState is called to ensure the UI reflects the loaded data if needed elsewhere in MyApp build,
      // though primarily MainScreen uses the passed values.
    });
  }

  void toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  bool get isDarkMode => _isDarkMode;
  // 4. Expose service getters/methods through MyAppState if needed by other parts of MyApp's build
  // For this app, MainScreen gets the necessary data passed via constructor, so these might not be strictly needed here,
  // but exposing them keeps the pattern consistent if MyApp's build needed them.
  int get keys => _keyUnlockService.keys;
  bool isItemUnlocked(String item) => _keyUnlockService.isItemUnlocked(item);

  // 5. Wrap service methods to expose them to the widget tree
  Future<void> unlockItem(String item) async {
    final bool wasUnlocked = await _keyUnlockService.unlockItem(item);
    if (wasUnlocked) {
      // If the unlock was successful, update the UI
      setState(() {
        // setState triggers a rebuild, passing the updated key count and unlock status to MainScreen
      });
    }
    // If unlock failed (e.g., no keys), the UI (e.g., HomeScreen/FavoritesScreen) should handle showing a message.
  }

  Future<void> resetKeys() async {
    await _keyUnlockService.resetKeys();
    setState(() {
      // Update UI with reset keys
    });
  }

  Future<void> resetAllUnlocks() async {
    await _keyUnlockService.resetAllUnlocks();
    setState(() {
      // Update UI with cleared unlocks
    });
  }

  @override
  Widget build(BuildContext context) {
    // 6. Pass data and methods to MainScreen
    return MaterialApp(
      title: 'Fruit App',
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: MainScreen(
        toggleTheme: toggleTheme,
        isDarkMode: _isDarkMode,
        // Pass data from the service
        keys: _keyUnlockService.keys, // Current key count
        // Pass wrapped methods that interact with the service and call setState
        unlockItem: unlockItem, // Wrapped unlock method
        resetKeys: resetKeys, // Wrapped reset keys method
        isItemUnlocked:
            _keyUnlockService.isItemUnlocked, // Direct pass of the check method
        resetAllUnlocks: resetAllUnlocks, // Wrapped reset unlocks method
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
