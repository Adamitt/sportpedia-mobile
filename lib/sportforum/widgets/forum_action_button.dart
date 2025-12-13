import 'package:flutter/material.dart';

class ForumActionButton extends StatelessWidget {
  const ForumActionButton({
    super.key,
    required this.onPressed,
    this.tooltip = 'Create Post',
    this.icon = Icons.add,
  });

  final VoidCallback onPressed;
  final String tooltip;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: Colors.indigo,
      foregroundColor: Colors.white,
      child: Icon(icon),
    );
  }
}
