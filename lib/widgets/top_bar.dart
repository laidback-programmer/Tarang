import 'package:flutter/material.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(title: const Text('Sea Safe'));
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
