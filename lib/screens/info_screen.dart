// lib/screens/info_screen.dart
import 'package:flutter/material.dart';

class InfoScreen extends StatelessWidget {
  final Function() toggleTheme;
  final int keys;
  final Function() resetKeys;
  final Function() resetAllUnlocks;

  const InfoScreen({
    super.key, 
    required this.toggleTheme,
    required this.keys,
    required this.resetKeys,
    required this.resetAllUnlocks,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Info'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fruit Dictionary',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Keys Remaining: $keys',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: resetKeys,
              child: const Text('Reset Keys (Get 5 More)'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: resetAllUnlocks,
              child: const Text('Reset All Unlocks'),
            ),
            const SizedBox(height: 30),
            const Text(
              'Features:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const ListTile(
              leading: Icon(Icons.check, color: Colors.green),
              title: Text('Browse fruit dictionary'),
            ),
            const ListTile(
              leading: Icon(Icons.check, color: Colors.green),
              title: Text('Search fruits by name or translation'),
            ),
            const ListTile(
              leading: Icon(Icons.check, color: Colors.green),
              title: Text('Multilingual support (English, French, Arabic)'),
            ),
            const ListTile(
              leading: Icon(Icons.check, color: Colors.green),
              title: Text('Unlock items with keys'),
            ),
            const ListTile(
              leading: Icon(Icons.check, color: Colors.green),
              title: Text('Persistent unlock state'),
            ),
            const ListTile(
              leading: Icon(Icons.check, color: Colors.green),
              title: Text('Mark favorites'),
            ),
            const SizedBox(height: 30),
            const Text(
              'How to Use:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const ListTile(
              leading: Icon(Icons.lock, color: Colors.red),
              title: Text('Locked items require keys to unlock'),
            ),
            const ListTile(
              leading: Icon(Icons.lock_open, color: Colors.green),
              title: Text('Tap lock icon to unlock items'),
            ),
            const ListTile(
              leading: Icon(Icons.touch_app, color: Colors.blue),
              title: Text('Tap unlocked items to view details'),
            ),
            const SizedBox(height: 30),
            const Text(
              'Made with Flutter ❤️',
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}