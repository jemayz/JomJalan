import 'package:flutter/material.dart';
import 'package:jomjalan/main.dart'; // For colors

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onViewAll;

  const SectionHeader({Key? key, required this.title, required this.onViewAll})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        TextButton(
          onPressed: onViewAll,
          style: TextButton.styleFrom(foregroundColor: primaryGreen),
          child: const Text("View All"),
        ),
      ],
    );
  }
}
