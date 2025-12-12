import 'package:flutter/material.dart';

/// Reusable menu button widget for app bars
class AppMenuButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const AppMenuButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.menu),
      onPressed: onPressed ?? () => _showComingSoonDialog(context),
      tooltip: 'Menu',
    );
  }

  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Coming Soon'),
        content: const Text('Menu feature is under development.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
