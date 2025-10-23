import 'package:flutter/material.dart';

class StatusBar extends StatelessWidget {
  final String weather;
  final List<String> ongoingDisasters;

  const StatusBar({super.key, required this.weather, required this.ongoingDisasters});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.blue[100],
      child: Column(
        children: [
          Text('Weather: $weather'),
          Text('Ongoing Disasters: ${ongoingDisasters.length}'),
        ],
      ),
    );
  }
}
