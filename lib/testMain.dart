import 'package:flutter/material.dart';

/// Flutter code sample for [IconButton].

void main() => runApp(const IconButtonExampleApp());

class IconButtonExampleApp extends StatelessWidget {
  const IconButtonExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('IconButton Sample')),
        body: const IconButtonExample(),
      ),
    );
  }
}

class IconButtonExample extends StatelessWidget {
  const IconButtonExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, // Align buttons in the center horizontally
          children: [
            Ink(
              decoration: const ShapeDecoration(
                color: Colors.lightBlue,
                shape: CircleBorder(),
              ),
              child: IconButton(
                icon: const Icon(Icons.flight),
                color: Colors.white,
                onPressed: () {
                  // Handle the onPressed action for the first IconButton
                },
              ),
            ),
            SizedBox(width: 20), // Add some spacing between the buttons
            Ink(
              decoration: const ShapeDecoration(
                color: Colors.lightBlue,
                shape: CircleBorder(),
              ),
              child: IconButton(
                icon: const Icon(Icons.luggage),
                color: Colors.white,
                onPressed: () {
                  // Handle the onPressed action for the second IconButton
                },
              ),
            ),

            SizedBox(width: 20), // Add some spacing between the buttons
            Ink(
              decoration: const ShapeDecoration(
                color: Colors.lightBlue,
                shape: CircleBorder(),
              ),
              child: IconButton(
                icon: const Icon(Icons.house),
                color: Colors.white,
                onPressed: () {
                  // Handle the onPressed action for the second IconButton
                },
              ),
            ),
            SizedBox(width: 20), // Add some spacing between the buttons
            Ink(
              decoration: const ShapeDecoration(
                color: Colors.lightBlue,
                shape: CircleBorder(),
              ),
              child: IconButton(
                icon: const Icon(Icons.shopping_cart),
                color: Colors.white,
                onPressed: () {
                  // Handle the onPressed action for the second IconButton
                },
              ),
            ),

          ],
        ),
      ),
    );
  }
}
